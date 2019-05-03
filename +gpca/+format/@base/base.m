classdef (Abstract) base
    
    methods
        
        data  = read(obj,array,index,dimension)
        array = write(obj,array,value,index,dimension)
        n     = numel(obj, array)
        lat   = size(obj, array)
        array = allocate(obj, lat, prefix)
        array = like(obj, other, prefix)
        
    end
    
end

