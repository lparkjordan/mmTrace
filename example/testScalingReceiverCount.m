%% Example script to demonstrate the usage of mm-trace
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

clear; close all;
mytime = tic;

mkdir('res')

% Place a transmitter at one corner and a circle of recievers in the middle of the room
% The transmitter performs a sector sweep while both receivers are
% oriented towards the transmitter
figure_num = 1;
plot_cdf = 1;
plot_impulse_responses = 0;
plot_spatial_power = 0;
plot_env = 0;

max_figures_per_run = 4;

max_density = 9;
target_num_runs = 256;
max_powers_compiled = cell(max_density,1);
traces_compiled = cell(max_density, 1);

tx_sectors = 64;
rx_sectors = 1;
tx_rx_combos = tx_sectors * rx_sectors;

parfor idx = 1:max_density
    num_receivers = idx^2;
    repetitions = floor(256 / num_receivers);
    max_powers = zeros(num_receivers,repetitions);
    traces = cell(repetitions,1);
    for rep = 1:repetitions
        
        room_size = [10, 10, 3];
        person_width = 0.55;
        circle_radius = 3;

        usable_area = 0.9 * room_size(1:2) - person_width* sqrt(2) * ones(1,2);
        if (idx > 1)
            uniform_spacing = usable_area / (idx - 1);
        else
            uniform_spacing = usable_area / idx;
        end
        grid_size = ceil(sqrt(num_receivers));

        hpbw = 60;

        tx_pos = [-room_size(1)/2 * 0.9, room_size(2)/2 * 0.9];
        tx_set = sweepingTransceiver(tx_pos, 60, tx_sectors);

        rx_set = [];
        people = [];
        for i = 0:num_receivers-1
            % add a randomly oriented person at the point specified
            angle = (i-1)*2*pi/num_receivers;
            %pos = circle_radius*[cos(angle), sin(angle)];
            pos = [(mod(i,grid_size) - (grid_size-1)/2)*uniform_spacing(1), ...
                   (floor(i/grid_size) - (grid_size-1)/2)*uniform_spacing(2)];
            human_permit = 10;
            orientation = rand() * 2 * pi;
            rotation = rand() * 2 * pi;
            rx_pos = pos + person_width/2*sqrt(2)*[cos(orientation), sin(orientation)];
            rx_set = [rx_set; sweepingTransceiver(rx_pos, hpbw, rx_sectors, angle2Points(rx_pos,tx_pos))];

            person = [pos, person_width, person_width, rotation, human_permit];
            people = [people; person]; 
        end

        % Create an obstacle
        obstacles = [];%[0, 0, 1.5, 1.5, 0, 3.24];

        % Trace the channels
        [trace, tr_ccomps] = ch_trace( ...
            tx_set, rx_set, room_size, ...
            'max_refl', 4, ...
            'obstacles', obstacles, ...
            'attenuators', people);
        traces{rep} = trace;
        toc(mytime);

        %% Plot the received power for each receiver
        if (plot_spatial_power)
            figure((idx-1)*max_figures_per_run+1);
            clf
            set(gcf,'name','channel power in tx sector sweep');
            x	= trace.tx_set(1:tx_rx_combos,4); 
            legend_txt = {};
            hold on
            for i = 1:num_receivers
                plot(rad2deg(x), trace.power((i-1)*tx_rx_combos+1:i*tx_rx_combos));
                legend_txt{end+1} = sprintf('rx%0d', i);
            end
            hold off
            legend(legend_txt);
            xlabel('tx direction');
            ylabel('channel power');
        end
        % Find the optimal sectors for serving the receivers
        for i = 1:num_receivers
            [max_powers(i,rep), opt_dir] = max(trace.power((i-1)*tx_rx_combos+1:i*tx_rx_combos));
            opt_dir_tx = mod(opt_dir, tx_sectors);
            opt_dir_rx = floor(opt_dir/tx_sectors);
            disp([sprintf('Optimal direction for rx%0d: ', i), num2str(rad2deg(tx_set(opt_dir_tx,4))), ' degree']);
            if (plot_impulse_responses)
                plotImpulseResponse(figure((idx-1)*max_figures_per_run+2), trace.impres((i-1)*tx_rx_combos+(opt_dir_rx-1)*tx_sectors+opt_dir_tx,:), 2.56e9);
            end

        end

        % Plot the environment
        if (plot_env)
            figure((idx-1)*max_figures_per_run+3)
            for i = 1:num_receivers
                subplot(ceil(sqrt(num_receivers)),ceil(sqrt(num_receivers)),i)
                plotEnvironment(figure((idx-1)*max_figures_per_run+3), trace, (i-1)*tx_rx_combos+1);
                title(sprintf('Rx %d', i))
            end
        end
    end
    
    max_powers = reshape(max_powers, [], 1);
    max_powers_compiled{idx} = max_powers;
    traces_compiled{idx} = traces;
end

if (plot_cdf)
    for fig_num = 1:max_density
        figure(fig_num)
        cdfplot(max_powers_compiled{fig_num})
        title(sprintf('Measured CDF of Channel Gains for %.2f Humans Per m^2', fig_num^2/100));
        xlabel('Power (dB)');
        ylabel('Cumulative Probability')
        saveas(gcf, sprintf('res/cdf_%0d.png', fig_num))
    end
end

prob_coverage = zeros(max_density,1);
for idx = 1:max_density
    prob_coverage(idx) = sum(max_powers_compiled{idx} > -120)/length(max_powers_compiled{idx});
end

figure(10)
plot((1:max_density).^2/100, prob_coverage);
xlabel('Density (Humans / m^2)')
ylabel('Probability of Coverage')
title(sprintf('Probability of Coverage with %0d Rx Sectors, %0d Tx Sectors', rx_sectors, tx_sectors));
saveas(gcf, sprintf('res/prob_%0drx_%0dtx.png', rx_sectors, tx_sectors))