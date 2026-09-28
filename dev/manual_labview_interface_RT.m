%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%interface between labview and matlab

%INPUT FROM LABVIEW
%   i          - integer,itteration number
%   auto_enable- boolean
%   file       - string : tells program where to look for settinga files
%   file_exact - string
%   mloop      - boolean(legacy) do you want to interface with mloop or use matlab to scan over variables
%   control    - boolean(legacy)

%return
%exact_line- double (legacy just return a zero)
%new_path 

%% USER SETTINGS

update_keysight = 1;

num_points = 1;
shots_per_point = 400;
%num_sets  = 2;
%shots_per_set = 700;
shot_offset = 10;
shot_numb = i + 8750;%shot iteration number to write in log text file.
evap_update_interval = 5;
trap_type = 'quad_0_7_shunt_0_75';
top_target = 18;
% marker = 1;
% marker2 = 1;

if (i-1)<shot_offset
    marker = 1;
    %marker2 = 1;
    sequence = {'mag_k=-1'};
    new_path = 'c:\remote\settings202609Jun142828.xml'%'c:\remote\settings202614Jan114308.xml'%'c:\remote\settings202529Dec141959.xml'%
    evap_setting = 9; %0.857Mhz
    top_target = 18;
else
    marker = mod(floor((i-1-shot_offset)/shots_per_point), num_points)+1; %Counts from 1 to num shots before setpt update
    %marker2 = mod(floor((i-1-shot_offset)/shots_per_set), num_sets)+1;
    sequence = {'mag_k=-1','const','k=+1,0,-1','mirror','splitter'}%,'mag_transfer'};
    new_path = 'c:\remote\settings202610Jun154918.xml'%'c:\remote\settings202604Mar144909.xml'%'c:\remote\settings202626Feb133902.xml'%'c:\remote\settings202624Feb100917.xml'%'c:\remote\settings202617Feb100901.xml'%%'c:\remote\settings202614Jan114623.xml'%'c:\remote\settings202612Jan122720.xml'%'c:\remote\settings202402Nov213520.xml'%'c:\remote\settings202428Oct183106.xml'%'c:\remote\settings202428Oct103234.xml'%'c:\remote\settings202427Oct172710.xml'%'c:\remote\settings202410Oct115329.xml';
   %[new_path,evap_setting,num_path]=evap_setting_update(evap_setting,i-shot_offset,evap_update_interval,trap_type,top_target);
    %%'c:\remote\settings202616Jan083958.xml'%'c:\remote\settings202616Jan112246.xml'
    %'c:\remote\settings202616Feb223914.xml'
    %'c:\remote\settings202620Feb091315.xml'
    %'c:\remote\settings202626Feb141236.xml'

    %'c:\remote\settings202601Mar194209.xml'
    %'c:\remote\settings202605Mar102239.xml'
    %'c:\remote\settings202604Mar105617.xml'
    %'c:\remote\settings202604Mar144909.xml'
    %'c:\remote\settings202604Mar111914.xml'
    %'c:\remote\settings202604Mar112240.xml'


    %c:\remote\settings202617Mar154257.xml (6.5)
    %c:\remote\settings202619Mar150600.xml (6.52)
    


end
%spp = shots_per_point/2s

% if mod((i-1),shots_per_point) < spp
%     sequence = {'k=+1,0,-1','const'}; %Construct desired experimental sequenc from sequences above
% else
%     sequence = {'k=0,-1','mirror'};
% end
% sequence = {'mag_k=-1','const','k=+1,0,-1','mirror','splitter'}
% marker = mod(floor((i-1)/shots_per_point), num_points)+1; 
% 
% new_path ='c:\remote\settings202507Jan121233.xml'%'c:\remote\settings202427Aug173019.xml';%c:\remote\settings202001Sep155855.xml 'c:\remote\settings202429Feb143702.xml'

%% Keysight settings
% General settings
sample_rate=1e9;
max_points=double(4e6);
points_min=double(32);
repeats_max=1e6;
f0_AOM=80e6;            % [Hz]     Central AOMs frequency 
Ek=84.9e3;              % beam geometry (90 deg)
srate_all=sample_rate;
ampfun = @(b,x) b(1).*x(:,1).^b(2);


