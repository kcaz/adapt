function rcos_filt = raised_cosine(dims, taper_start, taper_end)
    rcos_filt = zeros(dims);
    center = floor(dims/2)+1;
    for row=1:dims(1)
        for col = 1:dims(2)
            dist = sqrt((row-center(1))^2+(col-center(2))^2);
            if dist < taper_start
                rcos_filt(row, col) = 1;
            elseif dist > taper_end
                rcos_filt(row, col) = 0;
            else
                rcos_filt(row, col) = 0.5*(1+cos( (dist - taper_start) / (taper_end - taper_start) * pi) );
            end
        end
    end
        
end