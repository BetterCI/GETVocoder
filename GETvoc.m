function [VocodedSound,ModulatedBands] = GETvoc(electrodogram,map,vocoderCarrier,GET_Durations_Factors,ConvType,GET_Carrier_Frequency_Shift,GET_fs)
% Transfer a ACE electrodgram to a vocoder simulation sound

% Copyright ©Meng Qinglin
% Acoustic lab, South China University of Technology
% Email: mengqinglin@scut.edu.cn
% Date: 2022.3.28


% Tone carrier, or noise carrier
NumCh = map.NumberOfBands;
NumMax = map.Nmaxima;
NumPulses = length(electrodogram.electrodes);
InterPulsePeriod = electrodogram.periods;
T = NumPulses*InterPulsePeriod/(1e6)+0.06;
NumSampling = round(T*GET_fs);
t = (0:NumSampling-1)/GET_fs;
VocEnv = zeros(NumCh,NumSampling);
VocCarrier = zeros(NumCh,NumSampling);

ACE_fs = 16000;
fftsize = 128;
block_size = 128;
bin_freqres = ACE_fs / fftsize; % frequency bin resolution
bin_freqs = bin_freqres * (0:(fftsize-1)); % frequency value for each fft bin
bin_freqs = bin_freqs(1:fftsize/2+1);
[weights,~] = calculate_weights(NumCh,fftsize/2+1); 
switch vocoderCarrier 
    case 1 % If Tone carrier        
        for n = 1:NumCh
            UsefulBins = weights(NumCh-n+1,:)>0;
            fc(n) = sum(UsefulBins.*bin_freqs)/sum(UsefulBins)+GET_Carrier_Frequency_Shift;  % n=1 Highest freq, n = 22 lowest freq
            VocCarrier(n,:) = sin(2*pi*fc(n)*t)/NumMax; % sine wave carriers, initial phase:0
            D(n) = GET_Durations_Factors(n)/fc(n); % D is the effective duration of Gaussian Envelope
        end
    case 2 % If Noise Carrier        
        for n = 1:NumCh
            VocCarrier(n,:) = zeros(size(t));
            UsefulBins = weights(NumCh-n+1,:)>0;
            fc(n) = sum(UsefulBins.*bin_freqs)/sum(UsefulBins)+GET_Carrier_Frequency_Shift;  % n=1 Highest freq, n = 22 lowest freq
            freqs = bin_freqs(UsefulBins);
            cutoffs = [freqs(1)-ACE_fs/block_size/2,freqs(end)+ACE_fs/block_size/2]+GET_Carrier_Frequency_Shift;%
            bandwidth = diff(cutoffs);
            for m = 1:ceil(bandwidth*0.1) % 0.1约等于24.7*4.37/1000 与ERB有关
                tempFreq = rand(1)*bandwidth+cutoffs(1);
                VocCarrier(n,:) = VocCarrier(n,:)+sin(2*pi*tempFreq*t+rand(1)*2*pi);% adding many sines with random initial phase gets a noise
            end
            D(n) = GET_Durations_Factors(n)/fc(n); % D is the effective duration of Gaussian Envelope
        end
end

v = electrodogram.current_levels/255; % see logarithmic_compression.m
acousticLevel = ((1 + map.lgf_alpha).^v-1)/map.lgf_alpha; % 

for n = 1:NumPulses
    currentElecrode = electrodogram.electrodes(n);
    if currentElecrode % if not 0
        halfEnvelopePointNum = 3*round((D(currentElecrode)/2)*GET_fs);
        GauEnv = acousticLevel(n)*GaussianEnvelope(D(currentElecrode),halfEnvelopePointNum,GET_fs);
        currentTime = n*InterPulsePeriod/(1e6);
        temp = round(currentTime*GET_fs);
        for tempIndex =  -halfEnvelopePointNum:halfEnvelopePointNum
            if tempIndex+temp > 0
                switch ConvType
                    case 1
                        VocEnv(currentElecrode,tempIndex+temp) = max(VocEnv(currentElecrode,tempIndex+temp), GauEnv(tempIndex+halfEnvelopePointNum+1));
                    case 2
                        VocEnv(currentElecrode,tempIndex+temp) = VocEnv(currentElecrode,tempIndex+temp)+GauEnv(tempIndex+halfEnvelopePointNum+1);% 20220325
                end
            end
        end
    end
end

ModulatedBands = VocEnv.*VocCarrier;

