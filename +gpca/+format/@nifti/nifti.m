classdef nifti < gpca.format.base
    
    methods
        function obj = numeric()
        end
        
        function data = read(~,array,index,dimension)
            if ischar(array)
                array = nifti(array);
            end
            if isa(array, 'nifti')
                array = array.dat;
            end
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
            array0 = array;
            if ischar(array)
                array = nifti(array);
            end
            if isa(array, 'nifti')
                array = array.dat;
            end
            if nargin < 5
                dimension = numel(size(array));
                if nargin < 4
                    index = inf;
                else
                    foo = 0;
                end
            end
            numdim = max(dimension,numel(size(array)));
            if ~isfinite(index)
                array = value;
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
            array = array0;
        end
        
        function n = numel(~, array)
            if ischar(array)
                array = nifti(array);
            end
            if isa(array, 'nifti')
                array = array.dat;
            end
            n = prod(size(array));
        end
            
        function lat = size(~, array)
            if ischar(array)
                array = nifti(array);
            end
            if isa(array, 'nifti')
                array = array.dat;
            end
            lat = size(array);
        end
        
        function array = allocate(obj, lat, ~)
            array = zeros(lat, obj.type);
        end
        
        function array = like(obj, other, ~)
            array = obj.allocate(size(other));
        end
    end
end

