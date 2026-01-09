"""
Disease Detection Model Training Script
Trains a CNN model on the Saon110 BD Crop-Vegetable Plant Disease Dataset
Exports to TensorFlow Lite for mobile deployment

This script requires:
- Python 3.9+
- tensorflow >= 2.12.0
- datasets (huggingface)
- numpy
- PIL
"""

import os
import json
import numpy as np
from pathlib import Path
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from datasets import load_dataset
from PIL import Image
import io

# Configuration
MODEL_CONFIG = {
    'input_size': 224,
    'batch_size': 32,
    'epochs': 30,
    'learning_rate': 0.001,
    'validation_split': 0.2,
    'test_split': 0.1,
}

class DiseaseModelTrainer:
    def __init__(self, config=None):
        self.config = {**MODEL_CONFIG, **(config or {})}
        self.model = None
        self.class_names = None
        self.history = None
        
    def download_dataset(self):
        """Download BD Crop-Vegetable Plant Disease Dataset from Hugging Face"""
        print("📥 Downloading dataset from Hugging Face...")
        try:
            dataset = load_dataset("Saon110/bd-crop-vegetable-plant-disease-dataset")
            print(f"✅ Dataset downloaded successfully")
            return dataset
        except Exception as e:
            print(f"❌ Error downloading dataset: {e}")
            print("Make sure you have internet access and HF_TOKEN if dataset is private")
            raise
    
    def prepare_dataset(self, dataset):
        """Prepare and preprocess the dataset"""
        print("🔄 Preparing dataset...")
        
        # Extract images and labels
        images = []
        labels = []
        
        # Handle different dataset formats
        for split in ['train', 'test']:
            if split in dataset:
                for sample in dataset[split]:
                    try:
                        # Get image - handle both PIL Image and bytes formats
                        if isinstance(sample['image'], Image.Image):
                            img = sample['image']
                        else:
                            img = Image.open(io.BytesIO(sample['image']))
                        
                        # Resize to target size
                        img = img.resize((self.config['input_size'], self.config['input_size']))
                        img_array = np.array(img) / 255.0
                        
                        # Handle grayscale images - convert to RGB
                        if len(img_array.shape) == 2:
                            img_array = np.stack([img_array] * 3, axis=-1)
                        elif img_array.shape[2] == 4:  # RGBA
                            img_array = img_array[:, :, :3]
                        
                        images.append(img_array)
                        
                        # Get label
                        label = sample.get('label') or sample.get('disease')
                        labels.append(label)
                        
                    except Exception as e:
                        print(f"⚠️ Error processing sample: {e}")
                        continue
        
        # Convert to numpy arrays
        X = np.array(images, dtype=np.float32)
        y = np.array(labels)
        
        # Get unique classes
        self.class_names = sorted(list(set(y)))
        class_to_idx = {cls: idx for idx, cls in enumerate(self.class_names)}
        
        # Encode labels
        y_encoded = np.array([class_to_idx[label] for label in y])
        
        print(f"✅ Dataset prepared: {X.shape[0]} images, {len(self.class_names)} classes")
        print(f"Classes: {self.class_names}")
        
        return X, y_encoded
    
    def build_model(self, num_classes):
        """Build CNN model - using MobileNetV2 for efficiency"""
        print("🏗️  Building model...")
        
        # Use transfer learning with MobileNetV2 (pre-trained on ImageNet)
        base_model = keras.applications.MobileNetV2(
            input_shape=(self.config['input_size'], self.config['input_size'], 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze base model weights
        base_model.trainable = False
        
        # Add custom layers
        model = models.Sequential([
            base_model,
            layers.GlobalAveragePooling2D(),
            layers.Dense(256, activation='relu', name='dense_1'),
            layers.Dropout(0.5),
            layers.Dense(128, activation='relu', name='dense_2'),
            layers.Dropout(0.3),
            layers.Dense(num_classes, activation='softmax', name='output')
        ])
        
        # Compile model
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=self.config['learning_rate']),
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print("✅ Model built successfully")
        self.model = model
        return model
    
    def train(self, X, y, validation_data=None):
        """Train the model"""
        print("🚀 Starting training...")
        
        # Split data if validation_data not provided
        if validation_data is None:
            indices = np.random.permutation(len(X))
            split_idx = int(len(X) * (1 - self.config['validation_split']))
            
            train_idx = indices[:split_idx]
            val_idx = indices[split_idx:]
            
            X_train, X_val = X[train_idx], X[val_idx]
            y_train, y_val = y[train_idx], y[val_idx]
            
            validation_data = (X_val, y_val)
        else:
            X_train, y_train = X, y
        
        # Train with data augmentation
        augmentation = keras.Sequential([
            layers.RandomFlip("horizontal"),
            layers.RandomRotation(0.1),
            layers.RandomZoom(0.1),
            layers.RandomBrightness(0.2),
        ])
        
        # Early stopping
        early_stop = keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=5,
            restore_best_weights=True
        )
        
        # Train
        self.history = self.model.fit(
            X_train, y_train,
            batch_size=self.config['batch_size'],
            epochs=self.config['epochs'],
            validation_data=validation_data,
            callbacks=[early_stop],
            verbose=1
        )
        
        print("✅ Training completed")
        return self.history
    
    def evaluate(self, X_test, y_test):
        """Evaluate model on test set"""
        print("📊 Evaluating model...")
        loss, accuracy = self.model.evaluate(X_test, y_test, verbose=0)
        print(f"Test Loss: {loss:.4f}")
        print(f"Test Accuracy: {accuracy:.4f}")
        return {'loss': loss, 'accuracy': accuracy}
    
    def save_model(self, filepath='./disease_model.h5'):
        """Save trained model"""
        print(f"💾 Saving model to {filepath}...")
        self.model.save(filepath)
        
        # Save class names
        class_file = filepath.replace('.h5', '_classes.json')
        with open(class_file, 'w') as f:
            json.dump(self.class_names, f)
        
        print(f"✅ Model saved")
    
    def export_tflite(self, output_path='./disease_model.tflite'):
        """Export model to TensorFlow Lite format"""
        print(f"📤 Exporting to TFLite: {output_path}...")
        
        # Convert to TFLite
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        tflite_model = converter.convert()
        
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"✅ TFLite model saved to {output_path}")
        
        # Save model info
        info_file = output_path.replace('.tflite', '_info.json')
        info = {
            'input_size': self.config['input_size'],
            'classes': self.class_names,
            'num_classes': len(self.class_names),
        }
        with open(info_file, 'w') as f:
            json.dump(info, f, indent=2)
        
        return output_path
    
    def predict(self, image_path):
        """Make prediction on a single image"""
        img = Image.open(image_path)
        img = img.resize((self.config['input_size'], self.config['input_size']))
        img_array = np.array(img) / 255.0
        
        if len(img_array.shape) == 2:
            img_array = np.stack([img_array] * 3, axis=-1)
        elif img_array.shape[2] == 4:
            img_array = img_array[:, :, :3]
        
        img_array = np.expand_dims(img_array, axis=0)
        
        predictions = self.model.predict(img_array)
        predicted_class = np.argmax(predictions[0])
        confidence = predictions[0][predicted_class]
        
        return {
            'disease': self.class_names[predicted_class],
            'confidence': float(confidence),
            'probabilities': {
                self.class_names[i]: float(predictions[0][i])
                for i in range(len(self.class_names))
            }
        }

