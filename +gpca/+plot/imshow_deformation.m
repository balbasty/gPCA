function h = imshow_deformation(d, vs, z, slice, nrm)

    dim = size(d);
    if numel(dim) > 4
        dim = [dim(1:3) dim(end)];
        d   = reshape(d, dim);
    end

    if nargin < 5
        nrm = nan;
        if nargin < 4
            slice = 3;
        end
    end
    dim = [size(d) 1 1 1];
    if numel(size(d)) == 5
        d = reshape(d, [dim(1:3) dim(5)]);
    end
    dim = [size(d) 1 1];
    if numel(size(d)) == 3
        d = reshape(ensure_numeric(d),  [dim(1) dim(2) 1 dim(3)]);
        d(:,:,:,3) = 0;
        dim = [size(d) 1 1];
    end
    if nargin < 3 || ~isfinite(z)
        switch slice
            case {2,3}
                z = ceil(dim(slice)/2);
            case 1
                z = ceil(dim(slice)/3);
        end
    end
    if nargin < 2
        vs = [1 1 1];
    end
    if size(vs,1) == 4 && size(vs,2) == 4
        vs = sqrt(sum(vs(1:3,1:3).^2));
    end
    switch slice
        case 1
            d = reshape(defToColor(d(z,:,:,:), nrm), [dim(2) dim(3) dim(4)]);
        case 2
            d = reshape(defToColor(d(:,z,:,:), nrm), [dim(1) dim(3) dim(4)]);
        case 3
            d = reshape(defToColor(d(:,:,z,:), nrm), [dim(1) dim(2) dim(4)]);
        otherwise
            error('not handled')
    end
    d = permute(d, [2 1 3]);
    asp = 1./[vs(2) vs(1) 1];
    h = image(d(end:-1:1,:,:));
    daspect(asp);
    axis off

end