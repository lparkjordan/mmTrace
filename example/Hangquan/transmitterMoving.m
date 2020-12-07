clear; close all;
mytime = tic;

%% video making
v = VideoWriter('trasnmitterMoving.avi');
v.FrameRate = 2;
open(v);
%% parameter setting
% x position moving
x_lines = [-4:0.1:0.2];
% figure index
figure_count = 1; 
% obstacle parameter
obstacles = [0.5, 0, 0.25, 2, 0, 3.24];
% room dimension
room_dimension = [9, 6, 6];
% probes area range
x_detect_left = obstacles(1) + obstacles(3)/2 + 0.25; 
x_detect_right = obstacles(1) + obstacles(3)/2 + 0.25 + 2;
y_detect_up = obstacles(4) /2  * 0.75;
y_detect_bottom = - obstacles(4) /2 * 0.75;
% probes numbers: num_points * num_points
num_points =  8;
% probes coordinates
x_axis = linspace(x_detect_left, x_detect_right, num_points);
y_axis = linspace(y_detect_bottom , y_detect_up , num_points);
% receiver angel number
receiver_angle_num = 8;
% set the gca gcf 
set(gca,'nextplot','replacechildren'); 
set(gcf,'name','channel power in tx sector sweep');

%% loop 
for x = x_lines
% get the transmitter sets
tx_set = sweepingTransceiver([x,0], 60, 64);
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
% figure(figure_count)
cla
xlim([-room_dimension(1) / 2, room_dimension(1) / 2])
ylim([-room_dimension(2) / 2, room_dimension(2) / 2])
hold on

plot(x,0,'or');
text(x - 1, 0.2, strcat('(',string(x),',', string(0), ') '))

rectangle('Position',[0.375,-1,0.25,2],'Curvature', [0 0], 'FaceColor','black')

rectangle('position',[x_detect_left y_detect_bottom x_detect_right-x_detect_left y_detect_up-y_detect_bottom] );

pcolor(x_axis,y_axis,z);
shading interp; 
colorbar; colormap(jet);
caxis([-90 -60])
xlabel('X');ylabel('Y');  
rectangle('position',[-room_dimension(1)/2, -room_dimension(2)/2, room_dimension(1), room_dimension(2)] );
% title(strcat('xaxis range: ','(',string(x),',', string(0), '), ', 'receiver Angel: ', string(receiver_angle_num), ', receiver number: ', string(num_points), ...
%     ', room dimension: ', '(',string(room_dimension(1)),',', string(room_dimension(2)),',', string(room_dimension(3)), ') '));
hold off;
frame = getframe(gcf);
writeVideo(v,frame);
% figure_count = figure_count + 1; 
end
close(v)