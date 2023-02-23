import pickle
from scipy.io import loadmat
import numpy as np
import scipy.io
from keras.models import load_model
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import os
snr = np.arange(1, 8)
t_snr = 7
for j in snr:
    dataset_path = './DNN_Dataset_{}.mat'.format(j)
    mat = loadmat(dataset_path)
    Dataset = mat['Preamble_Error_Correction_Dataset']
    Dataset = Dataset[0, 0]
    X = Dataset['X']
    Y = Dataset['Y']
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

    source_name = './DNN_Results_{}.pickle'.format(j)
    dest_name = './DNN_Results_{}.mat'.format(j)
    a = pickle.load(open(source_name, "rb"))
    scipy.io.savemat(dest_name, {
        'test_x_{}'.format(j): a[0],
        'test_y_{}'.format(j): a[1],
        'corrected_y_{}'.format(j): a[2]
    })
    print("Data successfully converted to .mat file ")
    print("Data successfully converted to .mat file ")
    os.remove(result_path)













