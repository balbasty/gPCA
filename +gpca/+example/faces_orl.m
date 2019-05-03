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

dataset = gpca.dataset.image(file_list{:});

%% Prepare model

gpca_model = gpca.model();
gpca_model.verbose = 2;
gpca_model.M = 20;
gpca_model.parallel = 15;
gpca_model.nA0 = 20;
gpca_model.nm0 = eps;
gpca_model.nl0 = eps;
% gpca_model.dot = gpca.dot.field;
% gpca_model.dot.Bending  = 0;
% gpca_model.dot.Membrane = 1;

%% Fit model

trained_model = gpca_model.train(dataset);