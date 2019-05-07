function h = imshow_mri(f, vs, z, slice, palette, scale)

    if nargin < 5
        palette = 'gray';
    end
    if ischar(palette)
        palette = str2func(palette);
    end
    if isa(palette, 'function_handle')
        palette = palette(2^10);
    end
    if nargin < 4
        slice = 3;
    end
    dim = [size(f) 1 1];
    if nargin < 3 || ~isfinite(z)
        switch slice
            case {2,3}
                z = ceil(dim(slice)/2);
            case 1
                z = ceil(dim(slice)/2); % 3
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
            f = reshape(f(z,:,:,:), [dim(2) dim(3) dim(4)]);
        case 2
            f = reshape(f(:,z,:,:), [dim(1) dim(3) dim(4)]);
        case 3
            f = reshape(f(:,:,z,:), [dim(1) dim(2) dim(4)]);
        otherwise
            error('not handled')
    end
    
    if nargin < 6
        scale = [min(f(:)) max(f(:))];
    end
    f = round((f-scale(1))/(scale(2)-scale(1))*size(palette,1)+1);
    f = ind2rgb(f, palette);
%     if dim(4) > 1
%         f = reshape(f, [dim(1:2) dim(4)]);
%     end
%     f = permute(f, [2 1 3]);
%     asp = 1./[vs(2) vs(1) 1];
%     h = imagesc(f(end:-1:1,:,:));
    asp = 1./[vs(1) vs(2) 1];
    h = imagesc(f);
    colormap(palette)
    daspect(asp);
    axis off

end