function opsLayerData = layerDataToOps(layerDataFn,settings)
% opsLayerData = layerDataToOps(layerDataFn,settings)
%
% 1. Converts CReSIS layerData to the OPS format.
% 2. Interpolates layerData onto a fixed scale based on point paths in the OPS database.
% 3. Removes any large gaps in the layerData (see also data_gaps_check.m)
% 4. Removes any duplicate points in the layerData (keeps manual over auto points)
%
% Input:
%   layerDataFn: Absolute path to a CReSIS layerData (.m) file.
%   settings: optional settings structure with the following fields
%     .layerFilter = REGULAR EXPRESSION OF LAYER NAMES TO INSERT
%       for more information on layerFilter see also runOpsBulkInsert.m
%
% Output:
%   opsLayerData = structure with fields:
%       properties.point_path_id = integer array 
%       properties.user = string
%       properties.twtt = double array
%       properties.type = integer arry (1 or 2) 1:manual, 2:auto
%       properties.quality = integer array (1, 2 or 3) 1:good, 2:moderate, 3:derived
%       properties.lyr_name = string ('surface','bottom', ...)
%
% Author: Kyle W. Purdon
%
% see also opsGetPath opsCreateLayerPoints

% SET DAFAULTS AND CHECK INPUT
if ~exist('settings','var')
  settings = struct();
end
if ~isfield(settings,'layerFilter') || isempty(settings.layerFilter)
  settings.layerFilter = inline('~isempty(regexp(x,''.*''))');
end

% LOAD THE LAYERDATA FILE
lyr = load(layerDataFn,'GPS_time','Latitude','Longitude','Elevation','layerData');

% LOAD ECHOGRAM DATA IF LAYERDATA DOES NOT EXIST IN FILE
if ~isfield(lyr, 'layerData')
  lyr = load(layerData_fn,'GPS_time','Latitude','Longitude','Elevation','Surface','Truncate_Bins','Elevation_Correction','Time');
  lyr = uncompress_echogram(lyr);
  lyr.layerData{1}.value{1}.data = NaN*zeros(size(lyr.Surface));
  lyr.layerData{1}.value{2}.data = lyr.Surface;
  lyr.layerData{1}.quality = ones(size(lyr.Surface));
end

% DONT SUPPORT NEW LAYERDATA FOR NOW (CRESIS > OPS ONLY)
% CHECK WHICH LAYERDATA FORMAT THIS IS (CReSIS OR OPS)
% newLd = false;
if ~isfield(lyr.layerData{1},'value')
  error('NEW LAYERDATA FORMAT NOT SUPPORTED YET')
  % newLd = true;
end

% GET OPS PATH INFORMATION
opsCmd;
pathParam.properties.location = settings.location;
pathParam.properties.season = settings.seasonName;
pathParam.properties.start_gps_time = min(lyr.GPS_time);
pathParam.properties.stop_gps_time = max(lyr.GPS_time);
pathParam.properties.nativeGeom = true;
[~,pathData] = opsGetPath(settings.sysName,pathParam);

