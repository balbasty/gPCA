function nii_type = type_num2nii(type,is_complex)

    if nargin < 2
        is_complex = false;
    end
    switch lower(type)
        case 'logical'
            nii_type = 'binary';
        case 'uint8'
            nii_type = 'uint8';
        case 'uint16'
            nii_type = 'uint16';
        case 'uint32'
            nii_type = 'uint32';
        case 'uint64'
            nii_type = 'uint64';
        case 'int8'
            nii_type = 'int8';
        case 'int16'
            nii_type = 'int16';
        case 'int32'
            nii_type = 'int32';
        case 'int64'
            nii_type = 'int64';
        case 'single'
            if is_complex
                nii_type = 'complex64';
            else
                nii_type = 'float32';
            end
        case 'double'
            if is_complex
                nii_type = 'complex128';
            else
                nii_type = 'float64';
            end
        otherwise
            error('type %s not supported', type);
    end

end