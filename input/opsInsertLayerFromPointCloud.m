
ramp_fn = '/scratch/metadata/2014_Greenland_P3/RampSurveyFieldProcessed_Sonntag.txt';
[layer.lat,layer.lon,layer.elev] = read_ramp_pass(ramp_fn);
layer.projection = 'geo';

ins_param.param_fn = ct_filename_param('kuband_param_2014_Greenland_P3.xls');
ins_param.update_layer_types = {'qlook'};
ins_param.update_ops_en = false;
ins_param.layer_name = 'Bottom';
ins_param.er_ice = 1;
geotiff_fn = fullfile(gRadar.gis_path,'greenland','Landsat-7','mzl7geo_90m_lzw.tif');
ins_param.proj = geotiffinfo(geotiff_fn);

%opsInsertLayerFromPointCloud(param,layer);

physical_constants;

params = read_param_xls(ins_param.param_fn);

%% Insert layers into each segment one by one
% ----------------------------------------------------------------------
for param_idx = 1:length(params)
  param = params(param_idx);
  
  if ischar(param.cmd.generic) || ~param.cmd.generic
    continue;
  end
  
  fprintf('Updating surface %s (%s)\n', param.day_seg, datestr(now,'HH:MM:SS'));
  
  load(ct_filename_support(param,'','frames'));
  
  if isempty(param.cmd.frms)
    param.cmd.frms = 1:length(frames.frame_idxs);
  end
  % Remove frames that do not exist from param.cmd.frms list
  [valid_frms,keep_idxs] = intersect(param.cmd.frms, 1:length(frames.frame_idxs));
  if length(valid_frms) ~= length(param.cmd.frms)
    bad_mask = ones(size(param.cmd.frms));
    bad_mask(keep_idxs) = 0;
    warning('Nonexistent frames specified in param.cmd.frms (e.g. frame "%g" is invalid), removing these', ...
      param.cmd.frms(find(bad_mask,1)));
    param.cmd.frms = valid_frms;
  end

  if strcmpi(layer.projection,'geo')
    % Convert layer inputs into map projected coordinates
    [layer.x,layer.y] = projfwd(ins_param.proj,layer.lat,layer.lon);
  else
    error('Mode not supported');
  end
  
  % Remove non-unique points
  [dtri_pnts dtri_idxs] = unique([layer.x layer.y],'rows');
  dtri = DelaunayTri(dtri_pnts(:,1),dtri_pnts(:,2));
  interp_fh = TriScatteredInterp(dtri,layer.elev(dtri_idxs));
  
  for frm_idx = 1:length(param.cmd.frms)
    frm = param.cmd.frms(frm_idx);
    
    %% Update Each Data File Type listed in ins_param.update_layer_types
    % ---------------------------------------------------------------------
    for layer_type_idx = 1:length(ins_param.update_layer_types)
      layer_type = ins_param.update_layer_types{layer_type_idx};
      
      data_fn = fullfile(ct_filename_out(param,layer_type,''), ...
        sprintf('Data_%s_%03d.mat', param.day_seg, frm));
      fprintf('  Updating %s (%s)\n', data_fn, datestr(now,'HH:MM:SS'));
    
      %mdata = load(data_fn,'GPS_time','Latitude','Longitude','Elevation','layerData','Surface','Bottom');
      mdata = load(data_fn);
      
      if isfield(mdata,'layerData')
        error('Mode not supported');
      else
        % Convert track into map projected coordinates
        [x,y] = projfwd(ins_param.proj,mdata.Latitude,mdata.Longitude);
        
        % Interpolate point cloud onto track
        layer_elev = interp_fh(x,y);
        
        range = mdata.Elevation - layer_elev;
        layer_twtt = min(mdata.Surface, 2/c * range) ...
          + max(0, 2*sqrt(ins_param.er_ice)/c * (range-mdata.Surface*c/2));
        layer_twtt(isnan(range)) = NaN;
        
        figure(1); clf;
        imagesc([],mdata.Time,lp(mdata.Data));
        hold on;
        plot(mdata.Surface,'b');
        plot(layer_twtt,'k','LineWidth',2);
        ylim([min(min(layer_twtt),min(mdata.Surface)) max(max(layer_twtt),max(mdata.Surface))])
        legend('Radar Surface','Ramppass')
        
        mdata.(ins_param.layer_name) = layer_twtt;
        
        %save(data_fn,'-append','mdata',ins_param.layer_name);
      end
    end
  end
  
end



return


ramp_fn = '/scratch/metadata/2014_Greenland_P3/RampSurveyFieldProcessed_Sonntag.txt';
[layer.lat,layer.lon,layer.elev] = read_ramp_pass(ramp_fn);
layer.projection = 'geo';

param.param_fn = ct_filename_param('snow_param_2014_Greenland_P3.xls');
param.data_type = 'qlook';
param.update_layer_en = true;
param.update_ops_en = false;
param.layer_name = 'ramp_pass';
opsInsertLayerFromPointCloud(param,layer);



