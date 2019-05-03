function obj = elbo_subspace(obj)

    D = prod(obj.lat);

    obj.lbU =   trace(obj.ULU + D * obj.iAu) ...
              + D * gpca.utils.logdetPD(obj.Au) ...
              - D * obj.M;
    obj.lbU = - 0.5 * obj.lbU;
          
end