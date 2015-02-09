function stair = get_stair(up, down, init, stimvals)
	state = 0;
	curr_val = init;
    
    function next_val = inner_stair(varargin)
        %up
        %down
        %init
        %stimvals
        %varargin{1}
		if numel(varargin)
			correct = varargin{1};
		else
			next_val = stimvals(curr_val);
			return;		
		end
		state = state * ((state < 0 && ~correct) || (state > 0 && correct)) + correct - (~correct);
		curr_val = max(1, min(numel(stimvals), curr_val + (state == -up) - (state == down)));
		state = state * ~(state == -up)	* ~(state == down);
		next_val = stimvals(curr_val);    
	end
    stair = @inner_stair;
end
