clc;clearvars;close all;
ch_func = Channel_functions();
est_func = Estimation_functions();
%% Simulation Parameters
ChType   = 'RTV';                      % Channel model
fs       = 64*156250;                  % Sampling frequency in Hz, here case of 802.11p with 64 subcarriers and 156250 Hz subcarrier spacing
fc       = 5.2e9;                      % Carrier Frequecy in Hz.
v        = 0;                          % Moving speed of user in km/h
c        = 3e8;                        % Speed of Light in m/s
fD       = (v/3.6)/c*fc;               % Doppler freq in Hz
rchan    = ch_func.GenFadingChannel(ChType, fD, fs); % Channel generation
K        = 64;                         % Number of subcarriers
K_cp     = K/4;                        % Number of cyclic prefix subcarriers

% Pre-defined preamble in frequency domain
dp       = [ 0  0 0 0 0 0 +1 +1 -1 -1 +1  +1 -1  +1 -1 +1 +1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1 +1 +1 +1 0 +1 -1 -1 +1 +1 -1 +1 -1 +1 -1 -1 -1 -1 -1 +1 +1 -1 -1 +1 -1 +1 -1 +1 +1 +1 +1 0 0 0 0 0];
Kset     = find(dp~=0);                % Active subcarriers
Kon      = length(Kset);               % Number of active subcarriers
Ep       = 1;                          % preamble power
dp       = sqrt(Ep)*dp.';              % Normalization
xp       = ifft(dp);                   % Frequency-Time conversion
xp_cp    = [xp(end-K_cp+1:end); xp];   % Adding CP 
SNR_p    = (0:5:30)';                  % SNR range
N_SNR    = length(SNR_p);              % SNR length
N0       = Ep/K*10.^(-SNR_p/10);       % Noise power : snr_p = Ep/KN0 => N0 = Ep/(K*snr_p)

N_CH     = 1000;                       % Number of channel realizations
Err_Ls   = zeros(N_SNR,1);             % LS NMSE vector
Err_MMSE = zeros(N_SNR,1);             % MMSE NMSE vector
Phf      = zeros(N_SNR,1);             % Average channel power E(|hf|^2)

%% Rh estimation
release(rchan);
init_seed   = 22;
rchan.Seed  = init_seed;
Rh          = est_func.Estimat_Rh(rchan, K_cp, K, Kset);
release(rchan);
rchan.Seed  = init_seed;

%% Main Simulation 
for n_snr = 1:N_SNR
    Hfe_LS = zeros(Kon, N_CH);
    Hfe_MMSE = zeros(Kon, N_CH);
    Hf =  zeros(Kon, N_CH);
    % MMSE filter varies with SNR
    W = est_func.MMSE_matrix (dp(Kset), Rh, Ep/N0(n_snr)/K);
    for n_ch = 1:N_CH % loop over channel realizations
        % ideal estimation
        [ h, y ] = ch_func.ApplyChannel( rchan, xp_cp, K_cp);
        release(rchan);
        rchan.Seed = rchan.Seed+1;
        
        yp = y((K_cp+1):end);
        h = h((K_cp+1):end);
        yfp = fft(yp); % FD preamble
        hf = fft(h); % Fd channel
        Phf(n_snr)  = Phf(n_snr)  + norm(hf(Kset))^2;
        
         %add noise
         yfp_r = yfp+ sqrt(K*N0(n_snr))*ch_func.GenRandomNoise([1,1], 1);
         
         
         %LS estimation
         [hfe_ls, err_ls] = est_func.LS(yfp_r(Kset), dp(Kset), hf(Kset));
         Err_Ls (n_snr) = Err_Ls (n_snr) + err_ls;
         
         %MMSE estimation
         [hfe_mmse, err_mmse] = est_func.MMSE(yfp_r(Kset), W, hf(Kset));
         Err_MMSE (n_snr) = Err_MMSE (n_snr) + err_mmse;
          
         % save the channels for further use
         Hf(:,n_ch) = hf(Kset);
         Hfe_LS(:,n_ch) = hfe_ls;
         Hfe_MMSE(:,n_ch) = hfe_mmse; 
    end
end

%% Averaging over channel realizations
Phf       = Phf/N_CH;
Err_Ls    = Err_Ls/N_CH;
Err_MMSE  = Err_MMSE/N_CH;

%% Theorectical LS NMSE Calculation
Err_Ls_th = Kon*K*N0/Ep;

%% Theorectical MMSE NMSE Calculation
release(rchan);
init_seed = 22;
rchan.Seed = init_seed;
Rh = est_func.Estimat_Rh(rchan, K_cp, K, Kset);
release(rchan);
rchan.Seed = init_seed;
Sig = real(eig(Rh));
Err_MMSE_th = zeros(N_SNR,1);
for n_snr = 1:N_SNR
    Err_MMSE_th(n_snr) = Err_MMSE_th(n_snr) + sum(Sig./(Sig+K*N0(n_snr)./Ep));
end
Err_MMSE_th = K*N0/Ep .* Err_MMSE_th;

%% Normalization by Channel Power 
Err_LSth          = Err_Ls_th./Phf;
Err_LSsim         = Err_Ls./Phf;
Err_MMSEth        = Err_MMSE_th./Phf;
Err_MMSEsim       = Err_MMSE./Phf;

%% Plotting NMSE Results
figure,
semilogy(SNR_p, Err_LSth ,'k--','LineWidth',2);
hold on;
semilogy(SNR_p,Err_LSsim,'k+','LineWidth',2);
hold on;
semilogy(SNR_p,Err_MMSEth,'k--','LineWidth',2);
hold on;
semilogy(SNR_p,Err_MMSEsim,'ko','LineWidth',2);
hold on;
grid on;
legend('Analytical-Ls', 'sim-LS', 'Analytical-MMSE', 'sim-MMSE')
xlabel('Preamble SNR')
ylabel('Average Error per subcarrier')