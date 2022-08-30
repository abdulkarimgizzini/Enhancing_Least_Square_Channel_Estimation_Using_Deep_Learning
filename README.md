This repository includes the source code of the LS-DNN based channel estimators proposed in "Enhancing Least Square Channel Estimation Using Deep Learning" paper that is published in the proceedings of the 2020 IEEE 91st Vehicular Technology Conference (VTC2020-Spring) virtual conference. Please note that the Tx-Rx OFDM processing is implemented in Matlab (Matlab_Codes) and the LSTM processing is implemented in python (Keras) (Python_Codes).

### Matlab_Codes

1. Main_Simulation: includes the implementation of the OFDM Rx-Tx communications, as well as the LS and LMMSE channel estimation schemes. it is used to generate datasets.

2. Channel_functions: includes different channel models definitions.

3. Estimation_functions: includes LS, MMSE, Rh_calculation, W_MMSE_calculation functions.

4. Process_Training_Data: Convert generated datasets from complex domain to real domain.

5. DNN_Results_Processing: use it to process the DNN results, just you need to choose which DNN model you want to show by setting the DNN_index variable.
   Forexample if DNN_index = 30, then the results for the tranied DNN model on SNR = 30dB will be shown.

### Python_Codes

1. LS_DNN_Training: this file is used to train the LS_DNN model according to a specific SNR value, after that the trained LS_DNN is saved to be used later in the testing phase. 

2. LS_DNN_Testing: this file is used to test the trained LS_DNN model perfromance on the whole datasets for all the whole SNR range.
