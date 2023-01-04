from tensorflow.keras import Sequential
from tensorflow.keras.layers import Conv2D, Flatten, Dense, AvgPool2D
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator

def load_train(path):
                            
    train_datagen = ImageDataGenerator(validation_split=0.25,
                            horizontal_flip=True, vertical_flip=True,
                            #rotation_range=90, 
                            width_shift_range=0.2, height_shift_range=0.2,
                            rescale=1./255)

    train_datagen_flow = train_datagen.flow_from_directory(
                            path,
                            target_size=(150, 150),
                            batch_size=16,
                            class_mode='sparse',
                            subset='training', seed=12345)
       
    return train_datagen_flow
	
def create_model(input_shape):
    model = Sequential()
        
    # слои 

    model.add(Conv2D(filters=8, kernel_size=(3, 3), padding='same',
                 activation="relu"))#, input_shape=input_shape))
    model.add(AvgPool2D(pool_size=(2, 2), strides=None, padding='same')) 

    model.add(Conv2D(filters=24, kernel_size=(3, 3), padding='valid', 
                 activation="relu"))
    model.add(AvgPool2D(pool_size=(2, 2), strides=None, padding='same')) 
    
    model.add(Conv2D(filters=48, kernel_size=(3, 3), padding='valid', 
                 activation="relu"))
    model.add(AvgPool2D(pool_size=(2, 2), strides=None, padding='same')) 

    model.add(Flatten())
    model.add(Dense(units=48, activation='relu'))
    model.add(Dense(units=24, activation='relu'))
    model.add(Dense(units=12, activation='softmax'))
  
    # конец слоев
    
    model.compile(optimizer=Adam(lr=0.001), loss='sparse_categorical_crossentropy', metrics=['acc']) 

    return model
	
def train_model(model, train_data, test_data, batch_size=None, epochs=10,
                steps_per_epoch=None, validation_steps=None):

    model.fit(train_data, 
              validation_data=test_data,
              steps_per_epoch=steps_per_epoch,
              batch_size=batch_size,
              validation_steps=validation_steps,
              verbose=2, epochs=epochs)

    return model