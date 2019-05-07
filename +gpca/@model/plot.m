function obj = plot(obj)

    if obj.verbose < 2
        return
    end
    
    f = findobj('Type', 'Figure', 'Name', 'gPCA');
    if isempty(f)
        f = figure('Name', 'gPCA', 'NumberTitle', 'off');
    end
    set(0, 'CurrentFigure', f);   
    clf(f);
    
    nrow = 4;
    ncol = 3;
    i    = 1;
    
    % ----
    % mean
    % ----
    if numel(gpca.format.read(obj.mu)) > 1
        subplot(nrow,ncol,i);
    %     imagesc(gpca.format.read(obj.mu));
        imshow_deformation(gpca.format.read(obj.mu));
        colormap(gray());
        axis off
        title('E[\mu]')
    end
    i = i+1;

    % ---
    % PC1
    % ---
    subplot(nrow,ncol,i);
%     imagesc(gpca.format.read(obj.U,1));
    imshow_deformation(gpca.format.read(obj.U,1));
    colormap(gray());
    axis off
    title('E[u_1]')
    i = i+1;
    
    % ---
    % PC2
    % ---
    subplot(nrow,ncol,i);
%     imagesc(gpca.format.read(obj.U,2));
    imshow_deformation(gpca.format.read(obj.U,2));
    colormap(gray());
    axis off
    title('E[u_2]')
    i = i+1;
    
    elbo = 0;
    
    % ---------
    % ELBO: obs
    % ---------
    subplot(nrow,ncol,i);
    obj.track.X = [obj.track.X obj.lbX];
    elbo = elbo + obj.lbX;
    p = plot(obj.track.X);
    set(p.Parent,'xtick',[]);
    title('E[log p(X | .)]')
    i = i+1;
    
    % ------------
    % ELBO: latent
    % ------------
    subplot(nrow,ncol,i);
    obj.track.Z = [obj.track.Z obj.lbZ];
    elbo = elbo + obj.lbZ;
    p = plot(obj.track.Z);
    set(p.Parent,'xtick',[]);
    title('-E[KL(Z)]')
    i = i+1;
    
    % --------------
    % ELBO: subspace
    % --------------
    subplot(nrow,ncol,i);
    obj.track.U = [obj.track.U obj.lbU];
    elbo = elbo + obj.lbU;
    p = plot(obj.track.U);
    set(p.Parent,'xtick',[]);
    title('-E[KL(U)]')
    i = i+1;
    
    % ----------------------
    % ELBO: latent precision
    % ----------------------
    if obj.nA0 > 0
        subplot(nrow,ncol,i);
        obj.track.A = [obj.track.A obj.lbA];
        elbo = elbo + obj.lbA;
        p = plot(obj.track.A);
        set(p.Parent,'xtick',[]);
        title('-E[KL(A)]')
    end
    i = i+1;
    
    % ------------------------
    % ELBO: residual precision
    % ------------------------
    if obj.nl0 > 0
        subplot(nrow,ncol,i);
        obj.track.lam = [obj.track.lam obj.lbl];
        elbo = elbo + obj.lbl;
        p = plot(obj.track.lam);
        set(p.Parent,'xtick',[]);
        title('-E[KL(\lambda)]')
    end
    i = i+1;
    
    % ----------
    % ELBO: mean
    % ----------
    if obj.nm0 > 0
        subplot(nrow,ncol,i);
        obj.track.mu = [obj.track.mu obj.lbm];
        elbo = elbo + obj.lbm;
        p = plot(obj.track.mu);
        set(p.Parent,'xtick',[]);
        title('-E[KL(\mu)]')
    end
    i = i+1;
    
    % ----------
    % ELBO: all
    % ----------
    subplot(nrow,ncol,i);
    obj.track.elbo = [obj.track.elbo elbo];
    p = plot(obj.track.elbo);
    set(p.Parent,'xtick',[]);
    title('ELBO')
    i = i+1;
    
    % ----
    % U'LU
    % ----
    subplot(nrow,ncol,i);
    p = imagesc(obj.ULU + prod(obj.lat) * obj.iAu);
    title('E[U''LU]')
    colorbar
    i = i+1;
    
    % -
    % A
    % -
    subplot(nrow,ncol,i);
    p = imagesc(obj.A);
    title('E[A]')
    colorbar
    i = i+1;
    
    drawnow
    
    if numel(obj.track.elbo) > 1
        if obj.track.elbo(end) < obj.track.elbo(end-1)
            foo = 0;
        end
    end
    
end