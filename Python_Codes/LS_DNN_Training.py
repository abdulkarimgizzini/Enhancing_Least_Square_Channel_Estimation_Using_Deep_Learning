import numpy as np
from keras.initializers import TruncatedNormal
from keras.layers import Dense
from keras.models import Sequential
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import h5py
from keras.callbacks import ModelCheckpoint

snr = 7 # SNR Index 1: 0dB, 2:5dB, 3:10dB, 4:20dB, etc...
# Load Matlab DataSets
mat = h5py.File('./MatLab_Codes/Data/DNN_Dataset/Dataset_{}.mat'.format(snr), 'r')
X = np.array(mat['Preamble_Error_Correction_Dataset']['X'])
Y = np.array(mat['Preamble_Error_Correction_Dataset']['Y'])
print('Loaded Dataset Inputs: ', X.shape)
print('Loaded Dataset Outputs: ', Y.shape)

# Normalizing Datasets
scalerx = StandardScaler()
scalerx.fit(X)
scalery = StandardScaler()
scalery.fit(Y)
XS = scalerx.transform(X)
YS = scalery.transform(Y)

# Split Data into train and test sets
seed = 7
train_X, test_X, train_Y, test_Y = train_test_split(XS, YS, test_size=0.2, random_state=seed)
print('Training samples: ', train_X.shape[0])
print('Testing samples: ', test_X.shape[0])

# Build the model.
init = TruncatedNormal(mean=0.0, stddev=0.05, seed=None)
model = Sequential([
    Dense(units=52, activation='relu', input_dim=104,
          kernel_initializer=init,
          bias_initializer=init),
    Dense(units=104, kernel_initializer=init,
          bias_initializer=init)
])

# Compile the model.
model.compile(loss='mean_squared_error', optimizer='adam', metrics=['acc'])
print(model.summary())


model_path = './LS_DNN_{}.h5'.format(snr)

# This check point saves the best DNN model with highest validation accuracy
checkpoint = ModelCheckpoint(model_path, monitor='val_acc',
                             verbose=1, save_best_only=True,
                             mode='max')
callbacks_list = [checkpoint]
# Train the model.
epoch = 500
batch_size = 32

model.fit(train_X, train_Y, epochs=epoch, batch_size=batch_size, verbose=2, validation_split=0.25,  callbacks=callbacks_list)
