clear; close all;
mytime = tic;

%% video making
v = VideoWriter('transmitterDistanceVSChannelPower.avi');
v.FrameRate = 2;
open(v);
%% parameter setting
% x position moving
x_lines = [1:1:40];

% room dimension
room_dimension = [100, 6, 6];

% probes numbers: num_points * num_points
% num_points =  8;
% probes coordinates

% receiver angel number
receiver_angle_num = 1;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');
tx_set = sweepingTransceiver([-9,0], 60, 64);
rx_set = [];
for x = x_lines
    rx_set = [rx_set;sweepingTransceiver([x, 0], 60, receiver_angle_num, angle2Points([x, 0],[0,0])) ];
end

[trace, tr_ccomps] = ch_trace( tx_set, rx_set, room_dimension, 'max_refl',4);

x_distance = x_lines + 9; 
max_power = [];
maxium_phase_shift = []; 
%% loop 
count = 1; 
for x = x_lines

subplot(2, 2, 1);
set(gcf,'name','channel power in tx sector sweep');
single_trace = trace.tx_set(count:63 + count,4);
% max_power = [max_power; trace.power(count:63 + count)]
plot(rad2deg(single_trace), trace.power(count:63 + count));
ylim([-110, -60]);
legend('rx1', 'rx2');
xlabel('tx direction');
ylabel('channel power');
title(strcat('the distance: ', string(x + 9)))
toc(mytime);

[~, s1] = max(trace.power(count:63 + count));
disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set(s1,4))), ' degree']);

% plotImpulseResponse(figure(1), trace.impres(s1,:), 2.56e9);
f_samp = 2.56e9;
impulse_res = trace.impres(s1,:);
t=(1:length(impulse_res)) / f_samp *1e9;
subplot(2, 2, 3);
plot(t,impulse_res .* conj(impulse_res));
xlabel('time [ns]');
ylabel('pdp');

subplot(2,2,4);
plot(t,angle(impulse_res));
xlabel('time [ns]');
ylabel('phase');

myplotEnvironment(subplot(2, 2, 2), trace, count);
% title(strcat('the distance: ', string(x + 9)))
% wait time (1 second);
frame = getframe(gcf);
writeVideo(v,frame);
count = count + 64;
cla
end
close(v)