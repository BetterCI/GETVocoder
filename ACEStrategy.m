function [q,p] = ACEStrategy(x,fs,NbandVocoder,Nmaxima)  
% Gaussian enveloped tone (GET) vocoder program to generate vocoded speech
% for the advanced combination encoder (ACE) strategy
% Input：
% x - input audio vector
% fs - sampling rate
% NbandVocoder - band number, i.e.,the "m" value in "n-of-m" processing of ACE
% Nmaxima - maxima number, i.e., the "n" value in "n-of-m" processing of ACE
% vocoderCarrrier 1. Sine-wave (Tone) 2. Noise
% Output:

% Copyright ©Meng Qinglin
% Acoustic lab, South China University of Technology
% Email: mengqinglin@scut.edu.cn
% Date: 2022.3.28

%%  Stimulate
VocParas.NumberOfBands = NbandVocoder;
VocParas.Nmaxima = Nmaxima;
VocParas.THR = 10;
VocParas.MCL = 250;
VocParas.BandGain = 0;
VocParas.StimulationRate = 900;
p = load_map(VocParas);

p = initialize_ACE(p); 

p.General.LeftOn = 1; 

map = p;

map.Left.lr_select = 'left'; %%% left - - - Process the left implant first
       if (fs~=16000)
            x = resample(x, 16000, fs);
       end
[q,p] = ACE_Process(x, map.Left);



end
