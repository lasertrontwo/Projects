# MNIST Digit Recognition using Neural Network

## Project Overview

This project builds a simple neural network from scratch to recognize handwritten digits from the MNIST dataset.

The model takes an image of a handwritten digit and predicts which number it represents, from 0 to 9.

## Dataset

The dataset used is the MNIST Digit Recognizer dataset.

Each image is represented as 784 pixel values because every image is 28 x 28 pixels.

```text
28 x 28 = 784

Technologies Used
Python
NumPy
Pandas
Matplotlib
Project Workflow
1. Import Libraries

The required libraries are imported:

NumPy for mathematical operations
Pandas for reading the dataset
Matplotlib for displaying digit images
2. Load Dataset

The training dataset is loaded using Pandas.

data = pd.read_csv("train.csv")
3. Data Preprocessing

The dataset is converted into a NumPy array and shuffled.

The data is split into:

Training data
Validation data

The pixel values are normalized by dividing by 255.

X_train = X_train / 255
X_dev = X_dev / 255

This converts pixel values from the range 0–255 to 0–1.

4. Neural Network Architecture

A simple neural network is built from scratch.

The network has:

Input layer: 784 neurons
Hidden layer: 10 neurons
Output layer: 10 neurons

The output layer represents digits from 0 to 9.

5. Activation Functions

ReLU is used in the hidden layer.

Softmax is used in the output layer to get class probabilities.

6. Forward Propagation

Forward propagation calculates the output of the neural network.

It passes the input through the hidden layer and output layer.

7. Backward Propagation

Backward propagation calculates the gradients.

These gradients are used to update weights and biases.

8. Gradient Descent

Gradient descent is used to train the model.

The model updates its parameters repeatedly to reduce prediction error.

9. Prediction

After training, the model predicts the digit for a given image.

The predicted digit is compared with the actual label.

10. Visualization

Matplotlib is used to display the handwritten digit image along with the model prediction.

Project Files
mnist-neural-network/
├── mnist-dataset-training-for-neural-network.ipynb
├── README.md
└── train.csv
How to Run
Open the notebook in Jupyter Notebook, Google Colab, or Kaggle.
Upload or connect the MNIST train.csv dataset.
Run all cells step by step.
Train the neural network.
Test predictions using:
test_prediction(0, w1, b1, w2, b2)

You can change the index value to test different images.

Output

The model prints:

Predicted digit
Actual label

It also displays the handwritten digit image.

Example:

Prediction:  [3]
Label:  3
Conclusion

This project demonstrates how a basic neural network works internally without using deep learning libraries like TensorFlow or PyTorch.

source(datasets):https://www.kaggle.com/competitions/digit-recognizer/overview
