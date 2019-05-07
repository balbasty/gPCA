%% Specify input/output folders

input_folder = '/scratch/faces/ORL';
output_folder = '.';

%% Build dataset

file_list = {};

sub = dir(input_folder);

for i=1:numel(sub)
    if sub(i).isdir
        subsub = dir(fullfile(input_folder, sub(i).name));
        for j=1:numel(subsub)
            if ~subsub(j).isdir ...
                    && numel(subsub(j).name) >= 4 ...
                    && strcmpi(subsub(j).name(end-3:end), '.pgm')
                file_list{end+1} = fullfile(input_folder, sub(i).name, subsub(j).name);
            end
        end
    end
end

dataset = gpca.dataset.image(file_list{1:10:end});

%% Prepare model

gpca_model                   = gpca.model();        % Create model
gpca_model.verbose           = 2;                   % 1 = speak | 2 = plot
gpca_model.M                 = 20;                  % Nb of principal components            
gpca_model.parallel          = 15;                  % Nb of workers (inf = all)
gpca_model.nA0               = 20;                  % (prior) d.f. latent precision
gpca_model.nm0               = eps;                 % (prior) d.f. mean (inf = fixed)
gpca_model.nl0               = eps;                 % (prior) d.f. residual precision
gpca_model.dot               = gpca.dot.field;      % Fielddot product
gpca_model.dot.Absolute      = 0;                   % prm(1)
gpca_model.dot.Membrane      = 1;                   % prm(2)
gpca_model.dot.Bending       = 0;                   % prm(3)
gpca_model.dot.Boundary      = 1;                   % 0 = circulant | 1 = neumann

%% Fit model

trained_model = gpca_model.train(dataset);