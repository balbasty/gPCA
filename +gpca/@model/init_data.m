function obj = init_data(obj, X, Y)

    obj.data = struct;
    N        = numel(X);

    % Preprocess Y (class-encoding)
    if numel(Y) == 1
        if isnan(Y)
            Y = 1;
        end
        if Y > 1
            K = Y;
            Y = zeros(K,1);
        else
            K = 1;
        end
    else
        if size(Y,2) ~= 1 && size(Y,2) ~= N
            error('There should be as many observations in X and Y (%d ~= %d)', N, size(Y,2));
        end
        if size(Y,1) == 1
            K = max(Y);
            zero_indexing = (min(Y) == 0);
            if zero_indexing
                K = K + 1;
                Y = Y + 1;
            end
            iY = Y;
            Y = zeros(K,size(Y,2));
            for n=1:N
                if isfinite(iY(n))
                    Y(iY(n),n) = 1;
                end
            end
        end
    end
    
    % Prepare structure
    [obj.data(1:N).x]  = deal([]);
    [obj.data(1:N).y]  = deal([]);
    [obj.data(1:N).y_fixed] = deal([]);
    [obj.data(1:N).z]  = deal([]);
    [obj.data(1:N).zz] = deal([]);
    [obj.data(1:N).Az] = deal([]);

    % Copy each observed vector + class-indexing
    for n=1:N
        obj.data(n).x = X(n);
        if size(Y,2) > 1
            obj.data(n).y = Y(:,n);
        else
            obj.data(n).y = Y(:);
        end
        obj.data(n).y_fixed = any(obj.data(n).y);
    end
    obj.K = K;
end