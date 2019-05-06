function obj = init_label(obj)

    Y = zeros(obj.K, numel(obj.data));
    
    data     = obj.data;
    obj.data = [];
    parfor(n=1:numel(data), obj.parallel)
        data1    = data(n);
        if ~data1.y_fixed
            data1.y(:) = 1/obj.K;
        end
        Y(:,n) = data1.y;
        data(n)  = data1;
    end
    obj.data = data;

    obj.Y   = Y;
    
end