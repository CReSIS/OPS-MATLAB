#OPS-MATLAB

MATLAB API for the OPS project. Included .m files provide MATLAB functions for interacting with the OPS database. Conversion functions are used for serializing and deserializing database responses. Input functions either add or remove data from the database. Output functions return commonly requested information from the database. Utility functions are maintenance or support related. The ops_sys_cmd.m script is a global parameter-setting file used in most functions. 

Below are brief descriptions of each function. 
Most functions take the following form:
```matlab
[status,data] = ops_function_name(sys,param)
```
Where:   
	+ status = an integer indicating the result of calling the function (0: Error, 1: success, 2: Warning)  
	+ data = a structure with fields containing returned information (specific to each function).  
	+ sys = a string indicating a particular radar system ('rds','accum', 'snow', etc.)  
	+ param = a structure with fields containing relevant parameters (specific to each function)   
Consult function help documentation for more information. 

##conversion
####fromjson.mexa64
.MEX file supporting JSON deserialization.
####fromjson.mexw64
.MEX file supporting JSON deserialization.
####json_response_decode.m
```matlab
[status,decoded_json] = json_response_decode(json_response)
```
Decodes a database JSON response. Formats all responses in fromjson() format.
####json_wrapper.m
```matlab
new_data = json_wrapper(data)
```
Wraps the loadjson() output to match fromjson()
####tojson.mexa64
.MEX file supporting JSON serialization.
####tojson.mexw64
.MEX file supporting JSON serialization.

##input
####ops_create_layer.m
```matlab
[status,data] = ops_create_layer(sys,param)
```
Adds a layer to the database or restores status to 'normal' if previously deleted. 
####ops_create_layer_points.m
```matlab
[status,data] = ops_create_layer_points(sys,param)
```
Adds layer points to the database. 
####ops_create_path.m
```matlab
[status,data] = ops_create_path(sys,param)
```
Adds a flight path to the database. 
####ops_delete_layer.m
```matlab
[status,data] = ops_delete_layer(sys,param)
```
Sets a layer's status from 'normal' to 'deleted.'
####ops_delete_layer_points.m
```matlab
[status,data] = ops_delete_layer_points(sys,param)
```
Removes selected layer points within a specified range from the database.

##output
####ops_get_closest_frame.m
```matlab
[status,data] = ops_get_closest_frame(sys,param)
```
Finds the closest frame to a given point in the database. 
####ops_get_closest_point.m
```matlab
[status,data] = ops_get_closest_point(sys,param)
```
Finds the closest point path to a given point from the database. 
####ops_get_crossover_error.m
```matlab
[status,data] = ops_get_crossover_error(sys,param)
```
Retrieves crossover errors from the database. 
####ops_get_layer_points.m
```matlab
[status,data] = ops_get_layer_points(sys,param)
```
Gets layer points from the database. 
####ops_get_layers.m
```matlab
[status,data] = ops_get_layers(sys,param)
```
Retrieves all layers for for a given system with 'normal' status from the database. 
####ops_get_path.m
```matlab
[status,data] = ops_get_path(sys,param)
```
Gets the points assoicated with a flight path from the database.
####ops_get_segment_info.m
```matlab
[status,data] = ops_get_segment_info(sys,param)
```
Retrieves information for a single segment from the database. 
####ops_get_system_info.m
```matlab
[status,data] = ops_get_system_info(sys,param)
```
Retrieves all systems, seasons, and locations from the database
####ops_search_frames.m
```matlab
[status,data] = ops_search_frames(sys,param)
```
Retrieves the closest frame based on a search string from the database. 
####run_ops_get_crossover_error.m
Wrapper for ops_get_crossover_error

##utility
####ops_analyze_tables.m
```matlab
[status,message] = ops_analyze_tables(sys,param)
```
Analyzes tables and updates database statistics.
####ops_bulk_delete.m
```matlab
[status,data] = ops_bulk_delete(sys,param)
```
Completely removes data from the database.
####ops_query.m
```matlab
[status,data] = ops_query(query)
```
Retrieves query results from the database.
####ops_update_season_status.m
Script that modifies the status for a season in the database ('public','private')
