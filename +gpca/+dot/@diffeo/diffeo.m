classdef diffeo < gpca.dot.field
% FORMAT dot_diffeo = gpca.dot.diffeo()
%
% Inner product between 3D volumes based on a a mixture of differential 
% energies (absolute, membrane, bending, linear-elastic) implemented using 
% finite differences.
%
% References:
% -----------
% - Ashburner J., "A Fast Diffeomorphic Registration Algorithm",
%   NeuroImage (2007).

    methods
        function obj = diffeo()
            if exist('spm_diffeo','file') ~= 3
                error('Cannot find spm_diffeo. Check that SPM is on the path')
            end
        end
        
        function x = solve(obj,x)
            spm_diffeo('boundary', obj.Boundary);
            converter = str2fun(class(x));
            x = spm_diffeo('vel2mom', full(single(x)), ...
                double([obj.VoxelSize obj.Absolute obj.Membrane obj.Bending]));
            x = converter(x);
        end
        
        function x = dot(obj,x,y)
            if numel(x) ~= numel(y)
                error('x and y must have the same number of elements')
            end
            spm_diffeo('boundary', obj.Boundary);
            converter = str2fun(class(x));
            x = spm_diffeo('vel2mom', full(single(x)), ...
                double([obj.VoxelSize obj.Absolute obj.Membrane obj.Bending]));
            x = converter(x);
            x = x(:)'*y(:);
        end
    end
end