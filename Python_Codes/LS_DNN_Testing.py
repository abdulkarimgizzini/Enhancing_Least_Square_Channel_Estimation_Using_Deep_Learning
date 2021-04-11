import pickle
import numpy as np
import scipy.io
from keras.models import load_model
import h5py
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

snr = np.arange(1, 7)
t_snr = 4
for j in snr:
    dataset_path = './MatLab_Codes/Data/DNN_Dataset/Dataset_{}.mat'.format(j)
    mat = h5py.File(dataset_path, 'r')
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
    print('Testing samples: ', test_X.shape[0])

    model = load_model('./LS_DNN_{}.h5'.format(t_snr))

    # Testing the model
    Y_pred = model.predict(test_X)
    Original_Testing_X = scalerx.inverse_transform(test_X)
    Original_Testing_Y = scalery.inverse_transform(test_Y)
    Prediction_Y = scalery.inverse_transform(Y_pred)

    result_path = './DNN_Results_{}.pickle'.format(j)
    with open(result_path, 'wb') as f:
        pickle.dump([Original_Testing_X, Original_Testing_Y, Prediction_Y], f)


for j in snr:
    source_name = './DNN_Results_{}.pickle'.format(j)
    dest_name = './DNN_Results_{}.mat'.format(j)
    a = pickle.load(open(source_name, "rb"))
    scipy.io.savemat(dest_name, {
        'test_x_{}'.format(j): a[0],
        'test_y_{}'.format(j): a[1],
        'corrected_y_{}'.format(j): a[2]
    })
    print("Data successfully converted to .mat file ")








