# Custom C++ Neural Network Engine from Scratch

A lightweight, high-performance C++ neural network engine built completely from scratch using standard libraries. This project demonstrates the foundational mathematics of deep learning—including manual matrix layout, backpropagation chain rule calculus, and Gradient Descent optimization—without relying on external frameworks like PyTorch or TensorFlow.

---

## 🚀 Development Environment & Execution Syntax

This project was natively developed and evaluated inside **Google Colab** using an interactive cell environment. Because Colab natively runs a Python kernel, specific notebook shell scripts and magic commands were used to compile and execute the raw C++ code.

### 1. Where the Code is Written
This project was developed and tested inside **Google Colab**. Since Colab natively runs a Python environment, you use specific notebook commands to write, compile, and run the raw C++ code.

### 1. Saving the C++ File
The core engine is written in a single cell inside Google Colab. To save this code directly into Colab's local Linux cloud workspace, the very first line of the cell must use the `%%writefile` command:
### 2. Compilation & Execution Syntax
To compile the exported source file using the GNU C++ Compiler (g++) and run the binary executable directly inside the Colab notebook interface, execute the following bash shell commands in a separate cell:

//Compile the engine with optimizations
!g++ tensor_engine.cpp -o tensor_engine
//Execute the compiled binary to view the training logs
!./tensor_engine

# Machine Learning Pipeline Blueprint
The engine runs a continuous loop that repeatedly processes data, checks for mistakes, figures out who to blame, and adjusts itself. This happens in four clear stages:

1. The Forward Pass (Making a Guess): The network takes your raw input features and multiplies them by its internal weights to create a combined signal. It then passes this signal through a filter (the ReLU activation function). This filter acts like a security guard: if a value is positive, it lets it pass right through; if a value is negative, it completely blocks it and changes it to zero. The final output is the network’s current "guess."

2. Loss Computation (Measuring the Mistake): The engine compares the network's current guess against the true target answer. It calculates the difference to find out exactly how far off the guess was. This calculation generates an "error value" (the mistake), which acts as the initial spark or wake-up call needed to start the reverse cleanup process.

3. Backpropagation (Distributing the Blame): This is the backtracking stage where the engine works in reverse using the chain rule. First, it looks back at the filter from Stage 1: if a neuron didn't fire (got blocked at zero), it completely kills the gradient for that path because that neuron didn't contribute to the mistake. For the pathways that did fire, it mathematically tracks the error backwards through your matrix. It cross-references the incoming mistake with the original inputs to calculate the exact amount of "blame" or responsibility that should be assigned to each individual weight parameter.

4. Weight Optimization (Learning from the Mistake): Now that the engine knows exactly which weights caused the mistake, the optimizer takes over. It uses a setting called the "learning rate" to make small, controlled changes. It takes a percentage of the calculated blame and subtracts it from the current weights. This micro-adjustment nudges the weights in the right direction so that on the very next loop, the network's guess will automatically be slightly closer to the true answer

# Training Performance
Log OutputThe following diagnostic sequence demonstrates the engine successfully mapping a 3-feature input vector [1.0, 2.0, 3.0] to learn a multi-output target matrix [5.0, 10.0] over 50 epochs with a learning rate ($\alpha$) of 0.01:

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

# Observations from Diagnostics:
Gradient Decay: The weight gradients smoothly decay down toward 0.0 as total loss drops, proving stable convergence.

Feature Proportionality: The gradients for Row 1 and Row 2 maintain a perfect 2x and 3x ratio relative to Row 0, confirming that backpropagation accurately assigns error blame proportionally to input magnitudes.

# Core Code Overview
Tensor::matmul: Custom matrix multiplier using row-major layout arithmetic (i * cols + j).

Tensor::backward_relu: Element-wise conditional gradient gatekeeper (prevents dead updates).

Tensor::backward_matmul: Static backpropagation calculator mapping structural layer responsibility.

Tensor::update_weights: Clean optimizer implementing shorthand subtraction arithmetic updates (data[i] -= learning_rate * grad[i]).
