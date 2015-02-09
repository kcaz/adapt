function fcross = fixation_cross(dims)
	fcross = 128*ones(dims);
	fcross(:, round(dims(2)/2)) = 255;
	fcross(round(dims(1)/2), :) = 255;

	fcross(:, round(dims(2)/2)+1) = 255;
	fcross(round(dims(1)/2)+1, :) = 255;

	fcross(:, round(dims(2)/2)-1) = 255;
	fcross(round(dims(1)/2)-1, :) = 255;
end
