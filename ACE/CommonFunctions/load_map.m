function p = load_map(VocParas)

%% Step 1: Read Patient Map file
MAP = Map_ACE(VocParas);

%% Step 2: Check MAP for any errors, rate, pulse width, THR, and MCL values are checked here
p = check_map(MAP);