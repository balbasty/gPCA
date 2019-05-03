function format = auto(object)

    switch class(object)
        
        case 'nifti'
            format = gpca.format.nifti();
            
        case 'char'
            % get extension (and remove leading period)
            [~,~,ext] = fileparts(object);
            ext = ext(2:end);
            % build list of extensions that work with imread/imwrite
            image_ext = {};
            info = imformats;
            for n=1:numel(info)
                image_ext = [image_ext info.ext];
            end
            % if match, use image format
            if any(strcmpi(ext, image_ext))
                format = gpca.format.image(ext);
            else
                error('file format %s unsuppported', ext);
            end
            
        otherwise
            try
                format = gpca.format.numeric(class(object));
            catch
                warning('format %s unsuppported, using single instead', class(object));
                format = gpca.format.single(class(object));
            end
    end

end

