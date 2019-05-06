classdef numeric < gpca.format.base
    
    properties
        type = 'single';
    end
    
    methods
        function obj = numeric(type)
            if nargin > 0
                obj.type = type;
            end
        end
        
        function data = read(~,array,index,dimension)
            if nargin < 4
                dimension = numel(size(array));
                if nargin < 3
                    index = inf;
                end
            end
            lat = size(array);
            if isfinite(index) && index > lat(dimension)
                index = lat(dimension);
            end
            numdim = max(dimension,numel(size(array)));
            if ~isfinite(index)
                data = array();
            else
                S = struct;
                S.type = '()';
                S.subs = num2cell(repmat(':', [1 numdim]));
                S.subs{dimension} = index;
                data = subsref(array, S);
            end
        end
        
        function array = write(obj,array,value,index,dimension)
            if nargin < 5
                dimension = numel(size(array));
                if nargin < 4
                    index = inf;
                end
            end
            numdim = max(dimension,numel(size(array)));
            if ~isfinite(index)
                converter = str2func(obj.type);
                array = converter(value);
            else
                lat = size(array);
                lat = padarray(lat, [0 max(0,numel(lat)-dimension)], 1, 'post');
                lat(dimension) = 1;
                S = struct;
                S.type = '()';
                S.subs = num2cell(repmat(':', [1 numdim]));
                S.subs{dimension} = index;
%                 array = subsasgn(array, S, reshape(value, lat));
                array = subsasgn(array, S, value);
            end
        end
        
        function n = numel(~, array)
            n = numel(array);
        end
            
        function lat = size(~, array)
            lat = size(array);
        end
        
        function [type,is_complex] = class(~,array)
            type = class(array);
            is_complex = ~isreal(array);
        end
        
        function array = allocate(obj, lat, ~)
            array = zeros(lat, obj.type);
        end
        
        function array = like(obj, other, ~)
            array = obj.allocate(size(other));
        end
    end
end

