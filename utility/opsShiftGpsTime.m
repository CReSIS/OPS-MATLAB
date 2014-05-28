function [ status,data ] = opsShiftGpsTime( sys,param )
%
% [status,data] = opsShiftGpsTime(sys,param)
%
% Shift the GPS time of layer points in the database.
%
% Input:
%   sys: (string) sys name ('rds','accum','snow',...)
%   param: structure with fields
%     properties.offset = number
%     properties.location = string ('arctic' or 'antarctic')
%     properties.season = string
%     properties.segment = string
%     properties.lyr_name = string ('surface','bottom', etc...)
%
% Output:
%   data: see opsGetLayerPoints
%   message: status message
%
% Author: Weibo Liu & Kyle W. Purdon 

% authenticate the user
[authParam,~,~] = opsAuthenticate(struct('properties',[]));

% get the layer points
[~,data] = opsGetLayerPoints(sys,param);

% shift the gps time
shifted_gps_time = data.properties.gps_time + param.properties.offset;

% interpolate twtt onto shifted gps time
shifted_twtt = interp1(data.properties.gps_time,data.properties.twtt,shifted_gps_time,'pchip','extrap');

% interpolate shifted twtt onto original gps time
out_twtt = interp1(shifted_gps_time,shifted_twtt,data.properties.gps_time,'pchip','extrap');

% construct the create param
createParam.properties.point_path_id = data.properties.point_path_id;
createParam.properties.username = authParam.properties.userName;
createParam.properties.twtt = out_twtt;
createParam.properties.type = data.properties.type;
createParam.properties.quality = data.properties.quality;
createParam.properties.lyr_name = param.properties.lyr_name;

% create the layer points
[status,message] = opsCreateLayerPoints(sys,createParam);
fprintf('%s\n',message);

end