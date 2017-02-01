cziPath = ['C:\Users\d.kelly\Desktop' filesep 'EXP2 test_2016_04_29__15_01_20.czi'];

data = bfopen(cziPath);
omeMeta = data{1,4};
data = data{1}(1:(omeMeta.getPixelsSizeC(0).getValue()):end,1);
newshape = [size(data{1}, 1), length(data), size(data{1}, 2)];
data = cell2mat(data);
data = reshape(data, newshape);
stack = permute(data, [1 3 2]);

disruptionFrame = 61;

zPlane = 1;

%%
for zPlane = 1:omeMeta.getPixelsSizeZ(0).getValue()

    figname = sprintf('Z plane = %d', zPlane);
    hfig = figure('Name', figname);
    
    planestack = stack(:,:,zPlane:omeMeta.getPixelsSizeZ(0).getValue():end);

    gainCorrection = mean(mean(planestack(:,:,disruptionFrame+1)))/mean(mean(planestack(:,:,disruptionFrame)));
    planestack(:,:,1:disruptionFrame) = planestack(:,:,1:disruptionFrame) * gainCorrection;
    
    ms = squeeze(mean(mean(planestack, 1),2));

%     %%
%     ms = mean(mean(planestack,1),2);
%     plot(squeeze(ms));

    lag = 10;
    lags = [1 5 10 20];
    
    for lind = 1:length(lags)
        
        lag = lags(lind);

        diffplot = zeros(1,(size(planestack,3) - lag));

        for cind = 1:(size(planestack,3) - lag)

            diffplot(cind) = ms(cind) - ms(cind + lag);

        end
        
%         subplot(length(lags)+1, 2, 2 * lind - 1);
        subplot(length(lags)+1, 1, lind);
        title(sprintf('Difference plot, lag = %d frames', lag));
        plot(diffplot);
        
