clear; close all;
mytime = tic;

%% video making
% v = VideoWriter('transmitterDistanceVSChannelPower.avi');
% v.FrameRate = 2;
% open(v);
%% parameter setting
% x position moving
% x_lines = [3:0.5:60];

% room dimension
room_dimension = [9, 6, 6];

% probes numbers: num_points * num_points
% num_points =  8;
% probes coordinates

% receiver angel number
receiver_angle_num = 1;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');
x_tx =- room_dimension(1)/2*0.9; 
tx_set = sweepingTransceiver([x_tx,0], 60, 64);
rx_set = sweepingTransceiver([2, 0], 60, receiver_angle_num, angle2Points([0, 0],[-1,0]));


% obstacles
obstToTx = 1;
obstLen = 2; 
obstacles = [x_tx + obstToTx, 0, obstToTx*0.5, obstLen, 0, 3.24];

max_power = [];
permit_wall_list = [1.1:0.2:10];


for  permit_wall = permit_wall_list
[trace, tr_ccomps] = ch_trace( tx_set, rx_set, room_dimension, 'max_refl',4, 'obstacles', obstacles, 'permit_wall',permit_wall );
max_power = [max_power; max(trace.power(1:63 + 1))];
end
x_permit_wall = permit_wall_list; 

%% plot the graph
figure(1)
plot(x_permit_wall, max_power);
legend('rx');
xlabel('permittivity ');
ylabel('receiving power');
plotEnvironment(figure(2), trace, 1);