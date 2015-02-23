%this analysis function should work for 2 side plaid and surround
function stuff = analyze_joint_adapt_2s(files, varargin)
    
    boot = 100;
    output_file = ''
    if numel(varargin) > 1
        output_file = varargin{2}
    end
    if numel(varargin) > 0
       boot = varargin{1} 
    end
    fs = 12
    
    colors = [[0,0.5,0.5];[0.5, 0,0.5];[0.25,0.5,0.5];[0.5,0.25,0.5]];
    figure
    hold on
    %do some messy crap with the legends
        
    h1=plot(-1,-1,'o','color',colors(1,:))
    set(h1, 'MarkerSize',10);
    set(h1, 'MarkerFaceColor',colors(1,:));

    h2=plot(-1,-1,'o','color',colors(2,:))
    set(h2, 'MarkerSize',10);
    set(h2, 'MarkerFaceColor',colors(2,:));
    
    h3=plot(-1,-1,'o','color',colors(3,:))
    set(h3, 'MarkerSize',10);
    set(h3, 'MarkerFaceColor',colors(3,:));
    
    
    h4=plot(-1,-1,'o','color',colors(4,:))
    set(h4, 'MarkerSize',10);
    set(h4, 'MarkerFaceColor',colors(4,:));
    
    [l1]=legend([h1,h2,h3,h4],'L/A','R/A','L/N','R/N','Location','East')
    set(l1, 'fontsize',fs)
    set(l1, 'String', {'L/A    ','R/A    ','L/N    ','R/N    '})
    
    %I will code "correct" as choosing the adapted side, out of sheer
    %laziness
    for code = 1:4
        contrasts = [];
        correct = [];
        for i=1:numel(files)
            dat = load(files{i});
            datcode = dat.data.p.plaid + 2*dat.data.p.do_adapt; %index into colors, and whatnot
            if datcode == code
                contrasts = [contrasts, dat.data.contrast];
                correct = [correct, dat.data.response == dat.data.p.plaid];
            end
        end
        if ~numel(contrasts)
            continue %skip this code
        end

        pretty_plot_psycho(contrasts, correct, boot, colors(code,:));
        axis([-0.25,0.25,-0.05,1.05])
    end
    if numel(varargin)>1
        plot2svg(output_file)
        %print(gcf, '-depsc2', output_file);
    end
    
end


%get pct correct
function [ux, pct, correct, outof] = get_pct(x, b)
    ux = unique(x);
    pct = arrayfun(@(uxv) mean(b(x == uxv)), ux);
    correct = arrayfun(@(uxv) sum(b(x == uxv)), ux);
    outof = arrayfun(@(uxv) numel(b(x == uxv)), ux);
end

%doesn't handle legends
function h = pretty_plot_psycho(contrasts, correct, boot, color)
    xedge = 0.05;%how far past given values to plot
    yedge = 0.05;
    fs = 12;
    ms = 5; %base marker size
    [x, y, y_correct, y_outof] = get_pct(contrasts, correct);
    [wp, sd, bwp] = find_gauss_fit(x, y_correct, y_outof, boot);
    xs = linspace(min(x)-xedge, max(x)+xedge, 100);
        
    ys = PAL_CumulativeNormal(wp, xs);

    %do possible bootstrap error bars
    if boot
        ys_boot = [];
        for bpi = 1:size(bwp,1)
            ys_boot = [ys_boot ; PAL_CumulativeNormal(bwp(bpi,:), xs)];
        end
        
        low = get_percentile(ys_boot, 0.05);
        high = get_percentile(ys_boot, 0.95);
        %now we want to plot the area between these
        poly_x = [xs, fliplr(xs)];
        poly_y = [low, fliplr(high)];
        h=fill(poly_x, poly_y, color*1.0 + [1,1,1]*0.0);
        alpha(h,0.2)
        set(h,'EdgeColor','none')
    end
    
    %axis([0, max(x)+xedge, max(0.4,min(y))-yedge, 1+yedge])
    
    %plot the data points
    for i=1:numel(x)

        ms_i = ms + 10*y_outof(i) / max(y_outof);
        h=plot(x(i), y(i), 'o','color',color);

        set(h, 'MarkerSize',ms_i);
        set(h, 'MarkerFaceColor',color);
        hold on     
    end
    %plot weibull params
    h = plot(xs, ys, 'color',color);
    set(h,'LineWidth',2);
    pse = PAL_CumulativeNormal(wp, 0.5, 'Inverse');
    h = plot([pse, pse], [0,1],'--','color',color);
    set(h,'LineWidth',2);
    h=xlabel(sprintf('contrast increment'));
    xlabh = get(gca,'XLabel');
    set(xlabh,'Position',get(xlabh,'Position') - [0 0.00 0])
    
    set(h, 'FontSize',fs)
    h=ylabel(sprintf('percent correct'));
    set(h, 'FontSize',fs)
    set(gca,'FontSize',fs)

end

function xpct = get_percentile(x, pct)
    ind = round(pct*size(x,1));
    x_sort = sort(x);
    xpct = x_sort(ind, :);
end