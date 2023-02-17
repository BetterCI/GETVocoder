% VocMain
% Demostration for Gaussian enveloped tone (GET) vocoder program which is used to generate vocoded speech
% for the advanced combination encoder (ACE) strategy
% Copyright ©Meng Qinglin
% Acoustic lab, South China University of Technology
% Email: mengqinglin@scut.edu.cn
% Date: 2022.3.28
% Add a batch version 2023.2.17  the default setting is a GEN vocoder
close all

NbandVocoder = 22;%  Number of Channel
Nmaxima = 8; % Number of Maxima
vocoderCarrier = 2; % 1 Gaussian enveloped tone (GET); 2 Gaussian enveloped noise (GEN)
ConvType = 1;% 1. Fake convolution; 2. Real convolution
% GET_Durations_Factors = ones(1,NbandVocoder)*3;
GET_Durations_Factors =   (3+(NbandVocoder-(1:NbandVocoder)));
GET_Carrier_Frequency_Shift = 0;

if GET_Carrier_Frequency_Shift == 0
    GET_fs = 16000;
else
    GET_fs = 48000;
end

%% input
wavlist = dir('audio\*.wav');  
% Revise "audio" as your taget folder path
% 将“audio”改为相应的音频文件所在的文件夹路径即可 例如D:\GET\张三\HINT  后面的'\.*wav'不要修改


addpath(genpath('ACE'));

for k = 1:length(wavlist)

    % soundPath1 = 'audio\T006_CB8_02553x3.wav'; % A English sentence
    % soundPath1 = 'audio\Pz.wav'; % A Mandarin Chinese Word 

    soundPath1 = [wavlist(k).folder,'\',wavlist(k).name];
    outputPath = [wavlist(k).folder,'\','GETOutput\'];
    
    if ~exist(outputPath, 'dir')
        mkdir(outputPath);
    end

    [x,fs] = audioread(soundPath1);

    if fs ~= 16000
        x = resample(x,16000,fs);    fs = 16000;
    end

    x = x/max(x)*0.36;
    t = (0:length(x)-1)/fs;
    %%
    subplot(326);
    [q,p] = ACEStrategy(x,fs,NbandVocoder,Nmaxima)  ;
    % % Convert ACE electrodogram into GET vocoded sound


    vocodedSound = GETvoc(q,p,vocoderCarrier,GET_Durations_Factors,ConvType,GET_Carrier_Frequency_Shift,GET_fs);  

    o = vocodedSound(:);
    o = o * rms(x)/rms(o);
    
    
    audiowrite([outputPath,wavlist(k).name],o,fs);
    
    t1 = (0:length(o)-1)/GET_fs;
    title('ACE Electrodogram')

    figure(1);
    subplot(321);plot(t,x);axis([0,t(end),-0.7,0.7]);title('original audio')
    subplot(323);myspectrogram(x,fs);xlim([0,t(end)]);
    subplot(322);plot(t1,o);axis([0,t1(end),-0.7,0.7]);title('GET vocoded')
    subplot(324);myspectrogram(o,GET_fs);xlim([0,t1(end)]);ylim([0,8000+GET_Carrier_Frequency_Shift])
    sound(o,GET_fs);

    set(gcf,'outerposition',get(0,'screensize'));
    a = findobj('Type','Axes'); linkaxes(a,'x');
end