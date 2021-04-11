clc;
clearvars;
close all;

n_snr =7;

load(['Data\DNN_Dataset\HLS_',num2str(n_snr),'.mat'], 'Hf', 'Hfe_LS');

k = 52;
X = zeros(k*2, size(Hf,2));
Y = zeros(k*2, size(Hf,2));
for i = 1:size(X,2)
X(1:k,i)     = real(Hfe_LS(:,i));
X(k+1:2*k,i) = imag(Hfe_LS(:,i));
Y(1:k,i)     = real(Hf(:,i));
Y(k+1:2*k,i) = imag(Hf(:,i));
end
Preamble_Error_Correction_Dataset.('X') =  X;
Preamble_Error_Correction_Dataset.('Y') =  Y ;
save(['Data\DNN_Dataset\Dataset_' num2str(n_snr)],  'Preamble_Error_Correction_Dataset','-v7.3');