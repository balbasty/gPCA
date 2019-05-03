classdef field % < gpca.dot.base
% FORMAT dot_field = gpca.dot.field()
%
% Inner product between 3D volumes based on a a mixture of differential 
% energies (absolute, membrane, bending) implemented using finite
% differences.
%
% References:
% -----------
% - Ashburner J., "A Fast Diffeomorphic Registration Algorithm",
%   NeuroImage (2007).

    properties
        Absolute   = 0
        Membrane   = 0
        Bending    = 1
        VoxelSize  = [1 1 1]
        Boundary   = 1;
    end

    methods
        function obj = field()
            if exist('spm_field','file') ~= 3
                error('Cannot find spm_field. Check that SPM is on the path')
            end
        end
        
        function x = solve(obj,x)
            spm_field('boundary', obj.Boundary);
            converter = str2func(class(x));
            x = spm_field('vel2mom', full(single(x)), ...
                double([obj.VoxelSize obj.Absolute obj.Membrane obj.Bending]));
%             x = converter(x);
        end
        
        function x = dot(obj,x,y)
            if numel(x) ~= numel(y)
                error('x and y must have the same number of elements')
            end
            spm_field('boundary', obj.Boundary);
            converter = str2func(class(x));
            x = spm_field('vel2mom', full(single(x)), ...
                double([obj.VoxelSize obj.Absolute obj.Membrane obj.Bending]));
%             x = converter(x);
            x = x(:)'*y(:);
        end
        
        function ld = logdet(obj)
            ld = NaN;
        end
    end
end