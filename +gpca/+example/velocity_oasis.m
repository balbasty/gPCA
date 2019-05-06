%% Specify input/output folders

input_folder = '/scratch/shape/oasis/oasis_disc1';
output_folder = '.';

%% Build dataset

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

%% Prepare model

gpca_model = gpca.model();
gpca_model.verbose = 2;
gpca_model.M = 5;
gpca_model.parallel = 15;
gpca_model.nA0 = 20;
gpca_model.nm0 = inf;
gpca_model.nl0 = eps;
% gpca_model.dot = gpca.dot.diffeo;
% gpca_model.dot.Absolute      = 0;
% gpca_model.dot.Membrane      = 0.001;
% gpca_model.dot.Bending       = 0.02;
% gpca_model.dot.LinearElastic = [0.0025 0.005];
% gpca_model.dot.Boundary      = 0;
gpca_model.format = gpca.format.nifti;

%% Fit model

[Z,fit] = gpca_model.fit_transform(dataset);