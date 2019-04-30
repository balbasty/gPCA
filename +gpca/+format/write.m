function varargout = write(varargin)

    format = gpca.format.auto(varargin{1});
    [varargout{1:nargout}] = format.write(varargin{:});

end
