classdef nifti < gpca.format.base
    
    methods
        function obj = nifti()
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
                index = ':';
            end
%             lat = size(array);
%             lat = padarray(lat, [0 max(0,numel(lat)-dimension)], 1, 'post');
%             lat(dimension) = 1;
            S = struct;
            S.type = '()';
            S.subs = num2cell(repmat(':', [1 numdim]));
            S.subs{dimension} = index;
%                 array = subsasgn(array, S, reshape(value, lat));
            array = subsasgn(array, S, value);
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
        
        function [type, is_complex] = class(obj, array)
            if ischar(array)
                array = nifti(array);
            end
            if isa(array, 'nifti')
                array = array.dat;
            end
            [type, is_complex] = gpca.utils.type_nii2num(array.dtype);
        end
        
        function array = allocate(obj, lat, prefix, type, is_complex)
            if nargin < 4 || isempty(type)
                type = 'single';
            end
            if nargin < 5
                is_complex = false;
            end
            nii_type = gpca.utils.type_num2nii(type, is_complex);
            fname = fullfile(pwd, [prefix '.nii']);
            fa = file_array(fname, lat, nii_type);
            nii = nifti;
            nii.dat = fa;
            nii.descrip = prefix;
            create(nii);
            initialise(nii.dat);
            dim = size(nii.dat);
            for z=1:dim(end)
                nii.dat = gpca.format.write(nii.dat, 0, z, numel(dim));
            end
            array = nii;
        end
        
        function array = like(obj, other, prefix)
            [type, is_complex] = gpca.format.class(other);
            array = obj.allocate(size(other), prefix, type, is_complex);
        end
    end
end