def main():
    """Main training pipeline"""
    import sys
    
    print("🌾 BD Crop Disease Detection Model Training")
    print("=" * 50)
    
    # Create output directory
    output_dir = Path('./models')
    output_dir.mkdir(exist_ok=True)
    
    try:
        # Initialize trainer
        trainer = DiseaseModelTrainer()
        
        # Download dataset
        dataset = trainer.download_dataset()
        
        # Prepare data
        X, y = trainer.prepare_dataset(dataset)
        
        if len(X) == 0:
            print("❌ No images found in dataset")
            return
        
        # Build model
        num_classes = len(trainer.class_names)
        trainer.build_model(num_classes)
        print(trainer.model.summary())
        
        # Train model
        trainer.train(X, y)
        
        # Save model
        h5_path = str(output_dir / 'disease_model.h5')
        trainer.save_model(h5_path)
        
        # Export to TFLite
        tflite_path = str(output_dir / 'disease_model.tflite')
        trainer.export_tflite(tflite_path)
        
        print("\n" + "=" * 50)
        print("✅ Training completed successfully!")
        print(f"📁 Models saved in: {output_dir}")
        print(f"   - {tflite_path}")
        print(f"   - {tflite_path.replace('.tflite', '_info.json')}")
        
    except Exception as e:
        print(f"\n❌ Training failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
