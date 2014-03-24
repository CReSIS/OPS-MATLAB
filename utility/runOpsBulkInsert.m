% =========================================================================
% OPS BULK DATA LOADER
%
% Loads data in bulk from the CReSIS filesystem to the OPS.
%
% To use this script manually edit the input fileds under USER INPUT.
%
% Data inputs required:
%   path: records and frames files
%   layerData: layerData files or echogram files
%   atm: atm L2 nadir interpolated files
%
% Multi-Layer data is supported, the layerData files must contain a name
% field with a unique name identifying each layer.
%
% Authors: Kyle W. Purdon, Trey Stafford, John Paden
%
% see also opsBulkInsert.m opsCreatePath.m opsCreaLayerPoints.m layerDataToOps.m
%
% =========================================================================

%% USER INPUT

% ----------------------------------------------------------------
% runType: THE TYPE OF DATA INSERT TO COMPLETE
%   1: INSERTS PATHS ONLY
%   2: INSERTS LAYERS ONLY
%   3: INSERT ATM LAYERS ONLY
%   4: (1) AND (2)
%   5: (1), (2), AND (3)
settings.runType = 4;

% ----------------------------------------------------------------
% paramFn: FILENAME.xls OF EXCEL CReSIS PARAMS SHEET
settings.paramFn = 'rds_param_2012_Antarctica_DC8.xls';

% ----------------------------------------------------------------
% location: LOCATION NAME ('arctic' OR 'antarctic')
% settings.location = 'arctic';
settings.location = 'antarctic';

% ----------------------------------------------------------------
% sysName: SYSTEM NAME ('rds','snow','accum','kuband')
settings.sysName = 'rds';

% ----------------------------------------------------------------
% layerDataPath: PATH TO LAYERDATA FILES
%   'layerData': normal layerData path
%   'qlook': normal layerData path for using echogram data
%   'fullfile('CSARP_post','layerData')': posted layerData path
%   'fullfile('CSARP_post','qlook')': posted layerData qlook path
settings.layerDataPath = 'layerData';
% setting.layerDataPath = 'qlook';
% settings.layerDataPath = fullfile('CSARP_post','layerData');
% settings.layerDataPath = fullfile('CSARP_post','qlook');

% ----------------------------------------------------------------
% layerFilter: REGULAR EXPRESSION OF LAYER NAMES TO INSERT
%   inline('~isempty(regexp(x,''(^surface$|^bottom$)''))');: only surface and bottom layers
%   inline('~isempty(regexp(x,''^lm.*''))');: only layers starting with 'lm'
settings.layerFilter = inline('~isempty(regexp(x,''(^surface$|^bottom$)''))');
% settings.layerFilter = inline('~isempty(regexp(x,''^lm.*''))');


%% OPTIONAL USER INPUT (COMMON DEFAULT PROPERTIES)

% ----------------------------------------------------------------
% pathSpacing: DISTANCE IN METERS TO SPACE THE PATH/LAYER POINTS (DEFAULT = 2.50m)
settings.pathSpacing = 2.5;

% ----------------------------------------------------------------
% autoReleaseSeason: BOOLEAN, SHOULD THE SEASON AUTOMATICALLY BE PUBLIC? (DEFAULT = false)
settings.autoReleaseSeason = false;

% ----------------------------------------------------------------
% logsOn: BOOLEAN, SHOULD THE COMMAND WINDOW BE LOGGED TO A TXT FILE?
settings.logsOn = true;

%% AUTOMATED SECTION

% ERROR CHECK THE INPUT
if ~any(strcmp(settings.location,{'arctic','antarctic'}));
  tmp = questdlg({'Location must be ''arctic'' or ''antarctic''','',sprintf('You entered: %s',settings.location),''},'INVALID LOCATION','OK','OK');
  error('INVALID LOCATION');
elseif ~any(strcmp(settings.sysName,{'rds','snow','accum','kuband'}));
  tmp = questdlg({'System must be ''rds'',''snow'',''accum'' or ''kuband''','',sprintf('You entered: %s',settings.sysName),''},'INVALID SYSTEM','OK','OK');
  error('INVALID SYSTEM');
end

% GET THE CReSIS GLOBAL
global gRadar;
if isvarname('gRadar')
  settings = mergestruct(settings,gRadar);
else
  warning('gRadar IS NOT A GLOBAL VARIABLE.')
  fprintf('Type ''dbcont'' to run startup.m and continue\n or ''dbquit'' to fix this yourself ...\n');
  keyboard;
  startup
end

% RUN OPS BULK INSERT
opsBulkInsert(settings);