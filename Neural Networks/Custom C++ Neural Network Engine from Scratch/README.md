# Custom C++ Neural Network Engine from Scratch

A lightweight, high-performance C++ neural network engine built completely from scratch using standard libraries. This project demonstrates the foundational mathematics of deep learning—including manual matrix layout, backpropagation chain rule calculus, and Gradient Descent optimization—without relying on external frameworks like PyTorch or TensorFlow.

---

## 🚀 Development Environment & Execution Syntax

This project was natively developed and evaluated inside **Google Colab** using an interactive cell environment. Because Colab natively runs a Python kernel, specific notebook shell scripts and magic commands were used to compile and execute the raw C++ code.

### 1. Where the Code is Written
The core engine is contained within a single interactive notebook cell. To export the C++ source code from the Python environment into Colab's local Linux container workspace, the cell must begin with the `%%writefile` command:

Mathematical Pipeline Architectural BlueprintThe engine operates on a strictly synchronized training loop split into four main core stages:Forward Pass: Calculates layer states via row-column dot products and applies non-linear activation filtering:$$H_{\text{linear}} = X \cdot W$$$$Y_{\text{pred}} = \max(0, H_{\text{linear}})$$Loss Computation: Evaluates performance via Mean Squared Error (MSE) and generates the initial root upstream error spark:$$\text{Loss} = \frac{1}{2}(Y_{\text{pred}} - \text{Target})^2$$$$\frac{\partial \text{Loss}}{\partial Y_{\text{pred}}} = Y_{\text{pred}} - \text{Target}$$Backpropagation (The Chain Rule): Filters gradients through the ReLU derivative and propagates adjustments upstream via simulated transposes:$$\delta_{\text{linear}} = \delta_{\text{loss}} \cdot \mathbb{I}(H_{\text{linear}} > 0)$$$$\frac{\partial \text{Loss}}{\partial W} = X^T \cdot \delta_{\text{linear}}$$Weight Optimization: Updates internal parameters by taking safe, controlled steps down the error valley:$$W = W - (\alpha \cdot \frac{\partial \text{Loss}}{\partial W})$$

Training Performance Log OutputThe following diagnostic sequence demonstrates the engine successfully mapping a 3-feature input vector [1.0, 2.0, 3.0] to learn a multi-output target matrix [5.0, 10.0] over 50 epochs with a learning rate ($\alpha$) of 0.01:

=== TRAINING A COMPLETE C++ NEURAL NETWORK ===

Epoch 1 | Total Loss: 38.1291 | Network Guess: [1.45138, 2.02093]
--- W (Weight Gradients) (Gradients) ---
-3.54862    -7.97907    
-7.09723    -15.9581    
-10.6459    -23.9372    
--- W (Weights BEFORE update) (Data) ---
0.378938    0.613779    

...

Epoch 30 | Total Loss: 0.00605574 | Network Guess: [4.95528, 9.89944]
--- W (Weight Gradients) (Gradients) ---
-0.0447213  -0.100556   
-0.0894426  -0.201112   
-0.134164   -0.301668   

...

Epoch 50 | Total Loss: 1.45246e-05 | Network Guess: [4.99781, 9.99508]
--- W (Weight Gradients) (Gradients) ---
-0.0021902  -0.00492466 
-0.00438039 -0.00984933 
-0.00657059 -0.014774   
--- W (Weights BEFORE update) (Data) ---
0.59679     1.10362     

=== TRAINING COMPLETE! ===

Observations from Diagnostics:
Gradient Decay: The weight gradients smoothly decay down toward 0.0 as total loss drops, proving stable convergence.

Feature Proportionality: The gradients for Row 1 and Row 2 maintain a perfect 2x and 3x ratio relative to Row 0, confirming that backpropagation accurately assigns error blame proportionally to input magnitudes.

Core Code Overview
Tensor::matmul: Custom matrix multiplier using row-major layout arithmetic (i * cols + j).

Tensor::backward_relu: Element-wise conditional gradient gatekeeper (prevents dead updates).

Tensor::backward_matmul: Static backpropagation calculator mapping structural layer responsibility.

Tensor::update_weights: Clean optimizer implementing shorthand subtraction arithmetic updates (data[i] -= learning_rate * grad[i]).
