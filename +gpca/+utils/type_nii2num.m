function [num_type,is_complex] = type_nii2num(nii_type)

    is_complex = false;
    nii_type = strsplit(nii_type, '-');
    nii_type = nii_type{1};
    switch lower(nii_type)
        case 'binary'
            num_type = 'logical';
        case 'uint8'
            num_type = 'uint8';
        case 'uint16'
            num_type = 'uint16';
        case 'uint32'
            num_type = 'uint32';
        case 'uint64'
            num_type = 'uint64';
        case 'int8'
            num_type = 'int8';
        case 'int16'
            num_type = 'int16';
        case 'int32'
            num_type = 'int32';
        case 'int64'
            num_type = 'int64';
        case 'float32'
            num_type = 'single';
        case 'float64'
            num_type = 'double';
        case 'complex64'
            num_type = 'single';
            is_complex = true;
        case 'complex128'
            num_type = 'double';
            is_complex = true;
        otherwise
            error('type %s not supported', nii_type);
    end

end