%%% MAGNETIC TRANSFER pulse
%--------------------------------------------------------------------------

B_trap_bottom= 788e3;%495e3; %392e3;%
del = 84.96e3;% %detuning for second beam 3e3
del2 = 0;
T_pulse_del = 0.0e-6;%delay between pulses
dF_Raman= (B_trap_bottom) - del;     %[Hz]    Raman detuning
T_Raman_mix=100e-6;%;
Gs_mod_R_mix= 4.2e-6;% 
phi1_mix = pi;
phi2=0;
K_R_mix=0.48;%0.095;%%0.095;%0.4;%0.338;%0.338;%0.34063277;%0.31

f1_Raman_mix=f0_AOM+dF_Raman/2;     %[Hz]    45(P) RAMAN   "top"                          45(S) RAMAN   "top"
f2_Raman_mix=f0_AOM-dF_Raman/2;     %[Hz]   -45(S) RAMAN   "horizontal"                 -45(P) RAMAN   "horizonatal"


B_trap_bottom_intrap=4.2e6;%1.025e6;%1.0603782e6;
dF_Raman_in_trap=-(B_trap_bottom_intrap);     %[Hz]    Raman detuning
f1_Raman_mix_in_trap=f0_AOM-dF_Raman_in_trap/2-del;     %[Hz]    45(P) RAMAN   "top"                          45(S) RAMAN   "top"
f2_Raman_mix_in_trap=f0_AOM+dF_Raman_in_trap/2;     %[Hz]   -45(S) RAMAN   "horizontal"                 -45(P) RAMAN   "horizonatal"

%%% DELAYs between pulses
%--------------------------------------------------------------------------
% T_delay_mix=3000e-6;      % Delay between the SRC and MIX pulse

T_delay = 2.10e-3;   %duration of 'const' pulse
T_delay_mix=0;      % Delay between the MAG and Bragg pulse
T_delay_mirror=220e-6;%1500e-6;%500e-6; % Delay between the Bragg pulse and Mirror pulse
T_delay_splitter=150e-6;

%%% phases
%--------------------------------------------------------------------------
% NOTE: separated out since we find zero gives fine results
phi1_Bragg=0;
phi2_Bragg=0;

phi1_mirror=0;
phi2_mirror=0;
phi_floquet_mirror = 0;


globalphase_vec = [-pi/4]%[-pi,0,-pi/2,pi,pi/2]%,3*pi/4,3*pi/4]%,pi,pi/2]%3*pi/2,5*pi/4,2*pi,0,pi/2]%,3*pi/4,5*pi/4,pi]%-3*pi/4,-pi/2,-pi/2,0,pi];%[-pi/2,3*pi/2]%[3*pi/7, pi, 7*pi/4,2*pi];%[0, 3*pi/7, 3*pi/4, pi, 4*pi/3, 7*pi/4]

% phi1_splitter=pi;%5*pi/14;
% phi2_splitter=0;%2*pi/14;

if marker == 6
    phi1_splitter= 3/2;
    phi2_splitter=0;
    phi_floquet_splitter = 0;

elseif marker == 1
    phi1_splitter= -pi/8;%-pi/2;
    phi2_splitter= 0;%0;%2*pi/14;
    phi_floquet_splitter = 7*pi/16;%pi/4;

elseif marker == 3
    phi1_splitter=-pi/4;
    phi2_splitter=0;
    phi_floquet_splitter = 3*pi/8;%-9*pi/16;

%     phi1_splitter=-pi/8;
%     phi2_splitter=0;
%     phi_floquet_splitter = -3*pi/16 ;

%     phi1_splitter=pi/2;
%     phi2_splitter=pi/4;
%     phi_floquet_splitter = -3*pi/8;

elseif marker == 4
    phi1_splitter=0;
    phi2_splitter=0;
    phi_floquet_splitter = pi/2;%-pi/2;


elseif marker == 2
    phi1_splitter=pi;
    phi2_splitter=pi/2;
    phi_floquet_splitter = 3*pi/4;%-5*pi/8;


