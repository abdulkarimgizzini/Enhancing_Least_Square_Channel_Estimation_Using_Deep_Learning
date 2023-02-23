clc;clearvars;close all;
DNN_index = 30;
load('ErrSet');
SNR_p   = (0:5:30)';
%% 
N_SNR   = size(SNR_p,1);
Err_DNN = zeros(N_SNR,1);
Phf     = zeros(N_SNR,1);
for i = 1:size(SNR_p,1) 
    load(['./DNN_Results_' num2str(i)]);
    [O_HLS, O_Hf, Processed_DNN_H_HL ] = ProcessPythonData(eval(['test_x_',num2str(i)]),eval(['test_y_',num2str(i)]),eval(['corrected_y_',num2str(i)])); 
    Err_DNN (i) = Err_DNN(i)+ norm(O_Hf-Processed_DNN_H_HL).^2;
    Phf(i)  = Phf(i)  + norm(O_Hf)^ 2;
end

Err_DNN = Err_DNN ./ size (O_Hf,2);
Phf = Phf ./ size (O_Hf,2);
Err_DNN_normalized = Err_DNN ./ Phf;

figure,
semilogy(SNR_p, Err_LSth ,'k--','LineWidth',2);
hold on;
semilogy(SNR_p,Err_LSsim,'k+','LineWidth',2);
hold on;
semilogy(SNR_p,Err_MMSEth,'k--','LineWidth',2);
hold on;
semilogy(SNR_p,Err_MMSEsim,'ko','LineWidth',2);
hold on;
semilogy(SNR_p,Err_DNN_normalized,'r-d','LineWidth',2);
grid on;
legend('Analytical-Ls', 'sim-LS', 'Analytical-MMSE', 'sim-MMSE',['DNN' num2str(DNN_index)],'location','best')
xlabel('SNR (dB)')
ylabel('NMSE')


function [Processed_Orginal_Testing_X,Processed_Orginal_Testing_Y,Predicted_Testing_Y] =ProcessPythonData(a,b,c)


Testing_Channels_X = a.';
testing_real_X = Testing_Channels_X(1:52,:);
testing_imag_X = Testing_Channels_X(53:104,:);
Processed_Orginal_Testing_X = testing_real_X + 1i *  testing_imag_X;


Testing_Channels_Y = b.';
testing_real_Y = Testing_Channels_Y(1:52,:);
testing_imag_Y = Testing_Channels_Y(53:104,:);
Processed_Orginal_Testing_Y = testing_real_Y + 1i *  testing_imag_Y;


Predicted_Channels = c.';
H_real2 = Predicted_Channels(1:52,:);
H_image2 = Predicted_Channels(53:104,:);
Predicted_Testing_Y = H_real2 + 1i *  H_image2;
end
