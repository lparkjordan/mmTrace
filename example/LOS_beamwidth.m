clear; close all;
% Consider LOS in a study room and one transmitter located at the top right corner
% and a laptop (receiver) located at the center of the opposite wall
mytime = tic;
hpbw = [10,20,40,60,80];
s = size(hpbw);
nSec = 64;
n = 1;
% l,w,h
room = [10,10,3];


tx_set_10 = sweepingTransceiver([room(1)/2-0.2,room(2)/2-0.2], hpbw(1), nSec);
rx_set_10 = sweepingTransceiver([-room(2)/2+0.2,0], hpbw(1), 1, angle2Points([-room(2)/2+0.2,0],[room(1)/2-0.2,room(2)/2-0.2]));

tx_set_20 = sweepingTransceiver([room(1)/2-0.2,room(2)/2-0.2], hpbw(2), nSec);
rx_set_20 = sweepingTransceiver([-room(2)/2+0.2,0], hpbw(2), 1, angle2Points([-room(2)/2+0.2,0],[room(1)/2-0.2,room(2)/2-0.2]));

tx_set_40 = sweepingTransceiver([room(1)/2-0.2,room(2)/2-0.2], hpbw(3), nSec);
rx_set_40 = sweepingTransceiver([-room(2)/2+0.2,0], hpbw(3), 1, angle2Points([-room(2)/2+0.2,0],[room(1)/2-0.2,room(2)/2-0.2]));

tx_set_60 = sweepingTransceiver([room(1)/2-0.2,room(2)/2-0.2], hpbw(4), nSec);
rx_set_60 = sweepingTransceiver([-room(2)/2+0.2,0], hpbw(4), 1, angle2Points([-room(2)/2+0.2,0],[room(1)/2-0.2,room(2)/2-0.2]));

tx_set_80 = sweepingTransceiver([room(1)/2-0.2,room(2)/2-0.2], hpbw(5), nSec);
rx_set_80 = sweepingTransceiver([-room(2)/2+0.2,0], hpbw(5), 1, angle2Points([-room(2)/2+0.2,0],[room(1)/2-0.2,room(2)/2-0.2]));        

[trace_10, tr_ccomps_10] = ch_trace(tx_set_10, rx_set_10, [room(1),room(2),room(3)],'max_refl', 4);
[trace_20, tr_ccomps_20] = ch_trace(tx_set_20, rx_set_20, [room(1),room(2),room(3)],'max_refl', 4);
[trace_40, tr_ccomps_40] = ch_trace(tx_set_40, rx_set_40, [room(1),room(2),room(3)],'max_refl', 4);
[trace_60, tr_ccomps_60] = ch_trace(tx_set_60, rx_set_60, [room(1),room(2),room(3)],'max_refl', 4);
[trace_80, tr_ccomps_80] = ch_trace(tx_set_80, rx_set_80, [room(1),room(2),room(3)],'max_refl', 4);
toc(mytime);

figure(1);
clf
set(gcf,'name','channel power in tx sector sweep');
x	= trace_10.tx_set(1:nSec,4); 
legend_txt = {};
hold on
for i = 1:n
    plot(rad2deg(x), trace_10.power(((i-1)*nSec+1):(i*nSec)));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(1));
    plot(rad2deg(x), trace_20.power(((i-1)*nSec+1):(i*nSec)));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(2));
    plot(rad2deg(x), trace_40.power(((i-1)*nSec+1):(i*nSec)));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(3));
    plot(rad2deg(x), trace_60.power(((i-1)*nSec+1):(i*nSec)));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(4));
    plot(rad2deg(x), trace_80.power(((i-1)*nSec+1):(i*nSec)));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(5));
end
title("Received Power in Transmitter Sector Sweep")
ylim([-500, 0]);
hold off
legend(legend_txt);
xlabel('Transmitter Direction','FontSize',18);
ylabel('Received Power','FontSize',18);
saveas(gcf,'LOSpower.png')

% Find the optimal sectors for serving the receivers
for i = 1:n
    [~, opt_dir] = max(trace_10.power((i-1)*nSec+1:i*nSec));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set_10(opt_dir,4))), ' degree']);
    [~, opt_dir] = max(trace_20.power((i-1)*nSec+1:i*nSec));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set_20(opt_dir,4))), ' degree']);
    [~, opt_dir] = max(trace_40.power((i-1)*nSec+1:i*nSec));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set_40(opt_dir,4))), ' degree']);
    [~, opt_dir] = max(trace_60.power((i-1)*nSec+1:i*nSec));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set_60(opt_dir,4))), ' degree']);
    plotImpulseResponse(figure(2), trace_40.impres((i-1)*nSec+opt_dir,:), 2.56e9);
    saveas(gcf,'ImpulseResponse.png')
end

% Plot the environment
figure(3)
for i = 1:n
    subplot(ceil(sqrt(n)),ceil(sqrt(n)),i)
    plotEnvironment(figure(3), trace_10, (i-1)*nSec+1);
end
saveas(gcf,'LOSenvironment.png')