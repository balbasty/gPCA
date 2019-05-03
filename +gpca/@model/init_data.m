function obj = init_data(obj, dataset)

    obj.data = struct;
    N        = numel(dataset);

    [obj.data(1:N).x]  = deal([]);
    [obj.data(1:N).z]  = deal([]);
    [obj.data(1:N).zz] = deal([]);
    [obj.data(1:N).Az] = deal([]);

    for n=1:N
        obj.data(n).x = dataset(n);
    end
    
end