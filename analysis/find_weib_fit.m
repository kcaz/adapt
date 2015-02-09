%DEPRACATED

function fparams = findWeibfit(x,y, init)
	OPTIONS = optimset('Display','off','TolFun',1e-12,'TolX',1e-12,'Maxiter',10000,'MaxFunEvals',500000);
	%init=[log(.7), log(3.5)]; %initial parameters
	init = log(init);
    %finit = [0,0]
	%[fparams,fval,exitflag] = fminsearch(@MLfitSumErr,init,OPTIONS,x,y);
    [fparams,fval,exitflag] = fminsearch(@MLfitSumErr,[init,0],OPTIONS,x,y);
	%for repeat = 1:10
%		init = [log(rand), log(3*rand)];
%		[fparamsc,fvalc,exitflag] = fminsearch(@MLfitSumErr,init,OPTIONS,x,y);
%		if fvalc < fval
%			fparams = fparamsc;
%			fval = fvalc;
%		end
%	end
    lapse_rate = 0.5 / (1+exp(-1*fparams(3)));
	fparams(1) = 1/(1+exp(-fparams(1)));
    fparams(2) = 6/(1+exp(-fparams(2)));
    %fparams(1:2) = exp(fparams(1:2));
    fparams(3) = lapse_rate;
    fparams(2) = 3;
    wtf=fparams 
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sumerr] = MLfitSumErr(params,x,y)
	%grad = weibull_gradient(exp(params(1)), exp(params(2)), x, y)
    params(1) = 1/(1+exp(-params(1)));
    params(2) = 6/(1+exp(-params(2)));
    
	pCorrect = weibull((params(1)),(params(2)),x);
	pCorrect(pCorrect<1e-10) = 1e-12;
	pCorrect(pCorrect>(1-1e-10)) = 1 - 1e-12;
    lapse_rate = 1/(1+exp(-params(3)));
	ceil_rate = 1-lapse_rate;
    
	sumerr = -sum(y.*log(pCorrect*ceil_rate+0.5*(1-ceil_rate)) + (1-y).*log((1-pCorrect)*ceil_rate+0.5*(1-ceil_rate)));
end

function [sumerr] = MLfitSumErrLapse(params,x,y)
	%grad = weibull_gradient(exp(params(1)), exp(params(2)), x, y)
	pCorrect = weibull(exp(params(1)),exp(params(2)),x);
	pCorrect(pCorrect<1e-10) = 1e-12;
	pCorrect(pCorrect>(1-1e-10)) = 1 - 1e-12;
	lapse_rate = 0.05 / (1+exp(-1*params(3)));
    ceil_rate = 1-lapse_rate;
	sumerr = -sum(y.*log(pCorrect*ceil_rate+0.5*(1-ceil_rate)) + (1-y).*log((1-pCorrect)*ceil_rate+0.5*(1-ceil_rate)));
end
