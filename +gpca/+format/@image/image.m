classdef image < gpca.format.base
    
    properties
        fileformat = 'pgm'
        type       = 'single'
    end
    
    methods
        
        function obj = image(fileformat)
            if nargin > 0
                obj.fileformat = fileformat;
            end
        end
        
        function data  = read(obj,array,varargin)
            if ~ischar(array)
                error('Image format must be a path to an image file')
            end
            converter = str2func(obj.type);
            data      = converter(imread(array));
            if ~ isempty(varargin)
                numeric_format = gpca.format.numeric();
                data = numeric_format.read(data, varargin{:});
            end
        end
        
        function array = write(obj,array,value,varargin)
            if ~isempty(varargin)
                numeric_array  = obj.read(array);
                numeric_format = gpca.format.numeric();
                value = numeric_format.write(numeric_array, value, varargin{:});
                clear numeric_array
            end
            imwrite(value, array, obj.fileformat);
        end
        
        function n = numel(obj, array)
            n = prod(obj.size(array));
        end
        
        function lat = size(~, array)
            if ~ischar(array)
                error('Image format must be a path to an image file')
            end
            info = imfinfo(array);
            lat = [info.Height info.Width];
            if strcmpi(info.ColorType, 'truecolor')
                lat = [lat 3];
            end
        end
            
        function [type, is_complex] = class(~, array)
            if ~ischar(array)
                error('Image format must be a path to an image file')
            end
            info = imfinfo(array);
            type = ['uint' info.BitDepth];
            is_complex = false;
        end
        
        function array = allocate(obj, lat, prefix)
            array = fullfile(pwd, [prefix '.' obj.fileformat]);
            imwrite(zeros(lat, obj.type), array, obj.fileformat);
        end
        
        function array = like(obj, other, prefix)
            array = obj.allocate(gpca.format.size(other), prefix);
        end
        
    end
end

