close all
clc
clear
results = importdata('J:\ECGData\PTB\AllDataSmootherResultsPTB06_ComparisonWithWavelet_Backup.txt'); fs = 1000;
% results = importdata('J:\ECGData\Arrhythmia\AllDataSmootherResultsArrhythmia06_ComparisonWithWavelet_Backup.txt'); fs = 360;
% results = importdata('J:\ECGData\Normal\AllDataSmootherResultsNormal06_ComparisonWithWavelet_Backup.txt'); fs = 128;
numeric = results.data(:,1:end);
nominal = results.textdata(:,1:end);

% snr_list = 30 : -3: -12;
snr_list = 30 : -3: -15;
TPTR = {'rigrsure'};%%%{'rigrsure', 'heursure', 'sqtwolog', 'minimaxi'};
SORH = {'s'};%%%{'s', 'h'};
SCAL = {'sln'};%%%{'one', 'sln', 'mln'};
WLEVELS = 1 : 10;
WNAME = {'haar', 'db2', 'db3' ,'db4', 'db5', 'db6', 'db7', 'db8', 'db9', 'db10', 'db12', 'db16', 'coif1', 'coif2', 'coif3', 'coif4', 'coif5', 'sym2', 'sym3', 'sym4', 'sym5', 'sym6', 'sym7', 'sym8', 'bior1.5', 'bior2.6', 'bior2.8', 'bior5.5', 'bior6.8'};

wname = 'db2';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

wname = 'db3';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

wname = 'coif2';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

wname = 'coif3';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

wname = 'coif4';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

wname = 'coif5';
figure
wavefun(wname,'plot',7);
FREQ = centfrq(wname)

WNAME_count = zeros(1, length(WNAME));
CENTFREQ = zeros(1, length(WNAME));
for i = 1 : length(WNAME),
    CENTFREQ(i) = centfrq(WNAME{i});% (fs/2)
    for j = 1 : length(nominal(:, 8)),
        if(isequal(nominal(j, 8), WNAME(i)))
            WNAME_count(i) = WNAME_count(i) + 1;
        end
    end
end
[Y I] = sort(WNAME_count, 'descend');

figure
hold on
bar(100*WNAME_count(I)/length(nominal(:, 8)));
plot(.1*(fs/2)*CENTFREQ(I), 'r', 'linewidth', 2);
set(gca, 'XTick', 1:length(WNAME))
set(gca, 'XTickLabel', WNAME(I))
grid

% % % snr = results(:, 8);
% % % snr0 = results(:, 9);
% % % snrimp1 = results(:, 10);
% % % % snrimp2 = results(:, 10);
% % % % snrimp3 = results(:, 11);
% % % optparam = results(:, 11);
% % % 
% % % snrimp1_mean = zeros(1, length(snr_list));
% % % % snrimp2_mean = zeros(1, length(snr_list));
% % % % snrimp3_mean = zeros(1, length(snr_list));
% % % snrimp1_std = zeros(1, length(snr_list));
% % % % snrimp2_std = zeros(1, length(snr_list));
% % % % snrimp3_std = zeros(1, length(snr_list));
% % % optparam_mean = zeros(1, length(snr_list));
% % % optparam_std = zeros(1, length(snr_list));
% % % for i = 1 : length(snr_list),
% % %     I = find(snr == snr_list(i));
% % %     snrimp1_mean(i) = mean(snrimp1(I));
% % %     %     snrimp2_mean(i) = mean(snrimp2(I));
% % %     %     snrimp3_mean(i) = mean(snrimp3(I));
% % %     snrimp1_std(i) = std(snrimp1(I));
% % %     %     snrimp2_std(i) = std(snrimp2(I));
% % %     %     snrimp3_std(i) = std(snrimp3(I));
% % %     optparam_mean(i) = mean(optparam(I));
% % %     optparam_std(i) = std(optparam(I));
% % % end
% % % 
% % % figure
% % % hold on
% % % % errorbar(snr_list, snrimp1_mean, snrimp1_std, 'b', 'linewidth', 2.5);
% % % % errorbar(snr_list, snrimp2_mean, snrimp2_std, 'r', 'linewidth', 2);
% % % % plot(snr_list, snrimp1_mean, 'b', 'linewidth', 2.5);
% % % % plot(snr_list, snrimp2_mean, 'r', 'linewidth', 2);
% % % plot(snr_list, snrimp1_mean, 'b', 'marker', 'square', 'LineWidth', 2, 'MarkerEdgeColor','k', 'MarkerFaceColor', 'm', 'MarkerSize', 6);
% % % % plot(snr_list, snrimp2_mean, 'r', 'marker', 'o', 'LineWidth', 2, 'MarkerEdgeColor','k','MarkerFaceColor','g', 'MarkerSize', 6);
% % % grid
% % % set(gca, 'fontsize', 16);
% % % set(gca, 'box', 'on');
% % % a = axis;
% % % a(1) = -15;%snr_list(end);
% % % a(2) = 33;%snr_list(1);
% % % a(3) = 0;
% % % a(4) = 8;
% % % % axis(a);
% % % xlabel('Input SNR (dB)');
% % % ylabel('\Delta SNR Mean (dB)');
% % % 
% % % figure
% % % hold on
% % % plot(snr_list, snrimp1_std, 'b', 'marker', 'square', 'LineWidth', 2, 'MarkerEdgeColor','k', 'MarkerFaceColor', 'm', 'MarkerSize', 6);
% % % % plot(snr_list, snrimp2_std, 'r', 'marker', 'o', 'LineWidth', 2, 'MarkerEdgeColor','k','MarkerFaceColor','g', 'MarkerSize', 6);
% % % grid
% % % set(gca, 'fontsize', 16);
% % % set(gca, 'box', 'on');
% % % a = axis;
% % % a(1) = -15;%snr_list(end);
% % % a(2) = 33;%snr_list(1);
% % % a(3) = 0;
% % % a(4) = 2;
% % % % axis(a);
% % % xlabel('Input SNR (dB)');
% % % ylabel('\Delta SNR SD (dB)');
% % % 
% % % figure
% % % hold on
% % % errorbar(snr_list, optparam_mean, optparam_std, 'r', 'marker', 'o', 'LineWidth', 2, 'MarkerEdgeColor','k','MarkerFaceColor','g', 'MarkerSize', 6);
% % % grid
% % % set(gca, 'fontsize', 16);
% % % set(gca, 'box', 'on');
% % % % a = axis;
% % % % a(1) = -15;%snr_list(end);
% % % % a(2) = 33;%snr_list(1);
% % % % a(3) = 0;
% % % % a(4) = 2;
% % % % axis(a);
% % % xlabel('Input SNR (dB)');
% % % ylabel('Optim Param');