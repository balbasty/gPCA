function obj = elbo_latent(obj)

    N = numel(obj.data);
    obj.lbZ =   trace(obj.A * (obj.ZZ/N + obj.iAz)) ...
              + gpca.utils.logdetPD(obj.Az) ...
              - obj.logA ...
              - obj.M;
    obj.lbZ = - 0.5 * N * obj.lbZ;
    
end