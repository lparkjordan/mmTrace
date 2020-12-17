%% Example script to demonstrate the usage of mm-trace
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

close all;
mytime = tic;

orientation_1 = 60 * pi/180;

num_positions = 200;

attenuators = [];

for i = 1:num_positions
    % Place a transmitter at [-1,1], a receiver at [1,-1] and a second receiver
    % at [1,1]. The transmitter performs a sector sweep while both receivers are
    % oriented towards the transmitter
    tx_set = sweepingTransceiver([-2,1], 15, 64);
    rx_set = sweepingTransceiver([2 - 0.02*(i -1),-1],15,1, angle2Points([2-0.02*(i-1) - 1],[-2,1]));

    % Create some obstacles
    obstacles = [   1.5, 1, 0.5, 0.5, 0, 3.24; ...
                    2 - 0.02*(i -1), -0.8, 0.2, 0.2, 0, 3.24; ];

    % Trace the channels
    [trace, tr_ccomps] = ch_trace( ...
        tx_set, rx_set, [4.5, 3, 4.94], ...
        'max_refl', 4, ...
        'obstacles', obstacles);
    
    trace_matrix(i) = trace;
    tr_ccomps_matrix(i) = tr_ccomps;
end

toc(mytime);

%% Plot the received power for both receivers

v = VideoWriter('output_size_difference.avi');
v.FrameRate = 20;
open(v);


for i = 1:num_positions
    
    
    h0 = figure(1);
    set(gcf,'name','channel power in tx sector sweep');
    x	= trace_matrix(i).tx_set(1:64,4); 
    % plot(rad2deg(x), trace.power(1:64), rad2deg(x), trace.power(65:end));
    plot(rad2deg(x), trace_matrix(i).power(1:64));
    hold on
    plot(rad2deg(x), trace_matrix1(i).power(1:64));
    legend('with obstacle', 'without obstacle');
    xlabel('tx direction');
    ylabel('channel power');
    
    saveas(h0, '1.fig');
    
    clf(h0,'reset');
    
    % Find the optimal sectors for serving the receivers
    [~, s1] = max(trace_matrix(i).power(1:64));
    % [~, s2] = max(trace.power(65:end));

    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set(s1,4))), ' degree']);
    % disp(['Optimal direction for rx2: ', num2str(rad2deg(tx_set(s2,4))), ' degree']);

    h1 = figure(2);
    plotImpulseResponse(h1, trace_matrix(i).impres(s1,:), 2.56e9);
    % plotImpulseResponse(figure(3), trace.impres(64+s2,:), 2.56e9);
    saveas(h1, '2.fig');
    
    clf(h1,'reset');
    
    h2 = figure(3);
    % Plot the environment
    plotEnvironment(h2, trace_matrix(i), 1, attenuators);
    % plotEnvironment(figure(5), trace, 65);
    saveas(h2, '3.fig');
    
    clf(h2,'reset');
    
    % Number of the run
    N=0;

    % Get the path and filename of the desired fig file
    filename=[{'3.fig'}];
    pathname = 'C:\Users\Sanjeev\Desktop\ECE257A\Final Course Project\';
    for figureIndex = 1:size(filename,2)
        N=N+1;
        FN=[pathname filename{1,figureIndex}];
        % open figure
        h(N) = openfig(FN,'new','invisible');
        % get handle to axes of figure
        ax(N)=gca;
    end
    K=1;
    h = figure();
    for i=1:N
        % create and get handle to the subplot axes
%         s(i) = subplot(ceil(N/K),K,i); 
        s(i) = subplot(1,1,1);
        % get handle to all the children in the figure
        aux=get(ax(i),'children');
        for j=1:size(aux)
            fig(i) = aux(j);
            copyobj(fig(i),s(i)); 
            hold on
        end
        % copy children to new parent axes i.e. the subplot axes
        if(i ~= 1)
            xlab = get(get(ax(i),'xlabel'),'string');
            ylab = get(get(ax(i),'ylabel'),'string');
            tit = get(get(ax(i),'title'),'string');
            Legend = get(get(ax(i),'legend'),'string');
            xLimits = get(ax(i),'XLim');
            yLimits = get(ax(i),'YLim');
            ScaleX = get(ax(i),'Xscale');
            ScaleY = get(ax(i),'Yscale');
            TickX = get(ax(i),'Xtick');
            TickY = get(ax(i),'Ytick');
            TicklabelX = get(ax(i),'Xticklabel');
            TicklabelY = get(ax(i),'Yticklabel');
            set(gca, 'XScale', ScaleX, 'YScale', ScaleY, 'Xtick', TickX, 'Ytick',...
                TickY, 'Xticklabel', TicklabelX, 'Yticklabel', TicklabelY);
            xlabel(xlab);ylabel(ylab);title(tit);xlim(xLimits);ylim(yLimits);
            legend(Legend)
        end
    end

    
    F(i) = getframe(h);
    writeVideo(v,F(i).cdata)
    
end

close(v);
