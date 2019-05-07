classdef model < handle
    
    properties
    % Model hyper-parameters
        dot         = gpca.dot.euclidean(); % Dot product (< gpca.dot.base)
        M           = Inf; % Number of principal components
        lat         = [];  % Lattice dimensions
        A0          = 1;   % Prior expected latent precision
        nA0         = 0;   % Prior df latent precision
        lam0        = 1;   % Prior expected residual precision
        nl0         = 0;   % Prior df residual precision
        mu0         = 0;   % Prior expected mean
        nm0         = 0;   % Prior df mean
        U0          = 0;   % Initial subspace
    end
    
    properties
    % Implementation parameters
        iter_min    = 1;    % Minimum number of iterations
        iter_max    = 40;   % Maximum number of iterations
        tolerance   = 1E-4; % Tolerance (stop if gain is lower)
        verbose     = 0;    % Verbosity (0 = quiet | 1 = print | 2 = plot)
        parallel    = Inf;  % Number of parallel workers
        format      = gpca.format.numeric();
    end
    
    properties % (Hidden, Access = private)
    % Model learnt posteriors
        U      = []   % Principal subspace (E[] 1st moment)
        ULU    = []   % Principal subspace (E[] 2nd moment)
        Au     = []   % Principal subspace (precision)
        iAu    = []   % Principal subspace (covariance)
        A      = []   % Latent precision (E[] 1st moment)
        logA   = NaN; % Latent precision (E[] log det)
        nA     = NaN  % Latent precision (df)
        lam    = NaN  % Residual precision (E[] 1st moment)
        loglam = NaN; % Residual precision (E[] log)
        nl     = NaN  % Residual precision (df)
        mu     = []   % mean (E[] 1st moment)
        nm     = NaN  % mean (df)
        lbU    = NaN; % EKL/ELL of principal subspace
        lbA    = NaN; % EKL/ELL of latent precision
        lbl    = NaN; % EKL/ELL of residual precision
        lbm    = NaN; % EKL/ELL of mean
    end
    
    properties % (Hidden, Access = private)
    % Temporary variables (for fit/apply)
        data  = []   % Sliceable object with subject-specific data
        Z     = []   % Latent cordinates (1st moment) 
        ZZ    = []   % Latent cordinates (2nd moment)
        Az    = []   % Posterior precision (shared between subjects)
        iAz   = []   % Inverse of Az
        lbX   = NaN  % ELL of data term
        lbZ   = NaN  % EKL of latent coordinates
        elbo  = []   % Evidence Lower BOund
        elbo_parts = struct;
        gain  = NaN  % ELBO gain between two iterations
        track = struct('X',  [], 'Z',   [], 'U',  [], ...
                       'A',  [], 'lam', [], 'mu', [], 'elbo', [])
        Z_iscentred = false
    end
    
    methods (Access = public)
        function obj = model()
        end
        
        obj = set_parameters(varargin)
        mod = get_model(obj)
        obj = set_model(obj, mod)
        
        function output = train(obj,dataset) % Fit the full model    (subj+pop)
            obj.init_data(dataset);
            if ~isfinite(obj.M) || obj.M > numel(obj.data)
                obj.M = numel(obj.data) - 1;
            end
            obj.lat = gpca.format.size(obj.data(1).x);
%             try
                obj.train_internal();
%             catch ME
%                 obj.cleanup_data();
%                 ME.throw();
%             end
            output = obj.create_output();
            obj.cleanup_data();
        end
        
        function output = apply(obj,dataset) % Fit the trained model (subj)
            obj.init_data(dataset);
            datalat = gpca.format.size(obj.data(1).x);
            if ~issame(datalat, obj.lat)
                error('Model and Data lattices are not compatible')
            end
            try
                obj.apply_internal();
            catch ME
                obj.cleanup_data();
                ME.throw();
            end
            output = obj.create_output();
            obj.cleanup_data();
        end
        
    end
    
    methods (Access = private)
        
        obj  = train_internal(obj)                 % done
        obj  = apply_internal(obj)                 % done
        
        obj  = init_data(obj,dataset)              % done
        
        obj  = plot(obj, do_plot)                  % done
        
        obj  = init_model(obj)                     % done
        obj  = init_latent(obj)                    % done
        obj  = init_elbo_parts(obj)                % done
        
        obj  = update_latent(obj)                  % done
        data = update_latent_one(obj,data)         % done
        obj  = update_population(obj)              % done
        obj  = update_subspace(obj)                % done
        obj  = update_mean(obj)                    % done
        obj  = update_latent_precision(obj)        % done
        obj  = update_residual_precision(obj)      % done
        
        obj  = centre_latent(obj)                  % done
        
        obj  = elbo_subspace(obj)                  % done
        obj  = elbo_mean(obj)                      % done
        obj  = elbo_latent_precision(obj)          % done
        obj  = elbo_residual_precision(obj)        % done
        obj  = elbo_latent(obj)                    % done
        obj  = elbo_obs(obj)                       % done
        
                
        function obj = cleanup_data(obj)
            obj.data = [];
            obj.Z    = [];
            obj.ZZ   = [];
            obj.Az   = [];
            obj.iAz  = [];
            obj.lbX  = NaN;
            obj.lbZ  = NaN;
            obj.elbo = [];
            obj.elbo_parts = struct;
            obj.gain = NaN;
            obj.track = struct('X', [], 'Z',   [], 'U',  [], ...
                               'A', [], 'lam', [], 'mu', [], 'elbo', []);
            obj.Z_iscentred = false;
        end
        
        function out = create_output(obj)
            out           = struct;
            out.data      = obj.data;
            out.latent.Z  = obj.Z;
            out.latent.ZZ = obj.ZZ;
            out.latent.A  = obj.Az;
            out.elbo.X    = obj.lbX;
            out.elbo.Z    = obj.lbZ;
            out.elbo.all  = obj.elbo;
        end
        
    end
    
end