elseif marker == 5
    phi1_splitter=pi/4;
    phi2_splitter=0;
    phi_floquet_splitter = 5*pi/8;

%     phi1_splitter=7*pi/8;
%     phi2_splitter=0;
%     phi_floquet_splitter = -11*pi/16;

%     phi1_splitter=3*pi/4;
%     phi2_splitter=0;
%     phi_floquet_splitter = -5*pi/8;

%     phi1_splitter=pi/4;
%     phi2_splitter=pi/8;
%     phi_floquet_splitter = -5*pi/16;

%     phi1_splitter=pi;
%     phi2_splitter=pi/2;
%     phi_floquet_splitter = -pi/2;


end


%%% MIRROR pulse
%--------------------------------------------------------------------------
dF_Bragg_1=217e3/2;%229e3/2;%0.0849e6;%
dF_Bragg_2=217e3/2;%229e3/2;%0.12e6;%0.0849e6;%
f1_Bragg_mirror=f0_AOM-dF_Bragg_1;
f2_Bragg_mirror=f0_AOM+dF_Bragg_2;
f3_mirror_floquet = 42e3/2;

fsinc_Bragg = 0e3/2;

T_Bragg_mirror=200e-6;%32E-6;
%P_Bragg_src = 7.0; %power in mW 7 to 9 works well ~5.9
K_Bragg_mirror_1=0.29;%33;%ampfun([60.117, 0.5638],P_Bragg_src)/2e3;
K_Bragg_mirror_2=0.29;%33;%ampfun([132.62, 0.5283],P_Bragg_src)/2e3;
Gs_mod_Bragg_mirror_1=32e-6;%7.68e-6;%1.95*T_Bragg_mirror/16.7e-6*sqrt(2)*sqrt(5.63806937736142e-01);%~1.83
Gs_mod_Bragg_mirror_2=32e-6;%7.68e-6;%1.95*T_Bragg_mirror/16.7e-6*sqrt(2)*sqrt(5.28341254744861e-01);%~1.83

Chirp_grad_mirror=0;
%t0_Bragg_mirror=nan;%3.9895e-6;

%sinc_scale_Bragg_mirror= 6e-6;%5.5e-6;%5.3e-6;%5.3e-6;
%Amp_sinc_Bragg_mirror=sqrt(5);%sqrt(10.0);%0.2;%

wf_mirror_pulse = @(b,t) exp(-((t-b(1)/2)./b(4)).^2).*b(3);
wf_mirror_pulse_1 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));
wf_mirror_pulse_2 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));

%wf_mirror_pulse_d = @(b,t) sinc((t-b(1)/2)./b(4)).*b(3).*cos(pi*(t-b(1)/2)/(b(1))).^2;
%wf_mirror_pulse_1 = @(b,t) ampfun([60.117, 0.5638],abs(wf_mirror_pulse_d(b,t)).^2)/2e3.*sin(2*pi*b(2)*t).*sign(wf_mirror_pulse_d(b,t));%sinc((t-b(1)/2)./b(4)).*b(3).*sin(2*pi*b(2)*t);%
%wf_mirror_pulse_2 = @(b,t) ampfun([132.62, 0.5283],abs(wf_mirror_pulse_d(b,t)).^2)/2e3.*sin(2*pi*b(2)*t).*sign(wf_mirror_pulse_d(b,t));%sinc((t-b(1)/2)./b(4)).*b(3).*sin(2*pi*b(2)*t);%

%%% 50:50 Beam Splitter pulse
%--------------------------------------------------------------------------
dF_Bragg_1=222e3/2;%236e3/2;%18e3;%17
dF_Bragg_2=222e3/2;%236e3/2;%18e3;%17
f1_Bragg_splitter=f0_AOM-dF_Bragg_1;
f2_Bragg_splitter=f0_AOM+dF_Bragg_2;
f3_splitter_floquet = 42e3/2;

T_Bragg_splitter=200e-6;%10E-6;%35E-6;
t0_Bragg_splitter=nan;

sinc_scale_Bragg_splitter_1=30.5e-6;%4.2e-6;
sinc_scale_Bragg_splitter_2=30.5e-6;%4.2e-6;

