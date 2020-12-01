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

room_size = [9, 9, 3];
num_receivers = 8;
circle_radius = 3;
hpbw = 60;

tx_pos = [-room_size(1)/2 * 0.9, room_size(2)/2 * 0.9];

tx_set = sweepingTransceiver(tx_pos, 60, 64);
rx_set = [];
obstacles = [];
for i = 1:num_receivers
    % add a randomly oriented person at the point specified
    angle = (i-1)*2*pi/num_receivers;
    pos = circle_radius*[cos(angle), sin(angle)];
    person_width = 0.55;
    human_permit = 10;
    orientation = rand() * 2 * pi;
    rotation = rand() * 2 * pi;
    rx_pos = pos + person_width/2*sqrt(2)*[cos(orientation), sin(orientation)];
    rx_set = [rx_set; sweepingTransceiver(rx_pos, hpbw, 1, angle2Points(rx_pos,tx_pos))];
    
    person = [pos, person_width, person_width, rotation, human_permit];
    obstacles = [obstacles; person]; 
end
        
% Create some obstacles
obstacles = [obstacles;   
             0, 0, 0.5, 0.2, 0, 3.24];

% Trace the channels
[trace, tr_ccomps] = ch_trace( ...
    tx_set, rx_set, room_size, ...
    'max_refl', 4, ...
    'obstacles', obstacles);

toc(mytime);

%% Plot the received power for each receiver
figure(1);
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

% Find the optimal sectors for serving the receivers
figure_num = 2;
for i = 1:num_receivers
    [~, opt_dir] = max(trace.power((i-1)*64+1:i*64));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set(opt_dir,4))), ' degree']);
    plotImpulseResponse(figure(figure_num), trace.impres((i-1)*64+opt_dir,:), 2.56e9);
    figure_num = figure_num + 1;
end

% Plot the environment
figure(figure_num)
for i = 1:num_receivers
    subplot(ceil(sqrt(num_receivers)),ceil(sqrt(num_receivers)),i)
    plotEnvironment(figure(figure_num), trace, (i-1)*64+1);
end
figure_num = figure_num + 1;
