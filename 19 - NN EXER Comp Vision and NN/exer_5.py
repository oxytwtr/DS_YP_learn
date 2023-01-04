from tensorflow.keras import Sequential
from tensorflow.keras.layers import Dense, Flatten, GlobalAveragePooling2D, GlobalMaxPooling2D
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.resnet import ResNet50

import pandas as pd

RANDOM_STATE = 3141592654

def load_train(path):

    labels = pd.read_csv(path + 'labels.csv')
    
    train_datagen = ImageDataGenerator(validation_split=0.1,
                            #horizontal_flip=True, vertical_flip=True,
                            #rotation_range=45, 
                            #width_shift_range=0.2, height_shift_range=0.2,
                            rescale=1./255)

    train_datagen_flow = train_datagen.flow_from_dataframe(
        dataframe=labels,
        directory=path + 'final_files/',
        x_col='file_name',
        y_col='real_age',
        target_size=(224, 224),
        batch_size=16,
        class_mode='raw',
        subset='training',
        seed=RANDOM_STATE)
       
    return train_datagen_flow
    
def load_test(path):

    labels = pd.read_csv(path + 'labels.csv')
                            
    test_datagen = ImageDataGenerator(validation_split=0.1,
                            rescale=1./255)

    test_datagen_flow = test_datagen.flow_from_dataframe(
        dataframe=labels,
        directory=path + 'final_files/',
        x_col='file_name',
        y_col='real_age',
        target_size=(224, 224),
        batch_size=16,
        class_mode='raw',
        subset='validation',
        seed=RANDOM_STATE)
       
    return test_datagen_flow
	
def create_model(input_shape):

    # объявляем ResNet50, загрузка весов с сервера
    backbone = ResNet50(input_shape=input_shape,
                    weights='/datasets/keras_models/resnet50_weights_tf_dim_ordering_tf_kernels_notop.h5',
                    include_top=False) 
                    
    model = Sequential()
    
    # слои 

    model.add(backbone)
    model.add(GlobalMaxPooling2D())
    model.add(Dense(100, activation='linear')) 
 
    # конец слоев
    
    model.compile(optimizer=Adam(lr=0.0001), loss='mse', metrics=['mae']) 

    return model
	
def train_model(model, train_data, test_data, batch_size=None, epochs=5,
                steps_per_epoch=None, validation_steps=None):

    model.fit(train_data, 
              validation_data=test_data,
              steps_per_epoch=steps_per_epoch,
              batch_size=batch_size,
              validation_steps=validation_steps,
              verbose=2, epochs=epochs)

    return model