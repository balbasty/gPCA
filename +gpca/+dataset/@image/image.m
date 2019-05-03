classdef image
    
    properties
        fname_list = {};
    end
    
    methods
        function obj = image(varargin)
            obj.fname_list = varargin;
        end
        
        function value = subsref(obj,S)
            S.type = '{}';
            value = subsref(obj.fname_list,S);
        end
        
        function obj = subsasgn(obj,S,value)
            S.type = '{}';
            obj.fname_list = subsref(obj.fname_list,S,value);
        end
        
        function lat = size(obj)
            lat = size(obj.fname_list);
        end
        
        function n = numel(obj)
            n = numel(obj.fname_list);
        end
    end
end