Amp_sinc_Bragg_splitter_1=0.21;
Amp_sinc_Bragg_splitter_2=0.21;

Chirp_grad_splitter = 0;%7.6e6;

% wf_splitter_pulse = @(b,t) sinc((t-b(1)/2)./b(4)).*b(3);
wf_mirror_pulse = @(b,t) exp(-((t-b(1)/2)./b(4)).^2).*b(3);%

wf_splitter_pulse_1 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));
wf_splitter_pulse_2 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));



%%% Momentum splitting
%--------------------------------------------------------------------------

%%% Bragg splitting: |k=0> |--> |k=0> + |k=-1K> + |k=-2K>
dF_Bragg_1=0.095e6;%0.099e6;%~0.093;%
dF_Bragg_2=0.095e6;%0.099e6;
f1_Bragg_src_f=f0_AOM+dF_Bragg_1;
f2_Bragg_src_f=f0_AOM-dF_Bragg_2;

T_Bragg_src_f=32E-6;
P_Bragg_f = 7.2;%7.2;%20.5;%~7.8
K_Bragg_src_f_1=1.25*ampfun([60.117, 0.5638],P_Bragg_f)/2e3;%0.08;
K_Bragg_src_f_2=1.33*ampfun([132.62, 0.5283],P_Bragg_f)/2e3;%0.08;%[60.117, 0.5638] multiplier ~1.2 1.4
Gs_mod_Bragg_src_f_1=0.9*T_Bragg_src_f/4.2E-6*sqrt(2)*sqrt(5.63806937736142e-01);%~0.7 0.95
Gs_mod_Bragg_src_f_2=0.9*T_Bragg_src_f/4.2E-6*sqrt(2)*sqrt(5.28341254744861e-01);
t0_Bragg_src_f=nan;

%--------------------------------------------------------------------------
%%% Bragg splitting: |k=0> |--> |k=+1K> + |k=0> + |k=-1K>
random_manual_delta = 0.0;%0.01;

dF_Bragg_sym = 212e3/2;
dF_Bragg_1 = dF_Bragg_sym;
dF_Bragg_2 = dF_Bragg_sym;
f1_Bragg_sym_f=f0_AOM-dF_Bragg_1;
f2_Bragg_sym_f=f0_AOM+dF_Bragg_2;


T_Bragg_sym_f=60e-6;%60e-6;

K_Bragg_sym_f_1= 0.35;%0.6
K_Bragg_sym_f_2= 0.35;%0.6

Gs_mod_Bragg_sym_f_1=2.5e-6;%2.5e-6;
Gs_mod_Bragg_sym_f_2=2.5e-6;%2.5e-6;
t0_Bragg_sym_f=nan;

wf_mirror_pulse = @(b,t) exp(-((t-b(1)/2)./b(4)).^2).*b(3);%

wf_bragg_sym_pulse = @(b,t) sinc((t-b(1)/2)./b(4)).*b(3);%.*cos(pi*(t-b(1)/2)/(b(1))).^2;
wf_bragg_sym_pulse_1 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));
wf_bragg_sym_pulse_2 = @(b,t) wf_mirror_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));


%%% Bragg splitting: |k=0> |--> |k=0> + |k=-1K>
%dF_Bragg_1=0.06e6;
%dF_Bragg_2=0.06e6;
dopp_shft = 235e3%220e3;
dF_Bragg_1= (84.96e3+dopp_shft)/2; %84.96e3-
dF_Bragg_2= (84.96e3+dopp_shft)/2; %84.96e3-

f1_Bragg_src_t=f0_AOM-dF_Bragg_1;
f2_Bragg_src_t=f0_AOM+dF_Bragg_2;

T_Bragg_src_t=200e-6;
P_Bragg_src = 3.6; %power in mW 7 to 9 works well
K_Bragg_src_1=0.3%ampfun([60.117, 0.5638],P_Bragg_src)/2e3;
K_Bragg_src_2=0.3%ampfun([132.62, 0.5283],P_Bragg_src)/2e3;
Gs_mod_Bragg_src_1=5.4e-6;%1.82*T_Bragg_src_t/16.7e-6*sqrt(2)*sqrt(5.63806937736142e-01);
Gs_mod_Bragg_src_2=5.4e-6;%1.81*T_Bragg_src_t/16.7e-6*sqrt(2)*sqrt(5.28341254744861e-01);

