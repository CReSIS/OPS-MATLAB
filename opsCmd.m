% =========================================================================
% OPS COMMAND SCRIPT
%
% This script is used throughout the OPS MATLAB API and sets up some basic
% parameters and variables used throughout the script.
%
% Please set the user input below.
%
% Authors: Kyle W. Purdon, Trey Stafford
%
% =========================================================================

global gOps;

%% USER INPUT

gOps.profileCmd = false; % THE OPS PROFILER WILL RUN AND RETURN PROFILING LOGS

% gOps.sysUrl = 'https://ops.cresis.ku.edu/';
gOps.sysUrl = 'http://192.168.111.222/';

%% AUTOMATED SECTION (DONT MODFIY)

gOps.dbUser = 'doesnt';
gOps.dbPswd = 'doanything';

gOps.serverUrl = strcat(gOps.sysUrl,'ops/');
gOps.geoServerUrl = strcat(gOps.sysUrl,'geoserver/');

if gOps.profileCmd
    web(strcat(server_url(1:end-4),'profile-logs/'));
end