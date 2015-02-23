%experimental variant where you adapt one side, using center/surround
%stimuli
%plaid specifies which side will be plaid adapted
%1 - left, 2 - right
%adapt_grate - adapt with gratings (1) or noise (0)
function joint_adapt_plaid(initials, plaid, do_adapt)
    data_dir = ['Data/',initials];
    %first, make sure that the parameter file is up to date
    run([data_dir,'/params_',initials,'.m'])
    params_dir = [data_dir, '/', 'p'];
    load(params_dir) %loads a struct called p
    
    [window, windowRect, imageRect, destRect] = init_ptb(p.screen);

    %rectangles for putting things!
    left = destRect - [1,0,1,0]*round(p.stim_pos * p.screen.pixperdegree);
    right = destRect + [1,0,1,0]*round(p.stim_pos * p.screen.pixperdegree);
    crossRect = CenterRect([0, 0, size(p.fcross)], windowRect);
    
    
    data.start_time = GetSecs();%creates a data
    
    p.plaid = plaid;
    p.data_dir = data_dir;
    p.do_adapt = do_adapt;
    data.p = p; %save the parameters


    %staircases will live in a horrible structure
    stairs = struct();
    st_lbls = ['a','b','c'];
    stairs.(st_lbls(1)) = get_stair(1,1,round(numel(p.contrasts)),p.contrasts);
    stairs.(st_lbls(2)) = get_stair(1,1,1,p.contrasts);
    stairs.(st_lbls(3)) = get_const(p.contrasts, p.trials_per_cond);
    
   

    conditions = [];%stair x side

    for st = [1,2,3]
        conditions = [st , conditions];        
    end
    conditions = repmat(conditions, 1, p.trials_per_cond);
    rcos_outer = raised_cosine(p.sizeimg, p.outer_stim_end, p.outer_stim_end+p.stim_ramp) - raised_cosine(p.sizeimg, p.outer_stim_start, p.outer_stim_start+p.stim_ramp);
    rcos_inner = raised_cosine(p.sizeimg, p.inner_stim_end, p.inner_stim_end+p.stim_ramp);
         

    %fixation cross textures
    fcr_tex = Screen('MakeTexture', window, p.fcross_red);
	fcg_tex = Screen('MakeTexture', window, p.fcross_green); 
    fcw_tex = Screen('MakeTexture', window, p.fcross_white); 


    pl_high = [];
    contrast = [];
    response = [];

    run_adapter(p.pre_adapt_switches, p, rcos_inner, rcos_outer);
    
    Screen('FillRect',window,[128,128,128],windowRect); 
    Screen('Flip',window); 
    WaitSecs(p.top_up_gap);

    for trial = 1:size(conditions, 2)
        run_adapter(p.top_up_switches, p, rcos_inner, rcos_outer);
        Screen('FillRect',window,[128,128,128],windowRect); 
        Screen('Flip',window)
        WaitSecs(p.top_up_gap);
        

        st = conditions(1, trial);

        contr = stairs.(st_lbls(st))();
        

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
        present_stim = rcos_inner .* (p.base_contrast + contr) .* ori1_grating + rcos_outer .* p.mask_contrast .* ori2_grating; %stimulus on adapted side
        absent_stim  = rcos_inner .* (p.base_contrast +     0) .* ori1_grating + rcos_outer .* p.mask_contrast .* ori2_grating;
    
        tex_pr = Screen('MakeTexture',window, round(128 + 127*present_stim));
        tex_ab = Screen('MakeTexture',window, round(128 + 127*absent_stim));

        Screen('FillRect',window,[128,128,128],windowRect); 
        
        if plaid == 1
            %Screen('DrawTexture',window,LineupTexture,[],destRect); 
            Screen('DrawTexture',window, tex_pr, [], left)
            Screen('DrawTexture',window, tex_ab,[], right)        
        elseif plaid == 2
            Screen('DrawTexture',window, tex_pr, [], right)
            Screen('DrawTexture',window, tex_ab, [], left)               
        end
        Screen('Flip',window);
        WaitSecs(p.stim_duration);
        Screen('FillRect',window,[128,128,128],windowRect); 
        Screen('DrawTexture',window, fcw_tex, [], crossRect)
        Screen('Flip',window)
        Screen('Close', tex_pr);
        Screen('Close', tex_ab);
        %no feedback
        k = -1;
        while ~ any(k==p.keys)
            
            [~, k_codes] = KbWait();
            k = find(k_codes,1);
            
        end
        
        if k == p.keys(3)
            Screen('CloseAll');
            break;
        elseif k == p.keys(1)
            resp = 1;
        elseif k == p.keys(2)
            resp = 2;
        end
        
        if plaid == resp
            pl_judged_high = 1;
        else
            pl_judged_high = 0;
        end
        
        contrast = [contrast, contr];
        response = [response resp];    
        pl_high = [pl_high pl_judged_high];    
        
        
        stairs.(st_lbls(st))(pl_judged_high);
        %update staircases
        

        
        if p.feedback
        %give feedback, then wait post_gap seconds
            corr = (pl_judged_high && contr > 0) || (~pl_judged_high && contr < 0);

            if corr
                Screen('FillRect',window,[128,128,128],windowRect); 
                Screen('DrawTexture',window, fcg_tex, [], crossRect)
                Screen('Flip',window)

            else
                Screen('FillRect',window,[128,128,128],windowRect); 
                Screen('DrawTexture',window, fcr_tex, [], crossRect)
                Screen('Flip',window)

            end
        end
		WaitSecs(p.post_gap)
    end    
    %now add all the stuff to data
    end_time = GetSecs();
    data.contrast = contrast;
    data.response = response;
    %data.stimside = stimside;
    data.conditions = conditions;
    %data.correct = correct;
    save_new(data);
    sca;
    %nested function for access to local variables
    function run_adapter(swaps, p, rcos_inner, rcos_outer)
        t_o = round(rand); %offset for swap
        ori = p.ori * sign(rand() - 0.5);
        for t = 1:swaps
            ori = ori * -1;
            ori1_grating = mksinewave(p.component_contrast, p.sf, ori, 360*rand, p.screen.pixperdegree, p.sizeimg);
            ori2_grating = mksinewave(p.component_contrast, p.sf, -ori, 360*rand, p.screen.pixperdegree, p.sizeimg);

            if do_adapt

                adp_plaid = rcos_inner .* ori1_grating + rcos_outer .* ori2_grating;                            

                adp_grate = rcos_inner .* ori1_grating + rcos_outer .* ori1_grating;
            else
                adp_plaid = 1-2*rand(size(ori1_grating));
                targ_rms = sqrt(mean((ori1_grating + ori2_grating).^2));
                curr_rms = sqrt(mean(adp_plaid.^2));
                adp_plaid = (targ_rms/curr_rms).^0.5 * adp_plaid .* (rcos_inner + rcos_outer);
                adp_grate = adp_plaid;
            end
            adp_tex_p = Screen('MakeTexture',window,uint8(128 + 127*adp_plaid));
            adp_tex_g = Screen('MakeTexture',window,uint8(128 + 127*adp_grate));
            
            for f = 1:p.switch_frames
                Screen('FillRect',window,[128,128,128],windowRect); 
                Screen('DrawTexture',window, fcw_tex, [], crossRect);
                if plaid == 1
                    Screen('DrawTexture',window, adp_tex_p, [],left);
                    Screen('DrawTexture',window, adp_tex_g, [], right);
                else
                    Screen('DrawTexture',window, adp_tex_g, [],left);
                    Screen('DrawTexture',window, adp_tex_p, [], right);
                end
                Screen('Flip',window) 
            end
            
            for f = 1:p.switch_gap_frames
                Screen('FillRect',window,[128,128,128],windowRect);
                Screen('DrawTexture',window, fcw_tex, [], crossRect)
                Screen('FillRect',window,[128,128,128],windowRect);
                Screen('DrawTexture',window, fcw_tex, [], crossRect)
                Screen('Flip',window)
            end
            Screen('Close',adp_tex_p);
            Screen('Close',adp_tex_g);
        end
    end
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
