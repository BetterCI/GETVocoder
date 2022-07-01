function MAP = Map_ACE(VocParas)

%% Left Ear Parameters
%  remove this section if left side does not exist
MAP.Left.ImplantType        = 'CI24RE';     %Implant chip type, e.g., CI24RE(CS/CA), CI24R, CI24M, CI22M, ST
MAP.Left.SamplingFrequency  = 16000;        % Fixed
% MAP.Left.NumberOfChannels   = 22;           % 22 fixed for imlants from Cochlear Ltd.
MAP.Left.Strategy           = 'ACE';        % 'ACE' or 'CIS' or 'Custom'
MAP.Left.Nmaxima            = VocParas.Nmaxima;            % Nmaxima 1 - 22 for n-of-m strategies
MAP.Left.StimulationMode    = 'MP1+2';      % Electrode Configuration/Stimulation mode e.g., MP1, MP1+2, BP1, BP1+2, CG,....etc.
MAP.Left.StimulationRate    = VocParas.StimulationRate;         % Stimulation rate per electrode in number of pulses per second (pps)
MAP.Left.PulseWidth         = 25;           % Pulse width in us
MAP.Left.IPG                = 8;            % Inter-Phase Gap (IPG) fixed at 8us (could be variable in future)
MAP.Left.Sensitivity        = 2.3;          % Microphone Sensitivity (adjustable in GUI)
MAP.Left.Gain               = 25;           % Global gain for envelopes in dB - standard is 25dB (adjustable in GUI)
MAP.Left.Volume             = 10;           % Volume Level on a scale of 0 to 10; 0 being lowest and 10 being highest (adjustable in GUI)
MAP.Left.Q                  = 20;           % Q-factor for the compression function
MAP.Left.BaseLevel          = 0.0156;       % Base Level
MAP.Left.SaturationLevel    = 0.5859;       % Saturation Level
MAP.Left.ChannelOrderType   = 'base-to-apex'; % Channel Stimulation Order type: 'base-to-apex' or 'apex-to-base'
MAP.Left.FrequencyTable     = 'Default';    % Frequency assignment for each band "Default" or "Custom"
MAP.Left.Window             = 'Hanning';     % Window type

MAP.Left.NumberOfBands          = VocParas.NumberOfBands;    % Number of active electrodes/bands
MAP.Left.Electrodes             = (VocParas.NumberOfBands:-1:1)';       % Active Electrodes

MAP.Left.THR                    = VocParas.THR*ones(VocParas.NumberOfBands,1);       % Threshold Levels (THR)
MAP.Left.MCL                    = VocParas.MCL*ones(VocParas.NumberOfBands,1);       % Maximum Comfort Levels (MCL)
MAP.Left.BandGains              = VocParas.BandGain*ones(VocParas.NumberOfBands,1);       % Individual Band Gains (dB)
% MAP.Left.Comments               = '';                                           % Optional: comments

