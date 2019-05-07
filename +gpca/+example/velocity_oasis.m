%% ------------------------------------------------------------------------
%  Specify input/output folders

input_folder = '/scratch/shape/oasis/oasis_disc1';
output_folder = '.';

%% ------------------------------------------------------------------------
%  Build dataset

file_list = {};

sub = dir(input_folder);

for i=1:numel(sub)
    if sub(i).isdir
        if strcmpi(sub(i).name, '9')
            continue
        end
        subsub = dir(fullfile(input_folder, sub(i).name));
        for j=1:numel(subsub)
            if ~subsub(j).isdir ...
                    && numel(subsub(j).name) >= 4 ...
                    && strcmpi(subsub(j).name, 'velocity.nii')
                file_list{end+1} = fullfile(input_folder, sub(i).name, subsub(j).name);
            end
        end
    end
end

dataset = gpca.dataset.image(file_list{:});

%% ------------------------------------------------------------------------
%  Prepare model

gpca_model                   = gpca.model();        % Create model
gpca_model.verbose           = 2;                   % 1 = speak | 2 = plot
gpca_model.M                 = 5;                   % Nb of principal components            
gpca_model.parallel          = 15;                  % Nb of workers (inf = all)
gpca_model.nA0               = 20;                  % (prior) d.f. latent precision
gpca_model.nm0               = inf;                 % (prior) d.f. mean (inf = fixed)
gpca_model.nl0               = eps;                 % (prior) d.f. residual precision
gpca_model.dot               = gpca.dot.diffeo;     % Diffeo dot product
gpca_model.dot.Absolute      = 0;                   % prm(1)
gpca_model.dot.Membrane      = 0.001;               % prm(2)
gpca_model.dot.Bending       = 0.02;                % prm(3)
gpca_model.dot.LinearElastic = [0.0025 0.005];      % prm([4 5])
gpca_model.dot.Boundary      = 0;                   % 0 = circulant | 1 = neumann

%% ------------------------------------------------------------------------
%  Fit model

trained_model = gpca_model.train(dataset);