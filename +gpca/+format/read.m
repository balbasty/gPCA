function varargout = read(varargin)

    format = gpca.format.auto(varargin{1});
    [varargout{1:nargout}] = format.read(varargin{:});

end

