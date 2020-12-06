%% Example script to demonstrate the usage of mm-trace
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

clear; close all;
mytime = tic;

% Place a transmitter at one corner and a circle of recievers in the middle of the room
% The transmitter performs a sector sweep while both receivers are
% oriented towards the transmitter
figure_num = 1;
plot_impulse_responses = 0;
plot_spatial_power = 0;
plot_env = 0;



for sqrt_receivers = 1:7
    num_receivers = sqrt_receivers^2;
    repetitions = floor(250 / num_receivers);
    max_powers = zeros(num_receivers,repetitions);
    for rep = 1:repetitions
        
        room_size = [20, 20, 3];
        person_width = 0.55;
        circle_radius = 3;

        usable_area = room_size(1:2) - 2 * person_width* sqrt(2) * ones(2,1);
        uniform_spacing = usable_area / (sqrt(num_receivers));
        grid_size = ceil(sqrt(num_receivers));

        hpbw = 60;

        tx_pos = [-room_size(1)/2 * 0.9, room_size(2)/2 * 0.9];
        tx_set = sweepingTransceiver(tx_pos, 60, 64);

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
            rx_set = [rx_set; sweepingTransceiver(rx_pos, hpbw, 1, angle2Points(rx_pos,tx_pos))];

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

        toc(mytime);

        %% Plot the received power for each receiver
        if (plot_spatial_power)
            figure(figure_num);
            clf
            set(gcf,'name','channel power in tx sector sweep');
            x	= trace.tx_set(1:64,4); 
            legend_txt = {};
            hold on
            for i = 1:num_receivers
                plot(rad2deg(x), trace.power((i-1)*64+1:i*64));
                legend_txt{end+1} = sprintf('rx%0d', i);
            end
            hold off
            legend(legend_txt);
            xlabel('tx direction');
            ylabel('channel power');
            figure_num = figure_num + 1;
        end
        % Find the optimal sectors for serving the receivers
        for i = 1:num_receivers
            [max_powers(i,rep), opt_dir] = max(trace.power((i-1)*64+1:i*64));
            disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set(opt_dir,4))), ' degree']);
            if (plot_impulse_responses)
                plotImpulseResponse(figure(figure_num), trace.impres((i-1)*64+opt_dir,:), 2.56e9);
                figure_num = figure_num + 1;
            end

        end

        % Plot the environment
        if (plot_env)
            figure(figure_num)
            for i = 1:num_receivers
                subplot(ceil(sqrt(num_receivers)),ceil(sqrt(num_receivers)),i)
                plotEnvironment(figure(figure_num), trace, (i-1)*64+1);
                title(sprintf('Rx %d', i))
            end
            figure_num = figure_num + 1;
        end
    end
    figure(figure_num)
    max_powers = reshape(max_powers, [], 1);
    histogram(max_powers,20);
    figure_num = figure_num + 1;
end