%         subplot(length(lags)+1, 2, 2 * lind);
%         NFFT = 2^nextpow2(length(diffplot));
%         f = fft(
    
    end

    subplot(length(lags)+1, 1, (length(lags)+1));
    imagesc(squeeze(planestack(:,:,end)));
    colormap gray
    axis equal tight
    set(gca, 'XTick', [], 'YTick', []);
    
    [out_path, ~, ~] = fileparts(cziPath);
    out_file = [out_path filesep figname];
    print(hfig, out_file, '-dpng', '-r300');
    
    
end


% DYLAN'S SUGGESTION:

% Generate a stack that is im(t) - im(t + lag): in the case of constant
% lumen opening, a spatially averaged plot of this stack would be constant.
% In the case of pulsing opening, there would be oscillatory behaviour
% observed in the plot: a fourier analysis will tell us the
% time-periodicity of this opening. 

% IS TIME THE IMPORTANT FACTOR - it seems to me to be more likely that
% spatial position of the sticking points is of interest? Better to do a
% single, wide kymograph the axis of which runs along the midline in which
% you should see successive steps. Tracing the opening edge (top edge in
% kym) should give a plot with steps, which can then be used with the
% lagging technique to give oscillatory difference plot, which in turn can
% then be fourier analysed...
% 

% To show the effect of lag time

% Then generate a plot of mean image signal with time, perhaps normalised
% to mean signal from the original stack in order to get rid of ~linear
% decrease in intensity over time course. 

% Generate plots for each lag and show as subplots in order to compare
% effects of different lag times. 

% Then perform fourier analysis to identify the 

% Does Autocorrelation get us anywhere here?:
% % 
% % load officetemp
% % 
% % tempC = (temp-32)*5/9;
% % 
% % tempnorm = tempC-mean(tempC);
% % 
% % fs = 2*24;
% % t = (0:length(tempnorm) - 1)/fs;
% % 
% % plot(t,tempnorm)
% % xlabel('Time (days)')
% % ylabel('Temperature ( {}^\circC )')
% % axis tight
% % 
% % [autocor,lags] = xcorr(tempnorm,3*7*fs,'coeff');
% % 
% % plot(lags/fs,autocor)
% % xlabel('Lag (days)')
% % ylabel('Autocorrelation')
% % axis([-21 21 -0.4 1.1])
% % 
% % [pksh,lcsh] = findpeaks(autocor);
% % short = mean(diff(lcsh))/fs
% % 
% % [pklg,lclg] = findpeaks(autocor, ...
% %     'MinPeakDistance',ceil(short)*fs,'MinPeakheight',0.3);
% % long = mean(diff(lclg))/fs
% % 
% % hold on
% % pks = plot(lags(lcsh)/fs,pksh,'or', ...
% %     lags(lclg)/fs,pklg+0.05,'vk');
% % hold off
% % legend(pks,[repmat('Period: ',[2 1]) num2str([short;long],0)])
% % axis([-21 21 -0.4 1.1])

% % 
% % %% Author :- Embedded Laboratory
% % 
% % %%This Project shows how to apply FFT on a signal and its physical 
% % % significance.
% % 
% % fSampling = 10000;          %Sampling Frequency
% % tSampling = 1/fSampling;    %Sampling Time
% % L = 10000;                  %Length of Signal
% % t = (0:L-1)*tSampling;      %Time Vector
% % F = 100;                    %Frequency of Signal
% % 
% % %% Signal Without Noise
% % xsig = sin(2*pi*F*t);
% % subplot(2,1,1)
% % plot(t,xsig);
% % grid on;
% % axis([0 0.1 -1.2 +1.2])
% % xlabel('\itTime Axis \rightarrow');
% % ylabel('\itAmplitude \rightarrow');
% % title('\itxsig(t) of Frequency = 100Hz');
% % pause(2);
% % 
% % %%Frequency Transform of above Signal
% % subplot(2,1,2)
% % NFFT = 2^nextpow2(L);
% % Xsig = fft(xsig,NFFT)/L;
% % f1 = fSampling/2*(linspace(0,1,NFFT/2+1));
% % semilogy(f1,2*abs(Xsig(1:NFFT/2+1)),'r');
% % grid on;
% % axis([-50 500 1.0000e-005 1])
% % title('\itSignle-Sided Amplitude Sepectrum of xsig(t)');
% % xlabel('\itFrequency(Hz) \rightarrow');
% % ylabel('|Xsig(f)| \rightarrow');
% % pause(2);
% % 
% % %% Addition of Noise in Signal when Signal is Transmitted over some
% % % transmission medium
% % xnoise = xsig +0.25*randn(size(t));
% % figure;
% % subplot(2,1,1)
% % plot(t,xnoise,'r');
% % grid on;
% % xlabel('\itTime Axis \rightarrow');
% % ylabel('\itAmplitude \rightarrow');
% % title('\itxnoise(t) of Frequency = 100Hz (Noise Addition)');
% % pause(2);
% % 
% % %%Frequency Transform of the Noisy Signal
% % subplot(2,1,2)
% % NFFT = 2^nextpow2(L);
% % XNoise = fft(xnoise,NFFT)/L;
% % f1 = fSampling/2*(linspace(0,1,NFFT/2+1));
% % semilogy(f1,2*abs(XNoise(1:NFFT/2+1)),'r');
% % grid on;
% % axis([-50 500 1.0000e-005 1])
% % title('\itSignle-Sided Amplitude Sepectrum of xnoise(t)');
% % xlabel('\itFrequency(Hz) \rightarrow');
% % ylabel('|XNoise(f)| \rightarrow');
% % pause(2);
% % 
% % %%Comparision of both Spectrums
% % figure;
% % subplot(2,1,1)
% % semilogy(f1,2*abs(Xsig(1:NFFT/2+1)));
% % grid on;
% % axis([-50 500 1.0000e-005 1])
% % title('\itSignle-Sided Amplitude Sepectrum of xsig(t)');
% % xlabel('\itFrequency(Hz) \rightarrow');
% % ylabel('|Xsig(f)| \rightarrow');
% % 
% % subplot(2,1,2)
% % semilogy(f1,2*abs(XNoise(1:NFFT/2+1)),'r');
% % grid on;
% % axis([-50 500 1.0000e-005 1])
% % title('\itSignle-Sided Amplitude Sepectrum of xnoise(t)');
% % xlabel('\itFrequency(Hz) \rightarrow');
% % ylabel('|XNoise(f)| \rightarrow');

