clear; close all;

mytime = tic;
hpbw = [10,20,40,60,80];
s = size(hpbw);
nSec = 64;
n = 1;
% l,w,h
room = [10,10,3];
times = 1;
power_10 = zeros(nSec,times);
power_20 = zeros(nSec,times);
power_40 = zeros(nSec,times);
power_60 = zeros(nSec,times);
power_80 = zeros(nSec,times);

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

for h = 1:times
ppl = zeros(20,2);
people = [];
obstacles = [[0,2.5], 1, 1, 0, 3.24];
for i = 1:20
    ppl(i,1:2) = randomBlockage(room(1), room(2));
    people = [ people; ppl(i,1:2), 0.5, 0.3, 0, 7.8];                       
end

[trace_10, tr_ccomps_10] = ch_trace(tx_set_10, rx_set_10, room,'max_refl', 4, 'obstacles', obstacles,'attenuators', people);
[trace_20, tr_ccomps_20] = ch_trace(tx_set_20, rx_set_20, room,'max_refl', 4, 'obstacles', obstacles,'attenuators', people);
[trace_40, tr_ccomps_40] = ch_trace(tx_set_40, rx_set_40, room,'max_refl', 4, 'obstacles', obstacles,'attenuators', people);
[trace_60, tr_ccomps_60] = ch_trace(tx_set_60, rx_set_60, room,'max_refl', 4, 'obstacles', obstacles,'attenuators', people);
[trace_80, tr_ccomps_80] = ch_trace(tx_set_80, rx_set_80, room,'max_refl', 4, 'obstacles', obstacles,'attenuators', people);
toc(mytime);

power_10(:,h) = trace_10.power;
power_20(:,h) = trace_20.power;
power_40(:,h) = trace_40.power;
power_60(:,h) = trace_60.power;
power_80(:,h) = trace_80.power;
end

%%
p = zeros(64,s(2));
p(:,1)= mean(power_10,2);
p(:,2)= mean(power_20,2);
p(:,3)= mean(power_40,2);
p(:,4)= mean(power_60,2);
p(:,5)= mean(power_80,2);
%%
figure(1);
clf
set(gcf,'name','channel power in tx sector sweep');
x	= trace_10.tx_set(1:nSec,4); 
legend_txt = {};
hold on
for i = 1:n
    plot(rad2deg(x), p((i-1)*nSec+1:i*nSec,1));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(1));
    plot(rad2deg(x), p((i-1)*nSec+1:i*nSec,2));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(2));
    plot(rad2deg(x), p((i-1)*nSec+1:i*nSec,3));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(3));
    plot(rad2deg(x), p((i-1)*nSec+1:i*nSec,4));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(4));
    plot(rad2deg(x), p((i-1)*nSec+1:i*nSec,5));
    legend_txt{end+1} = sprintf('HPBW = %0d', hpbw(5));
end
title("channel power in tx sector sweep")
ylim([-700, 0]);
hold off
legend(legend_txt);
xlabel('tx direction');
ylabel('channel power');
saveas(gcf,'RANDOMpower.png')

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
    [~, opt_dir] = max(trace_80.power((i-1)*nSec+1:i*nSec));
    disp(['Optimal direction for rx1: ', num2str(rad2deg(tx_set_80(opt_dir,4))), ' degree']);
    plotImpulseResponse(figure(2), trace_10.impres((i-1)*nSec+opt_dir,:), 2.56e9);
    saveas(gcf,'ImpulseResponse.png')
end
%%
% Plot the environment
figure(3)
for i = 1:n
    subplot(ceil(sqrt(n)),ceil(sqrt(n)),i)
    plotEnvironment(figure(3), trace_80, (i-1)*nSec+1);
end
saveas(gcf,'RANDOMenvironment.png')


function x = randomPosition(room_l,room_w)
     x = zeros(1,2);
     x(1) = (room_l-0.2) * rand(1,1)-((room_l-0.2)/2);
     x(2) = (room_w-0.2) * rand(1,1)-((room_w-0.2)/2);
end
function y = randomBlockage(room_l,room_w)
% 1->right 2->top 3->left 4->bottom
    y = zeros(1,2);
    y(1) = (room_l-0.6) * rand(1,1)-((room_l-0.2)/2);
    y(2) = (room_w-0.6) * rand(1,1)-((room_w-0.2)/2);
    
end