% BUILD UP A STRUCTURE COMBINE AUTO/MANUAL AND REMOVE DUPLICATES
lyrCombined = [];
opsLayerData = [];
for layerIdx = 1:length(lyr.layerData)
  
  % SET DEFAULT LAYER NAMES (FOR SURFACE AND BOTTOM)
  if ~isfield(lyr.layerData{layerIdx},'name')
    if layerIdx == 1
      lyr.layerData{layerIdx}.name = 'surface';
    elseif layerIdx == 2
      lyr.layerData{layerIdx}.name = 'bottom';
    end
  end
  
  % CHECK IF THIS LAYER SHOULD BE PROCESSED
  if ~settings.layerFilter(lyr.layerData{layerIdx}.name)
    continue;
  end
  
  % ADD MANUAL LAYER POINTS (type = 1)
  layerSource = lyr.layerData{layerIdx}.value{1}.data;
  goodIdxs = find(~isnan(layerSource) & isfinite(layerSource));
  lyrCombined.gps_time = lyr.GPS_time(goodIdxs);
  lyrCombined.lat = lyr.Latitude(goodIdxs);
  lyrCombined.lon = lyr.Longitude(goodIdxs);
  lyrCombined.elev = lyr.Elevation(goodIdxs);
  lyrCombined.twtt = double(layerSource(goodIdxs));
  lyrCombined.quality = lyr.layerData{layerIdx}.quality(goodIdxs);
  
  % ADD AUTOMATIC LAYER POINTS (type = 2)
  layerSource = lyr.layerData{layerIdx}.value{2}.data;
  goodIdxs = find(~isnan(layerSource) & isfinite(layerSource));
  lyrCombined.gps_time = cat(2,lyrCombined.gps_time,lyr.GPS_time(goodIdxs));
  lyrCombined.lat = cat(2,lyrCombined.lat,lyr.Latitude(goodIdxs));
  lyrCombined.lon = cat(2,lyrCombined.lon,lyr.Longitude(goodIdxs));
  lyrCombined.elev = cat(2,lyrCombined.elev,lyr.Elevation(goodIdxs));
  lyrCombined.twtt = cat(2,lyrCombined.twtt,double(layerSource(goodIdxs)));
  lyrCombined.quality = cat(2,lyrCombined.quality,lyr.layerData{layerIdx}.quality(goodIdxs));
  
  % FIND DUPLICATES AND REMOVE
  [~,notDupIdxs] = unique(lyrCombined.gps_time);
  newGpsTime = nan(size(lyrCombined.gps_time));
  newGpsTime(notDupIdxs) = lyrCombined.gps_time(notDupIdxs);
  lyrCombined.gps_time = newGpsTime;
  clear newGpsTime;
  
  % REMOVE ALL OF THE DUPLICATE DATA FROM THE CURRENT COMBINED LAYERDATA
  keepIdxs = ~isnan(lyrCombined.gps_time);
  lyrCombined.gps_time = lyrCombined.gps_time(keepIdxs);
  lyrCombined.lat = lyrCombined.lat(keepIdxs);
  lyrCombined.lon = lyrCombined.lon(keepIdxs);
  lyrCombined.elev = lyrCombined.elev(keepIdxs);
  lyrCombined.twtt = lyrCombined.twtt(keepIdxs);
  lyrCombined.quality = lyrCombined.quality(keepIdxs);
  lyrCombined.quality(isnan(lyrCombined.quality)) = 1; % CORRECT FOR NAN QUALITY
  lyrCombined.lyr_name = lower(lyr.layerData{layerIdx}.name); % ADD A NAME FIELD
  
  % FIND GAPS IN DATA
  layerAlongTrack = geodetic_to_along_track(lyrCombined.lat,lyrCombined.lon,lyrCombined.elev);
  pathAlongTrack = geodetic_to_along_track(pathData.properties.Y,pathData.properties.X,pathData.properties.elev);
  dataGapIdxs = data_gaps_check(pathData.properties.gps_time,lyrCombined.gps_time,pathAlongTrack,layerAlongTrack,50,20);
  
  % INTERPOLATE COMBINED LAYERDATA ONTO OPS PATH, STORE IN THE OUTPUT
  opsLayerData(end+1).properties.point_path_id = pathData.properties.id;
  opsLayerData(end).properties.username = settings.userName;
  opsLayerData(end).properties.twtt = interp1(lyrCombined.gps_time,lyrCombined.twtt,pathData.properties.gps_time);
  opsLayerData(end).properties.type = ones(size(pathData.properties.gps_time));
  opsLayerData(end).properties.quality = interp1(lyrCombined.gps_time,lyrCombined.quality,pathData.properties.gps_time,'nearest');
  opsLayerData(end).properties.lyr_name = lyrCombined.lyr_name;
  
  % REMOVE GAPS IN DATA
  opsLayerData(end).properties.point_path_id = double(opsLayerData(end).properties.point_path_id(~dataGapIdxs));
  opsLayerData(end).properties.twtt = opsLayerData(end).properties.twtt(~dataGapIdxs);
  opsLayerData(end).properties.type = double(opsLayerData(end).properties.type(~dataGapIdxs));
  opsLayerData(end).properties.quality = double(opsLayerData(end).properties.quality(~dataGapIdxs));
  
  lyrCombined = []; % RESET COMBINED LAYERDATA STRUCTURE
  
end
end