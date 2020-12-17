%% Example script to demonstrate the usage of mm-trace
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

close all;
mytime = tic;

orientation_1 = 60 * pi/180;

material = 'd';
thickness = 0.05;
permittivity = 2.8;
dry_wall_initial = [ -2.25,-0.2, 2.25, -0.2, thickness, permittivity];
% The following variable is a modified version of dry_wall_initial used for
% plotting the attenuator
dry_wall_dimension = [0, 0, 4.5, 0.05];
edge1 = createEdge(dry_wall_initial(1), dry_wall_initial(2), dry_wall_initial(3), dry_wall_initial(4));


num_positions = 200;
human_width = 0.1;

%% The iteration starts from here
for i = 1:num_positions
    % Place a transmitter at [-1,1], a receiver at [1,-1] and a second receiver
    % at [1,1]. The transmitter performs a sector sweep while both receivers are
    % oriented towards the transmitter
    human_pos_x = 2 - 0.02*(i - 1);
    human_pos_y = -0.8;
    tx_set = sweepingTransceiver([-2,1], 15, 64);
    rx_set = sweepingTransceiver([human_pos_x,human_pos_y-human_width],15,1, angle2Points([2-0.02*(i-1) ,- 1],[-2,1]));

    % Create some obstacles
    obstacles = [   1.5, 1, 0.5, 0.5, 0, 3.24];
%                     human_pos_x, human_pos_y, human_width, human_width, 0, 10; ];

%      obstacles = [1.5, 1, 0.5, 0.5, 0, 3.24];

      attenuators = [dry_wall_dimension, 0, 3.24];
%       attenuators = [];

    % Trace the channels
    [trace, tr_ccomps] = ch_trace( ...
        tx_set, rx_set, [4.5, 3, 5], ...
        'permit_wall', 5, ...
        'max_refl', 4, ...
        'obstacles', obstacles);
    
    trace_matrix(i) = trace;
    tr_ccomps_matrix(i) = tr_ccomps;
end

toc(mytime);

%% Plot the received power for both receivers

v = VideoWriter('output_attenuation_wall_difference_final.avi');
v.FrameRate = 20;
open(v);

for k = 1:num_positions
    
    h0 = figure(1);
    set(gcf,'name','channel power in tx sector sweep');
    x	= trace_matrix(k).tx_set(1:64,4); 
    % plot(rad2deg(x), trace.power(1:64), rad2deg(x), trace.power(65:end));
    plot(rad2deg(x), trace_matrix(k).power(1:64));
%     hold on
% %     plot(rad2deg(x), trace_matrix2(k).power(1:64));
% %     hold on
%     plot(rad2deg(x), trace_matrix(k).power(1:64));
%     hold on
%     plot(rad2deg(x), trace_matrix2(k).power(1:64));
%     legend('Free Space', 'Dry wall', 'Concrete');
    xlabel('tx direction');
    ylabel('channel power');

    saveas(h0, '1.fig');

      clf(h0,'reset');

    % Find the optimal sectors for serving the receivers
    [~, s1] = max(trace_matrix(k).power(1:64));
    % [~, s2] = max(trace.power(65:end));

    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set(s1,4))), ' degree']);
    % disp(['Optimal direction for rx2: ', num2str(rad2deg(tx_set(s2,4))), ' degree']);

    h1 = figure(2);
    plotImpulseResponse(h1, trace_matrix(k).impres(s1,:), 2.56e9);
    % plotImpulseResponse(figure(3), trace.impres(64+s2,:), 2.56e9);
    saveas(h1, '2.fig');

      clf(h1,'reset');

    h2 = figure(3);
    % Plot the environment
    plotEnvironment(h2, trace_matrix(k), 1, attenuators);
    % plotEnvironment(figure(5), trace, 65);
    saveas(h2, '3.fig');

      clf(h2,'reset');

    % Number of the run
    N=0;

    % Get the path and filename of the desired fig file
    filename={'3.fig'};
%     filename = [{'1.fig'} {'3.fig'}];
    pathname = 'C:\Users\Sanjeev\Desktop\ECE257A\Final Course Project\mmtrace-final\mmTrace\';
    for figureIndex = 1:size(filename,2)
        N=N+1;
        FN=[pathname filename{1,figureIndex}];
        % open figure
        h(N) = openfig(FN,'new','invisible');
        % get handle to axes of figure
        ax(N)=gca;
    end
    K=2;
    h = figure();
    for m=1:N
        % create and get handle to the subplot axes
%          s(m) = subplot(ceil(N/K),K,m);
         s(m) = subplot(1,1,1);
        % get handle to all the children in the figure
        aux=get(ax(m),'children');
        for j=1:size(aux)
            fig(m) = aux(j);
            copyobj(fig(m),s(m)); 
            hold on
        end
        % copy children to new parent axes i.e. the subplot axes
        if(m ~= 1)
            xlab = get(get(ax(m),'xlabel'),'string');
            ylab = get(get(ax(m),'ylabel'),'string');
            tit = get(get(ax(m),'title'),'string');
            Legend = get(get(ax(m),'legend'),'string');
            xLimits = get(ax(m),'XLim');
            yLimits = get(ax(m),'YLim');
            ScaleX = get(ax(m),'Xscale');
            ScaleY = get(ax(m),'Yscale');
            TickX = get(ax(m),'Xtick');
            TickY = get(ax(m),'Ytick');
            TicklabelX = get(ax(m),'Xticklabel');
            TicklabelY = get(ax(m),'Yticklabel');
            set(gca, 'XScale', ScaleX, 'YScale', ScaleY, 'Xtick', TickX, 'Ytick',...
                TickY, 'Xticklabel', TicklabelX, 'Yticklabel', TicklabelY);
            xlabel(xlab);ylabel(ylab);title(tit);xlim(xLimits);ylim(yLimits);
            legend(Legend)
        end
    end

    F(k) = getframe(h);
    writeVideo(v,F(k).cdata);
end

close(v);
