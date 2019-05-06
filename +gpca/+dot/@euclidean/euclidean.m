classdef euclidean < gpca.dot.base
% FORMAT dot = gpca.dot.euclidean()
%
% Euclidean inner product (dot)

    properties
        Lattice = 1
    end

    methods
        function obj = euclidean()
        end
        
        function x = solve(~,x)
        end
        
        function x = dot(~,x,y)
            x = x(:)'*y(:);
        end
        
        function ld = logdet(obj)
            ld = prod(obj.Lattice);
        end
    end
end