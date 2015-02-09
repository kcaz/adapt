function y = weibull2AFC(a,b,x)

	y = .5 + .5*(1 - exp( -(x/a).^b));
end