t0_Bragg_src_t=nan;

wf_Bragg_t_pulse = @(b,t) exp(-((t-b(1)/2)./b(4)).^2).*b(3);%
wf_Bragg_src_t_pulse_1 = @(b,t) wf_Bragg_t_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));
wf_Bragg_src_t_pulse_2 = @(b,t) wf_Bragg_t_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));


%%% Bragg splitting: |k=0> |--> |k=-1K> + |k=-2K>
dF_Bragg_1=0.085e6;
dF_Bragg_2=0.075e6;
f1_Bragg_src_b=f0_AOM-dF_Bragg_1;
f2_Bragg_src_b=f0_AOM+dF_Bragg_2;

T_Bragg_src_b=10.2e-6;
K_Bragg_src_b=0.24;
Gs_mod_Bragg_src_b=3.0;

%%% Bragg splitting: |k=0> |--> |k=0> + |k=+1K>

dopp_shft = 24e3;
dF_Bragg_1= (84.96e3-dopp_shft)/2; %84.96e3-
dF_Bragg_2= (84.96e3-dopp_shft)/2; %84.96e3-
f1_Bragg_src_up=f0_AOM+dF_Bragg_1;
f2_Bragg_src_up=f0_AOM-dF_Bragg_2;

T_Bragg_src_up= 200e-6;
% P_Bragg_src = 5.8;%25;%4.8; %4.2; %power in mW 7 to 9 works well 4.93
K_bragg_vec = [0.6:0.02:0.78];
K_Bragg_src_1_up= 0.64;
K_Bragg_src_2_up= 0.64;

%Gs_mod_vec = [0:0.4:14];
Gs_mod_Bragg_src_1_up=5e-6;
Gs_mod_Bragg_src_2_up=5e-6;

t0_Bragg_src_up=nan;
wf_Bragg_up_pulse = @(b,t) exp(-((t-b(1)/2)./b(4)).^2).*b(3);%
wf_Bragg_src_up_pulse_1 = @(b,t) wf_Bragg_up_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));
wf_Bragg_src_up_pulse_2 = @(b,t) wf_Bragg_up_pulse(b,t).*sin(2*pi.*(b(2)-b(6).*t).*t+b(5));


%-------------------------------------------------------------------------------
%%%% Double freq pulse:
dF_Bragg_1=226e3/2; 
dF_Bragg_2=226e3/2; 
f1_Bragg_modulated=f0_AOM-dF_Bragg_1;
f2_Bragg_modulated=f0_AOM+dF_Bragg_2;

f3_Bragg_floquet = 42e3/2;%42e3/2
fsinc_Bragg = 45e3/2;

T_Bragg_modulated=200e-6;
t0_Bragg_mirror=nan;

Gs_Bragg_modulated_1=31e-6;%31e-6
Gs_Bragg_modulated_2=31e-6;%31e-6

Amp_Bragg_modulated_1=0.25;%0.2
Amp_Bragg_modulated_2=0.25;%0.2

phi_modulated_1=0;
phi_modulated_2=0;
phi_floquet = 0;

chirp_rate = 0;%12.8e6;

wf_amp_modulated = @(b,t) (exp(-((t-b(1)/2)./b(4)).^2).*b(3)).*cos(2*pi.*(b(7).*(t-b(1)/2))+b(8));


%%% PAL settings
%--------------------------------------------------------------------------
freq = 1.2e6;
amp_PAL = sqrt(2)*0.650; %Vrms
phase_PAL = 0;
cycles = 6;
dur_PAL = cycles/freq;

%% Iteration through parameters
Amp_sinc_Bragg_mirror_vec = flip(sqrt([0 0.25 10 19]));
Amp_sinc_Bragg_mirror = Amp_sinc_Bragg_mirror_vec(1);%marker

% dF_Bragg_vec = [1.5:0.01:1.8];%[0.5:0.05:3];
%Gs_mod_Bragg_sym_vec = [0:0.5:6];%[0:0.5:30, 31:1:120];%[0:2:50];%[0:0.1:20, 20.2:0.2:50];%[0:0.5:50];

