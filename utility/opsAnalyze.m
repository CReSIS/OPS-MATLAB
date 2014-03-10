function [status,message] = opsAnalyze(sys,param)
%
% [status,message] = opsAnalyze(sys,param)
%
% Analyzes tables and updates database statistics.
%
% Input:
%   sys: (string) sys name ('rds','accum','snow',...)
%   param: structure with fields
%     properties.tables = cell array of strings specifying table names to be analyzed. (without system_ prefix) 
%
% Output:
%   status: integer (0:Error,1:Success)
%   message: status message
%
% Author: Trey Stafford

% CONSTRUCT THE JSON STRUCTURE
jsonStruct = struct('properties',param.properties);

% CONVERT THE JSON STRUCUTRE TO A JSON STRING
try
  jsonStr = tojson(jsonStruct);
catch ME
  jsonStr = savejson('',jsonStruct,'FloatFormat','%2.10f');
end

% SEND THE COMMAND TO THE SERVER
opsCmd;
if gOps.profileCmd
  [jsonResponse,~] = opsUrlRead(strcat(gOps.serverUrl,'profile'),gOps.dbUser,gOps.dbPswd,...
    'Post',{'app' sys 'data' jsonStr 'view' 'analyze'});
else
  [jsonResponse,~] = opsUrlRead(strcat(gOps.serverUrl,'analyze'),gOps.dbUser,gOps.dbPswd,...
    'Post',{'app' sys 'data' jsonStr});
end

% DECODE THE SERVER RESPONSE
[status,decodedJson] = jsonResponseDecode(jsonResponse);

% CREATE THE DATA OUPUT STRUCTURE OR MESSAGE
message = decodedJson;

end