for n = 1:NumCh
    if rms(ModulatedBands(n,:)) ~=0
        ModulatedBands(n,:) = ModulatedBands(n,:) * rms(electrodogram.current_levels(electrodogram.electrodes == n)) / rms(ModulatedBands(n,:));
    end
end

VocodedSound = sum(ModulatedBands);

% Deemphasis
p.pre_numer =    [0.4994   0.4994];
p.pre_denom =    [1.0000   -0.0012];
VocodedSound = filter(p.pre_numer, p.pre_denom,VocodedSound);

VocodedSound = VocodedSound/max(VocodedSound)*0.5;

end

function GauEnv = GaussianEnvelope(D,halfEnvelopePointNum,fs)
t = (-halfEnvelopePointNum:halfEnvelopePointNum)/fs;
GauEnv = exp(-pi*t.^2/D^2);
end

function [w,band_bins] = calculate_weights(numbands,numbins)
    band_bins = FFT_band_bins(numbands)';
    w = zeros(numbands, numbins);
    bin = 3;	% ignore bins 0 (DC) & 1.
    for band = 1:numbands
        width = band_bins(band);
        w(band, bin:(bin + width - 1)) = 1;
        bin = bin + width;
    end
end

function widths = FFT_band_bins(num_bands)
    switch num_bands
        case 22
            widths = [ 1, 1, 1, 1, 1, 1, 1,    1, 1, 2, 2, 2, 2, 3, 3, 4, 4, 5, 5, 6, 7, 8 ];% 7+15 = 22
        case 21
            widths = [ 1, 1, 1, 1, 1, 1, 1,    1, 2, 2, 2, 2, 3, 3, 4, 4, 5, 6, 6, 7, 8 ];   % 7+14 = 21
        case 20
            widths = [ 1, 1, 1, 1, 1, 1, 1,    1, 2, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8, 8 ];      % 7+13 = 20
        case 19
            widths = [ 1, 1, 1, 1, 1, 1, 1,    2, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8, 9 ];         % 7+12 = 19
        case 18
            widths = [ 1, 1, 1, 1, 1, 2,    2, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8, 9 ];         % 6+12 = 18
        case 17
            widths = [ 1, 1, 1, 2, 2,    2, 2, 2, 3, 3, 4, 4, 5, 6, 7, 8, 9 ];         % 5+12 = 17
        case 16
            widths = [ 1, 1, 1, 2, 2,    2, 2, 2, 3, 4, 4, 5, 6, 7, 9,11 ];         % 5+11 = 16
        case 15
            widths = [ 1, 1, 1, 2, 2,    2, 2, 3, 3, 4, 5, 6, 8, 9,13 ];            % 5+10 = 15
        case 14
            widths = [ 1, 2, 2, 2,    2, 2, 3, 3, 4, 5, 6, 8, 9,13 ];            % 4+10 = 14
        case 13
            widths = [ 1, 2, 2, 2,    2, 3, 3, 4, 5, 7, 8,10,13 ];               % 4+ 9 = 13
        case 12
            widths = [ 1, 2, 2, 2,    2, 3, 4, 5, 7, 9,11,14 ];                  % 4+ 8 = 12
        case 11
            widths = [ 1, 2, 2, 2,    3, 4, 5, 7, 9,12,15 ];                  % 4+ 7 = 11
        case 10
            widths = [ 2, 2, 3,    3, 4, 5, 7, 9,12,15 ];                  % 3+ 7 = 10
        case  9
            widths = [ 2, 2, 3,    3, 5, 7, 9,13,18 ];                     % 3+ 6 =  9
        case  8
            widths = [ 2, 2, 3,    4, 6, 9,14,22 ];                        % 3+ 5 =  8
        case  7
            widths = [ 3, 4,    4, 6, 9,14,22 ];                        % 2+ 5 =  7
        case  6
            widths = [ 3, 4,    6, 9,15,25 ];                           % 2+ 4 =  6
        case  5
            widths = [ 3, 4,    8,16,31 ];                           % 2+ 3 =  5
        case  4
            widths = [ 7,    8,16,31 ];                             % 1+ 3 =  4
        case  3
            widths = [ 7,   15,40 ];                                % 1+ 2 =  3
        case  2
            widths = [ 7,   55 ];                                   % 1+ 1 =  2
        case  1
            widths =  62 ;                                          %         1
        otherwise
            error('illegal number of bands');
    end
end