%Gs_mod_Bragg_sym_f_1= Gs_mod_Bragg_sym_vec(marker) * 1e-6;
%Gs_mod_Bragg_sym_f_2= Gs_mod_Bragg_sym_vec(marker) * 1e-6;

% f1_Bragg_sym_f=f0_AOM-dF_Bragg_vec(marker)*1e6;
% f2_Bragg_sym_f=f0_AOM+dF_Bragg_vec(marker)*1e6;

% df_vec = [3.3:0.01:3.51];
% 
% dF_Bragg_sym = (df_vec(marker)-0.085)*1e6/4;
% 
% dF_Bragg_1 = dF_Bragg_sym;
% dF_Bragg_2 = dF_Bragg_sym;
% f1_Bragg_sym_f=f0_AOM-dF_Bragg_1;
% f2_Bragg_sym_f=f0_AOM+dF_Bragg_2;


%% Waveform generation
ch1_raw={}; %waveform for chanel 1
ch2_raw={}; %waveform for chanel 2
for ii = 1:length(sequence) %run through each segment
    segment = sequence{ii}; %the current segment
    switch segment %add to the waveforms the desired segment
        case 'const'
            %%% A constant delay
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay}}%{'arb',nullfun, srate_all,T_delay, 0}}
                ];
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay}}%{{'arb',nullfun, srate_all,T_delay, 0}}
                ];

        case 'mag_transfer'
            %%% Magentic transfer
            ch1_raw=[ch1_raw(:)',...
                {{'double_sine',f1_Raman_mix,f2_Raman_mix,phi1_mix,phi2,K_R_mix,...
                K_R_mix,Gs_mod_R_mix,Gs_mod_R_mix,srate_all,T_Raman_mix,T_pulse_del}}
                ];
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_Raman_mix+abs(T_pulse_del)}}
                ];

        case 'mag_k=-1'
            %%% Top Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',  wf_Bragg_src_t_pulse_1,  srate_all,  T_Raman_mix,  f1_Raman_mix,  K_R_mix,  Gs_mod_R_mix, phi1_mix,0}}
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',  wf_Bragg_src_t_pulse_2,  srate_all,  T_Raman_mix,  f2_Raman_mix,  K_R_mix,  Gs_mod_R_mix, phi2,0}}
                ];



        case 'k=0,-1,-2'
            %%% Full Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'sine',    f1_Bragg_src_f       ,phi1,          K_Bragg_src_f_1,       Gs_mod_Bragg_src_f_1, srate_all,   T_Bragg_src_f,   t0_Bragg_src_f}},...
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'sine',    f2_Bragg_src_f       ,phi2,          K_Bragg_src_f_2,       Gs_mod_Bragg_src_f_2, srate_all,   T_Bragg_src_f,    t0_Bragg_src_f}},...
                ];

        case 'k=0,-1'
            %%% Top Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',  wf_Bragg_src_t_pulse_1,  srate_all,  T_Bragg_src_t,  f1_Bragg_src_t,  K_Bragg_src_1,  Gs_mod_Bragg_src_1, phi1_Bragg,0}}
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',  wf_Bragg_src_t_pulse_2,  srate_all,  T_Bragg_src_t,  f2_Bragg_src_t,  K_Bragg_src_2,  Gs_mod_Bragg_src_2, phi2_Bragg,0}}
                ];

