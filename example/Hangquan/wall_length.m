clear; close all;
mytime = tic;

%% video making
v = VideoWriter('wall length changing.avi');
v.FrameRate = 2;
open(v);
%% parameter setting
% wall length extended 
wall_lengths = [1:0.2:5];


% room dimension
room_dimension = [9, 6, 6];

% probes numbers: num_points * num_points
num_points =  8;

% receiver angel number
receiver_angle_num = 4;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');

%% loop 
for wall = wall_lengths

% obstacle parameter
obstacles = [0.5, 0, 0.25, wall, 0, 3.24];
% probes area range
x_detect_left = obstacles(1) + obstacles(3)/2 + 0.25; 
x_detect_right = obstacles(1) + obstacles(3)/2 + 0.25 + 2;
y_detect_up = obstacles(4) /2  * 0.75;
y_detect_bottom = - obstacles(4) /2 * 0.75;
% probes coordinates
x_axis = linspace(x_detect_left, x_detect_right, num_points);
y_axis = linspace(y_detect_bottom , y_detect_up , num_points);

% get the transmitter sets
tx_set = sweepingTransceiver([-0.2,0], 60, 64);
% get the receiver sets
rx_set = [];
for i = x_axis
    for j = y_axis
        rx_set = [rx_set; sweepingTransceiver([i,j],60, receiver_angle_num, angle2Points([i, j],[0,0]))];
    end
end

% Trace the channels
[trace, tr_ccomps] = ch_trace( tx_set, rx_set, room_dimension, 'max_refl',4, 'obstacles', obstacles);
toc(mytime);

%% Plot the received power for both receivers
count = 1; 
for i = 1:size(x_axis, 2)
    for j = 1:size(y_axis, 2)
        z(i, j) = max(trace.power(count:count + 64*receiver_angle_num -1));
        count = count + 64*receiver_angle_num; 
    end
end
z = rot90(z);

% plot the graph
% reset the plot
cla
% draw the title
title(strcat('wall length: ', string(wall)))
% draw the limit of room
xlim([-room_dimension(1) / 2, room_dimension(1) / 2])
ylim([-room_dimension(2) / 2, room_dimension(2) / 2])
hold on
% draw the whole room 
rectangle('position',[-room_dimension(1)/2, -room_dimension(2)/2, room_dimension(1), room_dimension(2)] );
% draw the transmitter
x = -0.2
plot(-0.2,0,'or');
text(-0.2 - 1, 0.2, strcat('(',string(x),',', string(0), ') '))
% draw the obstacles
rectangle('Position',[0.375,-wall/2,0.25,wall],'Curvature', [0 0], 'FaceColor','black')
% draw the probe range
rectangle('position',[x_detect_left y_detect_bottom x_detect_right-x_detect_left y_detect_up-y_detect_bottom] );
% draw the probe values
pcolor(x_axis,y_axis,z);
shading interp; 
colorbar; colormap(jet);
% draw the color bar
dbStrength_left = -100; dbStrength_right = -60; 
caxis([-110 -60])
xlabel('X');ylabel('Y');  
% draw the coutour 
[cs, h]=contour(x_axis,y_axis,z,int16(linspace(min(z(:)), max(z(:)),6)),'w--');
clabel(cs, h,'LabelSpacing',100, 'FontSize', 10, 'Color', 'k'); 
hold off;
% create the frame and write frame into the videos
frame = getframe(gcf);
writeVideo(v,frame);
end
close(v)