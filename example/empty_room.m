%% Example script to demonstrate the usage of mm-trace
% 	Project: 		mmTrace
% 	Author: 		Daniel Steinmetzer
% 	Affiliation:	SEEMOO, TU Darmstadt
% 	Date: 			January 2016

clear; close all;
mytime = tic;

% Place a transmitter at [-1,1], a receiver at [1,-1] and a second receiver
% at [1,1]. The transmitter performs a sector sweep while both receivers are
% oriented towards the transmitter
tx_set = sweepingTransceiver([0,0], 60, 64);
% rx_set = [	sweepingTransceiver([1,1],60,1, angle2Points([0,0],[1,0])); ...
% 			sweepingTransceiver([1,-1],60,1, angle2Points([1,1],[-1,1])); ...
%             sweepingTransceiver([-1,-1],60,1, angle2Points([1,1],[-1,1]))];
     
% seting different direction for the receivers
x_axis = linspace(-2, 2, 20);
y_axis = linspace(-1.25, 1.25, 20);
rx_set = [];
for i = x_axis
    for j = y_axis
        rx_set = [rx_set; sweepingTransceiver([i,j],60, 32, angle2Points([0,0],[0,1]))];
    end
end
        
        
% Trace the channels
[trace, tr_ccomps] = ch_trace( tx_set, rx_set, [4.5, 3, 3], 'max_refl',4);

toc(mytime);

%% Plot the received power for both receivers
figure(1);
set(gcf,'name','channel power in tx sector sweep');

count = 1; 
for i = 1:size(x_axis, 2)
    for j = 1:size(y_axis, 2)
        z(i, j) = max(trace.power(count:count + 64*16 -1));
        count = count + 64*16; 
    end
end

figure(1)
pcolor(x_axis,y_axis,z);
shading interp; 
colorbar; colormap(jet);
xlabel('X');ylabel('Y');  

hold on;
[cs, h]=contour(x_axis,y_axis,z,linspace(-55, -30, 6),'w--');
clabel(cs, h,'LabelSpacing',100, 'FontSize', 10, 'Color', 'k'); 
hold off;