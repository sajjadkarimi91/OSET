% Test script for an ECG denoiser based on a data driven MAP estimator in
% the phase and time domains

close all
clear
clc

% Load data
datafilepath = '../../../DataFiles/PTBDataset/Physionet.org/files/ptbdb/1.0.0/'; % Change this path to where you have the .mat data files
filelist = dir(fullfile([datafilepath, '**/*.mat']));  % get list of all mat files of interest
fs = 1000.0; % Sampling frequency of the data (put it in the loop and read it from the data if not fixed across all records)

% Baseline wander removal filter
w1 = 0.72; % First stage baseline wander removal window size (in seconds)
w2 = 0.87; % Second stage baseline wander removal window size (in seconds)
BASELINE_REMOVAL_APPROACH = 'BP'; %'MDMN'; % baseline wander removal method
SNR_pre_set = 5000; % the desired input SNR
for k = 1 : 1%length(filelist) % Sweep over all or specific records
    datafilename = [filelist(k).folder '/' filelist(k).name];
    data = load(datafilename);
    data = data.val;
    data = data(:, 1 : round(20*fs)); % select a short segment
    
    switch(BASELINE_REMOVAL_APPROACH)
        case 'BP'
            data = data - LPFilter(data, 5.0/fs);
            data = LPFilter(data, 80.0/fs);
        case 'MDMN'
            wlen1 = round(w1 * fs);
            wlen2 = round(w2 * fs);
            for jj = 1 : size(data, 1)
                bl1 = BaseLine1(data(jj, :), wlen1, 'md');
                data(jj, :) = data(jj, :) - BaseLine1(bl1, wlen2, 'mn');
            end
        otherwise
            warning('Unknown method. Bypassing baseline wander removal.');
    end
    
    for ch = 1 : size(data, 1) % sweep over all or a single desired channel
        sig = data(ch, :);
        sd = sqrt(var(sig) / 10^(SNR_pre_set/10));
        x = sig + sd * randn(size(sig));
        
        f0 = 1.0; % approximate heart rate (in Hz) used for R-peak detection
        peaks = PeakDetection(sig, f0/fs);                  % peak detection
        
        I = find(peaks);
        t = (0 : length(x) - 1)/fs;
        
        GPfilterparams.bins = 300; % number of phase domain bins
        GPfilterparams.BEAT_AVG_METHOD = 'MEDIAN'; % 'MEAN' or 'MEDIAN'
        GPfilterparams.NOISE_VAR_EST_METHOD = 'AVGLOWER'; %'MIN', 'AVGLOWER', 'MEDLOWER', 'PERCENTILE'
        GPfilterparams.p = 0.5;
        GPfilterparams.avg_bins = 10;
        GPfilterparams.SMOOTH_PHASE = 'GAUSSIAN';
        GPfilterparams.gaussianstd = 1.0;
        GPfilterparams.plotresults = 0;
        GPfilterparams.nvar_factor = 1.0; % noise variance over/under estimation factor (1 by default)
        [data_posterior_est_phase_based, data_prior_est_phase_based] = ECGPhaseDomainMAPFilter(x, peaks, GPfilterparams);
        [data_posterior_est_time_based, data_prior_est_time_based] = ECGTimeDomainMAPFilter(x, peaks, GPfilterparams);
        
        SNR_pre = 10 * log10(mean(sig.^2) / mean((x - sig).^2));
        SNR_prior_phase_based = 10 * log10(mean(sig.^2) / mean((data_prior_est_phase_based - sig).^2));
        SNR_posterior_phase_based = 10 * log10(mean(sig.^2) / mean((data_posterior_est_phase_based - sig).^2));
        SNR_prior_time_based = 10 * log10(mean(sig.^2) / mean((data_prior_est_time_based - sig).^2));
        SNR_posterior_time_based = 10 * log10(mean(sig.^2) / mean((data_posterior_est_time_based - sig).^2));
        
        if 0
            figure;
            plot(t, x);
            hold on;
            plot(t(I), sig(I),'ro');
            grid
            xlabel('time (s)');
            ylabel('Amplitude');
            title('Noisy ECG and the detected R-peaks');
            set(gca, 'fontsize', 16)
        end
        
        lg = {};
        figure
        plot(t, x); lg = cat(2, lg, 'Noisy ECG');
        hold on
        plot(t, data_prior_est_time_based, 'linewidth', 2); lg = cat(2, lg, 'ECG prior estimate (time based)');
        plot(t, data_posterior_est_time_based, 'linewidth', 2); lg = cat(2, lg, 'ECG posterior estimate (time based)');
        plot(t, data_prior_est_phase_based, 'linewidth', 2); lg = cat(2, lg, 'ECG prior estimate (phase based)');
        plot(t, data_posterior_est_phase_based, 'linewidth', 2); lg = cat(2, lg, 'ECG posterior estimate (phase based)');
        plot(t, sig, 'linewidth', 2); lg = cat(2, lg, 'Original ECG');
        grid
        legend(lg)
        xlabel('time (s)');
        ylabel('Amplitude');
        title('Filtering results');
        set(gca, 'fontsize', 16)
        
        disp('Filtering performance:');
        disp([' Input SNR (desired) = ' num2str(SNR_pre_set), 'dB']);
        disp([' Input SNR (actual) = ' num2str(SNR_pre), 'dB']);
        disp([' Output SNR (prior phase-based) = ' num2str(SNR_prior_phase_based), 'dB']);
        disp([' Output SNR (prior time-based) = ' num2str(SNR_prior_time_based), 'dB']);
        disp([' Output SNR (posterior phase-based) = ' num2str(SNR_posterior_phase_based), 'dB']);
        disp([' Output SNR (posterior time-based) = ' num2str(SNR_posterior_time_based), 'dB']);
    end
end
