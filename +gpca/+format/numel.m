function varargout = numel(varargin)

    format = gpca.format.auto(varargin{1});
    [varargout{1:nargout}] = format.numel(varargin{:});

end