%             ch1_raw=[ch1_raw(:)',...
%                 {{'const',0, srate_all,T_delay_mix}},...
%                 {{'sine',    f1_Bragg_src_t       ,phi1,          K_Bragg_src_1,       Gs_mod_Bragg_src_1, srate_all,   T_Bragg_src_t, t0_Bragg_src_t}},...
%                 ];
%             
%             ch2_raw=[ch2_raw(:)',...
%                 {{'const',0, srate_all,T_delay_mix}},...
%                 {{'sine',    f2_Bragg_src_t       ,phi2,          K_Bragg_src_2,       Gs_mod_Bragg_src_2, srate_all,   T_Bragg_src_t, t0_Bragg_src_t}},...
%                 ];

        case 'k=+1,0'
            %%% Top Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',   wf_Bragg_src_up_pulse_1,  srate_all,  T_Bragg_src_up,  f1_Bragg_src_up,  K_Bragg_src_1_up,  Gs_mod_Bragg_src_1_up, phi1_Bragg,0}}
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',   wf_Bragg_src_up_pulse_2,  srate_all,  T_Bragg_src_up,  f2_Bragg_src_up,  K_Bragg_src_2_up,  Gs_mod_Bragg_src_2_up, phi2_Bragg,0}}
                ];
        case 'k=-1,-2'
            %%% Bottom Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'sine',    f1_Bragg_src_b       ,phi1,          K_Bragg_src_b,       Gs_mod_Bragg_src_b, srate_all,   T_Bragg_src_b}},...
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_Raman_mix+abs(T_pulse_del)}},...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'sine',    f2_Bragg_src_b       ,phi2,          K_Bragg_src_b,       Gs_mod_Bragg_src_b, srate_all,   T_Bragg_src_b}},...
                ];

        case 'k=+1,0,-1'
            %%% Full Halo
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',   wf_bragg_sym_pulse_1,  srate_all,  T_Bragg_sym_f,  f1_Bragg_sym_f,  K_Bragg_sym_f_1,  Gs_mod_Bragg_sym_f_1, phi1_Bragg,0}}
                ];
            
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mix}},...
                {{'arb',   wf_bragg_sym_pulse_2,  srate_all,  T_Bragg_sym_f,  f2_Bragg_sym_f,  K_Bragg_sym_f_2,  Gs_mod_Bragg_sym_f_2, phi2_Bragg,0}}
                ];

        case 'mirror'
            %%% Mirror pulse
%             ch1_raw=[ch1_raw(:)',...
%                 {{'const',0, srate_all,T_delay_mirror}},...
%                 {{'arb',   wf_mirror_pulse_1,  srate_all,  T_Bragg_mirror,  f1_Bragg_mirror,  K_Bragg_mirror_1,  Gs_mod_Bragg_mirror_1, phi1_mirror,0}}
%                 ];
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_mirror}},...
                {{'floquet1',  wf_amp_modulated,  srate_all,  T_Bragg_mirror,  f1_Bragg_mirror,  K_Bragg_mirror_1,  Gs_mod_Bragg_mirror_1, phi1_mirror,Chirp_grad_mirror,f3_mirror_floquet,phi_floquet_mirror,fsinc_Bragg}} 
                ];

%             ch2_raw=[ch2_raw(:)',...
%                 {{'const',0, srate_all,T_delay_mirror}},...
%                 {{'arb',   wf_mirror_pulse_2,  srate_all,   T_Bragg_mirror, f2_Bragg_mirror,  K_Bragg_mirror_2,  Gs_mod_Bragg_mirror_2, phi2_mirror,0}}
%                 ];
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_mirror}},...
                {{'floquet2',  wf_amp_modulated,  srate_all,  T_Bragg_mirror,  f2_Bragg_mirror,  K_Bragg_mirror_2,  Gs_mod_Bragg_mirror_2, phi2_mirror,Chirp_grad_mirror,f3_mirror_floquet,phi_floquet_mirror,fsinc_Bragg}}
                ];

        case 'splitter'
            %%% 50:50 Beam splitter pulse %                 {{'arb',ampfun, srate_all,T_delay_splitter, 0}}
%             ch1_raw=[ch1_raw(:)',...
%                 {{'const',0, srate_all,T_delay_splitter}},...
%                 {{'arb',   wf_splitter_pulse_1,  srate_all,  T_Bragg_splitter,  f1_Bragg_splitter,  Amp_sinc_Bragg_splitter_1,  sinc_scale_Bragg_splitter_1, phi1_splitter,Chirp_grad_splitter}}
%                 ];
            ch1_raw=[ch1_raw(:)',...
                {{'const',0, srate_all,T_delay_splitter}},...
                {{'floquet1',  wf_amp_modulated,  srate_all,  T_Bragg_splitter,  f1_Bragg_splitter,  Amp_sinc_Bragg_splitter_1,  sinc_scale_Bragg_splitter_1, phi1_splitter,Chirp_grad_splitter,f3_splitter_floquet,phi_floquet_splitter,fsinc_Bragg}}
                ];
            
