function [status,data] = opsGetCrossovers(sys,param)
%
% [status,data] = opsGetCrossovers(sys,param)
%
% Retrieves crossovers from the database.
%
% Input:
%   sys: (string) sys name ('rds','accum','snow',...)
%   param: structure with fields
%     properties.location = string ('arctic' or 'antarctic')
%     properties.lyr_name = string or cell of strings ('surface','bottom')
%     PICK ONE OF THE FOLLOWING:
%       properties.point_path_id: integer or array of integers
%       properties.frame = string or cell of strings
%
% Output:
%   status: integer (0:Error,1:Success,2:Warning)
%   data: structure with fields (or error message)
%       properties.source_point_path_id = integer array
%       properties.cross_point_path_id = integer array
%       properties.source_elev = double array
%       properties.cross_elev = double array
%       properties.layer_id = integer array
%       properties.frame_id = integer array
%       properties.twtt = double array
%       properties.angle = double array
%       properties.abs_error = double array
%
% Author: Trey Stafford, Kyle W. Purdon

% CONSTRUCT THE JSON STRUCTURE
jsonStruct = struct('properties',param.properties);

% CONVERT THE JSON STRUCTURE TO A JSON STRING
try
    jsonStr = tojson(jsonStruct);
catch ME
    jsonStr = savejson('',jsonStruct,'FloatFormat','%2.10f');
end

% SEND THE COMMAND TO THE SERVER
opsCmd;
if gOps.profileCmd
    [jsonResponse,~] = opsUrlRead(strcat(gOps.serverUrl,'profile'),gOps.dbUser,gOps.dbPswd,...
        'Post',{'app' sys 'data' jsonStr 'view' 'getCrossovers'});
else
    [jsonResponse,~] = opsUrlRead(strcat(gOps.serverUrl,'get/crossovers/'),gOps.dbUser,gOps.dbPswd,...
        'Post',{'app' sys 'data' jsonStr});
end

% DECODE THE SERVER RESPONSE
[status,decodedJson] = jsonResponseDecode(jsonResponse);

if status == 2
    data = []; % CLIENT NEEDS TO HANDLE EMPTY DATA
else
    data.properties.source_point_path_id = decodedJson.source_point_path_id;
    data.properties.cross_point_path_id = decodedJson.cross_point_path_id;
    data.properties.source_elev = decodedJson.source_elev;
    data.properties.cross_elev = decodedJson.cross_elev;
    data.properties.layer_id = decodedJson.layer_id;
    data.properties.frame_id = decodedJson.frame_id;
    data.properties.twtt = decodedJson.twtt;
    data.properties.angle = decodedJson.angle;
    data.properties.abs_error = decodedJson.abs_error;
end
end