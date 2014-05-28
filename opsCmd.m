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

%% USER INPUT

profileCmd = false; % THE OPS PROFILER WILL RUN AND RETURN PROFILING LOGS

% sysUrl = 'https://ops.cresis.ku.edu/';
sysUrl = 'http://ops2.cresis.ku.edu/';
% sysUrl = 'http://192.168.111.222/';

%% AUTOMATED SECTION (DONT MODFIY)

dbUser = '';
dbPswd = '';

serverUrl = strcat(sysUrl,'ops/');
geoServerUrl = strcat(sysUrl,'geoserver/');

if profileCmd
    web(strcat(serverUrl(1:end-4),'profile-logs/'));
end