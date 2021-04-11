function func = Estimation_functions()
func.LS = @LS;
func.MMSE = @MMSE;
func.MMSE_matrix = @MMSE_matrix;
func.Estimat_Rh = @Estimat_Rh;
end
% LS estimation
function [he, err] = LS(yp, xp, h)
he = yp./xp;
err = norm(he-h)^2;
end

function [he, err] = MMSE(yp, W, h)
% W the MMSE filter generated from the preambles
he = W*yp;
err = norm (he-h)^2;
% correct bias 
end

function W = MMSE_matrix (xp, Rh, SNR)
K = size(Rh,1);
% to perform A*diag(xb)^{-1}
Lamp_p_inv = repmat(1./xp', K,1);
W = (Rh/(Rh + 1/SNR *eye(K))).*Lamp_p_inv;
end

function Rh = Estimat_Rh (rchan, K_cp, K, Kset)
% Kset active subcarriers
Kon = length(Kset);
Rh = zeros(Kon,Kon);
NR_CH = 1000;
% dummy signal
xp_cp = rand(K_cp+K,1);
for n_ch = 1:NR_CH % loop over channel realizations
    % ideal estimation
    ch_func = Channel_functions();
    [ h, ~ ] = ch_func.ApplyChannel( rchan, xp_cp, K_cp);
    release(rchan);
    rchan.Seed = rchan.Seed+1;
    
    h = h((K_cp+1):end);
    hf = fft(h); % Fd channel
    Rh = Rh + hf(Kset)*hf(Kset)';
end
Rh = Rh/NR_CH;
end
