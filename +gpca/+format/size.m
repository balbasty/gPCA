function varargout = size(varargin)

    format = gpca.format.auto(varargin{1});
    [varargout{1:nargout}] = format.size(varargin{:});

end
