clear; close all;
mytime = tic;

%% video making
v = VideoWriter('transmitterDistanceVSChannelPower.avi');
v.FrameRate = 2;
open(v);
%% parameter setting
% x position moving
x_lines = [10:10:800];

% room dimension
room_dimension = [1000, 6, 6];

% probes numbers: num_points * num_points
% num_points =  8;
% probes coordinates

% receiver angel number
receiver_angle_num = 1;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');
tx_set = sweepingTransceiver([-490,0], 60, 64);
rx_set = [];
for x = x_lines
    rx_set = [rx_set;sweepingTransceiver([-490 + x, 0], 60, receiver_angle_num, angle2Points([0, 0],[-1,0])) ];
end

[trace, tr_ccomps] = ch_trace( tx_set, rx_set, room_dimension, 'max_refl',4);

x_distance = x_lines; 
max_power = [];
maxium_phase_shift = []; 
%% loop 
count = 1; 
for x = x_lines
set(gcf,'name','channel power in tx sector sweep');
max_power = [max_power; max(trace.power(count:63 + count))]
[~, s1] = max(trace.power(count:63 + count));

% plotImpulseResponse(figure(1), trace.impres(s1,:), 2.56e9);
f_samp = 2.56e9;
impulse_res = trace.impres(s1,:);
t=(1:length(impulse_res)) / f_samp *1e9;

maxium_phase_shift = [maxium_phase_shift;max(angle(impulse_res))];
count = count + 64;
end
%% plot the graph
figure(1)
plot(x_distance, max_power);
legend('rx');
xlabel('distance ');
ylabel('channel power');
figure(2)
plot(x_distance, maxium_phase_shift);
figure(3);
plotEnvironment(figure(3), trace, count - 64);