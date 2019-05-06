classdef (Abstract) base < handle
% gpca.dot.base
%   Abstract base class for dot products of the form <x,y> = x'*L*y
%   Dot products are handle classes that must implement the methods
%   `solve`, `dot` and `logdet`.
    
    methods (Abstract)
        
        x  = solve(obj,x)
        % y = obj.solve(x)
        %   Compute L*x
        
        d  = dot(obj,x,y)
        % d = obj.dot(x,y)
        %   Compute x'*L*y
        
        ld = logdet(obj)
        % ld = obj.logdet()
        %   Compute log(det(L))
        
    end
end

