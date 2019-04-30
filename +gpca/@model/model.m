classdef model
    
    properties
    % Model hyper-parameters
        dot         = gpca.dot.euclidean(); % Dot product (< gpca.dot.base)
        M           = Inf; % Number of principal components
        lat         = [];  % Lattice dimensions
        Az0         = 1;   % Prior expected latent precision
        nz0         = 0;   % Prior df latent precision
        lam0        = 1;   % Prior expected residual precision
        nl0         = 0;   % Prior df residual precision
        mu0         = 0;   % Prior expected mean
        nm0         = 0;   % Prior df mean
        U0          = 0;   % Prior subspace
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
    
    properties
    % Model learnt posteriors
        U    = []   % Principal subspace (E[] 1st moment)
        ULU  = []   % Principal subspace (E[] 2nd moment)
        Au   = []   % Principal subspace (precision)
        Az   = []   % Latent precision (E[] 1st moment)
        nz   = []   % Latent precision (df)
        lam  = []   % Residual precision (E[] 1st moment)
        nl   = []   % Residual precision (df)
        mu   = []   % mean (E[] 1st moment)
        trLM = []   % mean (E[] 2nd moment) Tr(L*E[mu*mu'])
        nm   = []   % mean (df)
        lbU  = NaN; % EKL/ELL of principal subspace
        lbAz = NaN; % EKL/ELL of latent precision
        lbl  = NaN; % EKL/ELL of residual precision
        lbm  = NaN; % EKL/ELL of mean
    end
    
    properties (Hidden, Access = private)
    % Temporary variables (for fit/apply)
        data = []   % Sliceable object with subject-specific data
        Z    = []   % Latent cordinates (1st moment) 
        ZZ   = []   % Latent cordinates (2nd moment)
        A    = []   % Posterior precision (shared between subjects)
        trLS = NaN; % Tr(L*X*X')
        lbX  = NaN; % ELL of data term
        lbZ  = NaN; % EKL of latent coordinates
    end
    
    methods (Access = public)
        function obj = model()
        end
        
        set_parameters(varargin);
        
        function output = train(obj,dataset) % Fit the full model    (subj+pop)
            
            obj.init_data(dataset);
            
            try
                obj.train_internal();
            catch ME
                obj.cleanup_data();
                ME.throw();
            end
            
            output = obj.create_output();
            obj.cleanup_data();
            
        end
        
        function output = apply(obj,dataset) % Fit the trained model (subj)
            
            obj.init_data(dataset);
            
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
        
        train_internal(obj)                 % done
        apply_internal(obj)                 % done
        
        init_data(obj)
        cleanup_data(obj)
        create_output(obj)
        
        plot(obj)
        
        init_model(obj)                     % done
        init_latent(obj)                    % done
        
        update_all_subjects(obj)            % done
        data = update_subject(obj,data)     % done
        update_population(obj)              % done
        update_subspace(obj)                % done
        update_mean(obj)                    % done
        update_latent_precision(obj)        % done
        update_residual_precision(obj)      % done
        
        elbo_subspace(obj)                  % done
        elbo_mean(obj)                      % done
        elbo_latent_precision(obj)          % done
        elbo_residual_precision(obj)        % done
        elbo_latent(obj)                    % done
        elbo_obs(obj)                       % done
    end
    
end