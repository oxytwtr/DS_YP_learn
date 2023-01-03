from tensorflow.keras import Sequential
from tensorflow.keras.layers import GlobalAveragePooling2D, Dense
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications.resnet import ResNet50

def load_train(path):
                            
    train_datagen = ImageDataGenerator(validation_split=0.1,
                            horizontal_flip=True, vertical_flip=True,
                            rotation_range=90, 
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

    # объявляем ResNet50, загрузка весов с сервера
    backbone = ResNet50(input_shape=input_shape,#(150, 150, 3),
                    weights='/datasets/keras_models/resnet50_weights_tf_dim_ordering_tf_kernels_notop.h5',
                    include_top=False) 
                    
    # замораживаем ResNet50 без верхушки
    #backbone.trainable = False

    model = Sequential()
    
    # слои 
    
    model.add(backbone)
    model.add(GlobalAveragePooling2D())
    model.add(Dense(12, activation='softmax')) 
 
    # конец слоев
    
    model.compile(optimizer=Adam(lr=0.0001), loss='sparse_categorical_crossentropy', metrics=['acc']) 

    return model
	
def train_model(model, train_data, test_data, batch_size=None, epochs=3,
                steps_per_epoch=None, validation_steps=None):

    model.fit(train_data, 
              validation_data=test_data,
              steps_per_epoch=steps_per_epoch,
              batch_size=batch_size,
              validation_steps=validation_steps,
              verbose=2, epochs=epochs)

    return model