%             ch2_raw=[ch2_raw(:)',...
%                 {{'const',0, srate_all,T_delay_splitter}},...
%                 {{'arb',   wf_splitter_pulse_2,  srate_all,   T_Bragg_splitter, f2_Bragg_splitter,  Amp_sinc_Bragg_splitter_2,  sinc_scale_Bragg_splitter_2, phi2_splitter,Chirp_grad_splitter}}
%                 ];
            ch2_raw=[ch2_raw(:)',...
                {{'const',0, srate_all,T_delay_splitter}},...
                {{'floquet2',  wf_amp_modulated,  srate_all,  T_Bragg_splitter,  f2_Bragg_splitter,  Amp_sinc_Bragg_splitter_2,  sinc_scale_Bragg_splitter_2, phi2_splitter,Chirp_grad_splitter,f3_splitter_floquet,phi_floquet_splitter,fsinc_Bragg}}
                ];

        otherwise
            error('invalid sequence segment');
    end
end

%% Shot sequence settings
path_log = 'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\log_LabviewMatlab.txt';
path_param_log = 'Y:\TDC_user\ProgramFiles\my_read_tdc_gui_v1.0.1\dld_output\log_KeysightMatlab.txt';

%% convert waveforms to printables for logging
ch1_waveform_str = '';
ch2_waveform_str = '';
addpath('C:\Users\BEC Machine\Documents\MATLAB\Momentum_Bells_test\dev')
addpath('C:\Users\BEC Machine\cloudstor\PROJECTS\keysight-33600a\ch_to_waveforms.m')
for waveforms = 1:numel(ch1_raw)
    if waveforms>1
        ch1_waveform_str = [ch1_waveform_str,', '];
    end
    ch1_waveform_str = [ch1_waveform_str,cell2str(array2str(ch1_raw{waveforms}))];
end
for waveforms = 1:numel(ch2_raw)
    if waveforms>1
        ch2_waveform_str = [ch2_waveform_str,', '];
    end
    ch2_waveform_str = [ch2_waveform_str,cell2str(array2str(ch2_raw{waveforms}))];
end

ch1_waveform_str = replace(ch1_waveform_str,"'",'');
ch2_waveform_str = replace(ch2_waveform_str,"'",'');

%% Interface

addpath('C:\Users\BEC Machine\OneDrive - Australian National University\PROJECTS\keysight-33600a')%C:\Users\BEC Machine\OneDrive - Australian National University\PROJECTS\keysight-33600a\WaveformGenMain.m
%C:\Users\BEC Machine\cloudstor\MATLAB\keysight-33600a
% shot_info = shots.(shot_sequence{1});
% new_path=shot_info.LVfile;
% Send waveforms
chanels_dev1={ch_to_waveforms(ch1_raw),ch_to_waveforms(ch2_raw)};
if update_keysight && (mod((i-1-shot_offset),shots_per_point) == 0 || (i-1) == 0) 
    plot_segments(chanels_dev1,1);
    send_segments(chanels_dev1,1);
end


%write to log
%write to log
f1_log=fopen(path_log,'a');  % append to log-file
nowdt=datetime('now');
fprintf(f1_log,'shot num:%d, posixtime:%.3f, date:%s, matlab:ML_interface_RT, sequence:%s, global_phase:%.4f , theta:%.4f, phi_floquet:%.4f, labview settings:%s\n',...
    shot_numb,posixtime(nowdt),datestr(nowdt,'yyyy-mm-ddTHH:MM:SS.FFF'),sequence{end},globalphase_vec(marker),phi1_splitter-phi2_splitter,phi_floquet_splitter, new_path);
fclose(f1_log);
pause(0.1)

f_log=fopen(path_param_log,'a');  % append to param-log-file
fprintf(f_log,'shot num:%d, posixtime:%.3f, ch1 waveform: %s, ch2 waveform: %s\n',...
    shot_numb,posixtime(nowdt),...
    ch1_waveform_str,ch2_waveform_str);
fclose(f_log);
pause(0.1)