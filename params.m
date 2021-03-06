function p = params
    p.savename = 'default'
    p.screen = laptop_screen;
    
    %stimulus layout
    p.center = round(p.screen.screendims/2);
    p.stim_pos = 4;
    p.left = p.center - [p.screen.pixperdegree * p.stim_pos, 0];
    p.right = p.center + [p.screen.pixperdegree * p.stim_pos, 0];
    p.sizeimg = [256, 256];
    p.stim_rad = 60;
    p.stim_ramp = 8;
    p.ori = 15; %left and right 15 degrees
    p.sf = 4; %spatial frequency
    
    
    %fixation cross stuff. silly to have this here but whatever
    p.fcross = fixation_cross([17, 17]);
    p.fcross_red = 128*ones(17, 17, 3);
	p.fcross_red(:,:,1) = p.fcross;
	p.fcross_green = 128*ones(17, 17, 3);
	p.fcross_green(:,:,2) = p.fcross;
    p.fcross_white = repmat(fixation_cross([17,17]), [1,1,3]);	
    
    %control of contrast
    p.mask_contrast = 0.7;
    p.contrasts = logspace(log10(0.015), log10(0.3),9); %this is the contrast increments
    p.component_contrast = 0.45;
    p.base_contrast = 0.0; %pedestal for detection    

    %timing control
    %all times are in seconds
    p.pre_adapt_switches = 100;
    p.top_up_switches = 6;
    p.switch_duration = 1.0;
    p.switch_gap_duration = 2/60;
    p.top_up_gap = 0.25;
    p.post_gap = 0.25;
    p.stim_duration = 0.2;
    
    %how many trials?
    p.trials_per_cond = 50;%this is trials per staircase
    
    if mod(p.screen.framerate * p.switch_duration, 1)
        display('non integer number of switch frames!')
    end
    if mod(p.screen.framerate * p.switch_gap_duration, 1)
        display('non integer number of gap frames!')
    end
    p.switch_frames = round(p.screen.framerate * p.switch_duration);
    p.switch_gap_frames = round(p.screen.framerate * p.switch_gap_duration);
    
    %response control
    p.keys = [11, 12, 25]; %left, right, quit
    
    %this parameter needs to be set by the experiment
    p.plaid = nan;
    save p

end
