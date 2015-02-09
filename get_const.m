function stair = get_const(stimvals, repeats)
	state = 0;
    stimvals = repmat(stimvals, 1, repeats);
    stimvals = stimvals(randperm(numel(stimvals)));
    function next_val = inner_stair(varargin)
		state = 1+mod(state, numel(stimvals));
        next_val = stimvals(state); 
	end
    stair = @inner_stair;
end
