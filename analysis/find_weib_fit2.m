%uses palamedes
function [p, ste_conv, conv_boots] = find_weib_fit2(xs, numpos, outof, boot)
    init = [0.1,3,0.5,0.01];
    free = [1,1,0,1];
    sd = 0;
    pboot = 0;
    p = PAL_PFML_Fit(xs,numpos,outof,init,free,@PAL_Weibull,'lapseLimits',[0,0.1]);    
    ste_conv = 0;
    conv_boots = 0;
    if boot
        [sd, pboot, llboot, converged] = PAL_PFML_BootstrapNonParametric(xs, numpos, outof, init, free, boot, @PAL_Weibull,'lapseLimits',[0,0.1]);
        conv_boots = pboot(converged, :);
        ste_conv = std(conv_boots)/sqrt(size(conv_boots, 1));
    end
    
end
