function format = auto(object)

    switch class(object)
        case 'nifti'
            format = gpca.format.nifti();
        otherwise
            try
                format = gpca.format.numeric(class(object));
            catch
                warning('format %s unsuppported, using single instead', class(object));
                format = gpca.format.single(class(object));
            end
    end

end

