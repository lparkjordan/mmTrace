clear; close all;
mytime = tic;

%% changing
% without obstacles, transmitter (3.5,0),

%% video making
v = VideoWriter('wall permitivity changing.avi');
v.FrameRate = 2;
open(v);
%% parameter setting

% room dimension
room_dimension = [9, 6, 6];
% probes numbers: num_points * num_points
num_points =  8;
% receiver angel number
receiver_angle_num = 4;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');

%% set the changing parameter
% set the permit_walls
permit_walls = [6:1:12];
% trasnmitter coordinate
transmitter_x = 3.5; transmitter_y = 0; 
%% loop 
for permit_wall = permit_walls
% temp value
wall = 2;
% % obstacle parameter
% obstacles = [0.5, 0, 0.25, 2, 0, 3.24];
% probes area range
x_detect_left = transmitter_x + 0.25; 
x_detect_right = transmitter_x + 0.75;
y_detect_up = 1;
y_detect_bottom = - 1;
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
[trace, tr_ccomps] = ch_trace( tx_set, rx_set, room_dimension, 'max_refl',4,  'permit_wall', permit_wall);
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

%% plot the graph
% reset the plot
cla
% draw the title
title(strcat('permit wall: ', string(permit_wall)))
% draw the limit of room
xlim([-room_dimension(1) / 2, room_dimension(1) / 2])
ylim([-room_dimension(2) / 2, room_dimension(2) / 2])
hold on
% draw the whole room 
rectangle('position',[-room_dimension(1)/2, -room_dimension(2)/2, room_dimension(1), room_dimension(2)] );
% draw the transmitter
plot(transmitter_x,transmitter_y,'or');
text(transmitter_x - 1, transmitter_y + 0.2, strcat('(',string(transmitter_x),',', string(transmitter_y), ') '))
% % draw the obstacles
% rectangle('Position',[0.375,-wall/2,0.25,wall],'Curvature', [0 0], 'FaceColor','black')
% draw the probe range
rectangle('position',[x_detect_left y_detect_bottom x_detect_right-x_detect_left y_detect_up-y_detect_bottom] );
% draw the probe values
pcolor(x_axis,y_axis,z);
shading interp; 
colorbar; colormap(jet);
% draw the color bar
dbStrength_left = -70; dbStrength_right = -30; 
caxis([dbStrength_left dbStrength_right])
xlabel('X');ylabel('Y');  
% draw the coutour 
[cs, h]=contour(x_axis,y_axis,z,linspace(min(z(:)), max(z(:)), 6),'w--');
clabel(cs, h,'LabelSpacing',100, 'FontSize', 10, 'Color', 'k'); 
hold off;
% create the frame and write frame into the videos
% plotEnvironment(figure(4), trace, 1);
frame = getframe(gcf);
writeVideo(v,frame);
end
close(v)