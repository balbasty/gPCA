classdef subspace < gpca.dot.base
% dot_subspace = gpca.dot.subspace()
%   Inner product based on a known covariance of the form U*U' + inv(lam*L). 
%   Such a covariance may have been learned beforehand by gPCA.

    properties
        Subspace                        % Principal subspace
        Precision = 1                   % Residual precision     [1]
        Dot       = gpca.dot.euclidean  % Subspace inner product [euclidean]
    end
    
    properties (Access = private)
        M      % Latent dimension
        ULU    % ULU(m,n) = dot(Um,Un)
        P      % P = inv(I/lam + ULU)
    end

    methods
        function obj = subspace(U,lam,dot)
        % dot_subspace = gpca.dot.subspace(Subspace,[Precision],[Dot])
        %   Constructs a dot product from a subspace-based covariance
        %   matrix.
        %
        %   Subspace  - Principal subspace
        %   Precision - Residual precision
        %   Dot       - Subspace inner product
            obj.Subspace = U;
            if nargin > 1
                obj.Precision = lam;
            end
            if nargin > 2
                obj.Dot = dot;
            end
            obj.computeM();
            obj.computeULU();
            obj.computeP();
        end
        
        function Lx = solve(obj,x)
        % Lx = obj.solve(x)
        %   Returns L*x, where L is the underlying precision matrix.
            
            % We use Woodbury's matrix identity to invert (UU'+inv(lam*L))
            Lx = obj.dot.solve(x);
            WLx = zeros(obj.M,1);
            for m=1:obj.M
                Um = gpca.format.read(obj.Subspace);
                WLx(m) = Um(:)' * Lx(:);
                clear Um
            end
            WLx = obj.P * WLx;
            for m=1:obj.M
                LUm = obj.dot.solve(gpca.format.read(obj.Subspace));
                Lx = Lx - WLx(m) * LUm;
                clear LUm
            end
            Lx = obj.Precision * Lx;
        end
        
        function y = dot(obj,x,y)
        % dot_xy = obj.dot(x,y)
        %   Returns the dot product of two "vectors"
            y = obj.solve(y);
            y = x(:)' * y(:);
        end
        
        function ld = logdet(obj)
        % ld = obj.logdet()
        %   Returns the log-determinant of the underlying precision matrix
            ld = NaN;
        end
    end
    
    methods
    % Setters that trigger pre-computation of useful values
    
        function set.Subspace(obj,U)
            obj.Subspace = U;
            obj.computeM();
            obj.computeULU();
            obj.computeP();
        end
        
        function set.Precision(obj,lam)
            obj.Precision = lam;
            obj.computeP();
        end
        
        function set.Dot(obj,dot)
            obj.Dot = dot;
            obj.computeULU();
            obj.computeP();
        end
    
    end
    
    methods (Access = private)
    % Methods that pre-compute useful values
        
        function computeULU(obj)
            obj.ULU = zeros();
            for m=1:obj.M
                Um       = gpca.format.read(obj.U, m);
                LUm      = obj.dot.solve(Um);
                obj.ULU(m,m) = double(LUm(:))' * double(Um(:));
                clear Um
                for p=(m+1):obj.M
                    Up       = gpca.format.read(obj.U, p);
                    obj.ULU(m,p) = double(LUm(:))' * double(Up(:));
                    obj.ULU(p,m) = obj.ULU(m,p);
                    clear Up
                end
                clear LUm
            end
        end
        
        function computeP(obj)
            obj.P = eye(obj.Dimension)/obj.Precision + obj.ULU;
            obj.P = gpca.utils.invPD(obj.P);
        end
        
        function computeM(obj)
            dim = gpca.format.size(obj.Subspace);
            obj.M = dim(end);
        end
        
    end
end