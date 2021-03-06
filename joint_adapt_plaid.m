function joint_adapt_plaid(initials, plaid)
    data_dir = ['Data/',initials];
    %first, make sure that the parameter file is up to date
    run([data_dir,'/params_',initials,'.m'])
    params_dir = [data_dir, '/', 'p'];
    load(params_dir) %loads a struct called p
    
    init_mgl(p.screen);
    data.start_time = mglGetSecs();%creates a data
    
    p.plaid = plaid;
    p.data_dir = data_dir;
    data.p = p; %save the parameters
    
    %set up staircases
    stair1 = get_stair(1,3,round(numel(p.contrasts)),p.contrasts);
    stair2 = get_stair(1,2,1,p.contrasts);
    stair3 = get_const(p.contrasts, p.trials_per_cond);


    conditions = [];%stair x side
    for side = [1,2]
        for st = [0,1,2]
            conditions = [[st ; side], conditions];        
        end
    end
    conditions = repmat(conditions, 1, p.trials_per_cond);
    rcos_mask = raised_cosine(p.sizeimg, p.stim_rad, p.stim_rad+p.stim_ramp);     

    %fixation cross textures
    fcr_tex = mglCreateTexture(p.fcross_red);
	fcg_tex = mglCreateTexture(p.fcross_green);
    fcw_tex = mglCreateTexture(p.fcross_white);


    correct = [];
    contrast = [];
    response = [];
    stimside = [];

    run_adapter(p.pre_adapt_switches, p, rcos_mask);
    mglClearScreen; mglFlush; mglWaitSecs(p.top_up_gap);

    for trial = 1:size(conditions, 2)
        run_adapter(p.top_up_switches, p, rcos_mask);
        mglClearScreen; mglFlush;
        mglWaitSecs(p.top_up_gap);
        

        st = conditions(1, trial);
        side = conditions(2, trial);

        %query staircases for current contrast
        if st == 0
            contr = stair1();
        elseif st == 1
            contr = stair2();
        elseif st == 2
            contr = stair3();
        end

        %randomly assign orientations
        if round(rand)
            ori1 = p.ori;
            ori2 = -p.ori;
        else
            ori2 = p.ori;
            ori1 = -p.ori;
        end

        ori1_grating = mksinewave(1.0, p.sf, ori1, 360*rand, p.screen.pixperdegree, p.sizeimg);
        ori2_grating = mksinewave(1.0, p.sf, ori2, 360*rand, p.screen.pixperdegree, p.sizeimg);
        present_stim = rcos_mask .* ((p.base_contrast + contr) * ori1_grating + p.mask_contrast * ori2_grating);
        absent_stim  = rcos_mask .* ((p.base_contrast +     0) * ori1_grating + p.mask_contrast * ori2_grating);
    
        tex_pr = mglCreateTexture(round(128 + 127*present_stim));
        tex_ab = mglCreateTexture(round(128 + 127* absent_stim));
        mglClearScreen;
        if side == 1
            mglBltTexture(tex_pr, p.left);
            mglBltTexture(tex_ab, p.right);        
        elseif side == 2
            mglBltTexture(tex_pr, p.right);
            mglBltTexture(tex_ab, p.left);        
        end
        mglFlush;
        mglWaitSecs(p.stim_duration);
        mglClearScreen; mglBltTexture(fcw_tex, p.center); mglFlush;
        
        %now get feedback
        k = [];
        while ~any(k)
            k = mglGetKeys(p.keys);
            resp = find(k, 1);
        end
        k
        if resp==3
            mglClose();
            break;
        end
        contrast = [contrast, contr];
        response = [response resp-1];
        stimside = [stimside, side];
        corr = side == resp;
        correct = [correct corr];        
        %update staircases
        if st==0
            stair1(corr);
        elseif st==1
            stair2(corr);
        end

        %give feedback, then wait post_gap seconds
		if corr
			mglBltTexture(fcg_tex, p.center); mglFlush;
		else
			mglBltTexture(fcr_tex, p.center); mglFlush;
		end
		mglWaitSecs(p.post_gap)
    end    
    %now add all the stuff to data
    end_time = mglGetSecs();
    data.contrast = contrast;
    data.response = response;
    data.stimside = stimside;
    data.conditions = conditions;
    data.correct = correct;
    save_new(data);
end

function run_adapter(swaps, p, rcos_mask)
    t_o = round(rand); %offset for swap
    fcw_tex = mglCreateTexture(p.fcross_white);
    for t = 1:swaps
        
        ori1_grating = mksinewave(p.component_contrast, p.sf, p.ori, 360*rand, p.screen.pixperdegree, p.sizeimg);
        ori2_grating = mksinewave(p.component_contrast, p.sf, -p.ori, 360*rand, p.screen.pixperdegree, p.sizeimg);
    
        if p.plaid == 1 %normal plaid condition
            if mod(t+t_o, 2) == 0
                adp_plaid = rcos_mask .* (ori1_grating + ori2_grating);                            
            else
                adp_plaid = rcos_mask .* 0;
            end            
        elseif p.plaid == 0 %grating condition
            if mod(t+t_o, 2) == 0
                adp_plaid = rcos_mask .* ori1_grating;
            else
                adp_plaid = rcos_mask .* ori2_grating;
            end
        elseif p.plaid == 2 %white noise condition
            adp_plaid = 1-2*rand(size(ori1_grating));
            targ_rms = sqrt(mean((ori1_grating + ori2_grating).^2));
            curr_rms = sqrt(mean(adp_plaid.^2));
            adp_plaid = (targ_rms/curr_rms) * adp_plaid .* rcos_mask;
        end

        adp_tex = mglCreateTexture(round(128 + 127*adp_plaid));
        for f = 1:p.switch_frames
            mglClearScreen; 
            mglBltTexture(fcw_tex, p.center);
            mglBltTexture(adp_tex, p.left); 
            mglBltTexture(adp_tex, p.right);
            mglFlush;
        end    
        for f = 1:p.switch_gap_frames
            mglClearScreen;             
            mglBltTexture(fcw_tex, p.center);
            mglFlush;
        end
        mglDeleteTexture(adp_tex);
    end
    mglDeleteTexture(fcw_tex);
end

%finds a new name in the current directory to save to
function save_new(data)
    data
    out = [data.p.data_dir,'/',data.p.savename];
    files = dir(data.p.data_dir);     
    found = false;
    k = 0;
    while true
        candidate = [out, num2str(k),'.mat']
        if ~exist(candidate)
            break;        
        else
            k = k+1;
        end
    end
    save(candidate, 'data')
end

