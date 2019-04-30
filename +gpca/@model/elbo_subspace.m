function elbo_subspace(obj)

    D = prod(lat);

    obj.lbU = - 0.5 * trace(obj.ULU) ...
              - 0.5 * D * utils.gpca.logdetPD(obj.Au) ...
              + 0.5 * trace(obj.Au*obj.ULU);

end