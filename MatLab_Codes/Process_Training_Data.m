clc;
clearvars;
close all;
N_CH  = 1000;
SNR_p = 0:5:30;
k = 52;
X = zeros(k*2, N_CH);
Y = zeros(k*2, N_CH);

for n_snr = 1: size(SNR_p,2)

  load(['./Dataset_',num2str(n_snr),'.mat'], 'Hf', 'Hfe_LS');

  X(1:k,:)     = real(Hfe_LS);
  X(k+1:2*k,:) = imag(Hfe_LS);
  Y(1:k,:)     = real(Hf);
  Y(k+1:2*k,:) = imag(Hf);

  Preamble_Error_Correction_Dataset.('X') =  X.';
  Preamble_Error_Correction_Dataset.('Y') =  Y.';
  save(['./DNN_Dataset_' num2str(n_snr),'.mat'],  'Preamble_Error_Correction_Dataset');

end
