function [m,n] = subplot_tiling(plotnum)
    m = floor(sqrt(plotnum));
    n = floor(sqrt(plotnum));
    while(m*n<plotnum)
        n = n+1;
    end
end