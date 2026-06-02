#include<iostream>
#include <string>
#include<vector>
#include<numeric>
#include<cmath>
#include<algorithm>

class Tensor{
public:
    int rows,cols;
    std::vector<double> data;
    std::vector<double> grad; //holds gradients for backpropagation
    Tensor(int r,int c, double initial_val=0.0):rows(r),cols(c),data(r*c,initial_val), grad(r*c,0.0){
    }

    void randomize(){
      for (double &val:data){
        val = ((double)rand() / (RAND_MAX)) * 0.5 + 0.1;
      }

    }
    Tensor matmul(const Tensor& other){
      if(this->cols != other.rows){
        throw std::runtime_error("matrix dimensions do not match for multiplication!");

      }
      Tensor result(this->rows, other.cols,0.0);
        for(int i=0;i<this->rows;++i){
          for(int j=0;j<other.cols;++j){
            double sum=0;
            for(int k=0;k<this->cols;++k)


            {
              sum+=this->data[i*this->cols+k]*other.data[k*other.cols+j];

            }
            result.data[i*result.cols+j]=sum;
          }
        }
        return result;

    }
    Tensor relu(){
      Tensor result(this->rows,this->cols);
      for(size_t i=0;i<data.size();++i){
        result.data[i]=std::max(0.0,this->data[i]);

      }
      return result;
    }
    //Backpropagation: Backward Relu
    // Passes gradients backward only if the forward input was greater than 0
    void backward_relu(const Tensor& forward_output){
      for(size_t i=0; i<grad.size();++i){
        if(forward_output.data[i]<=0.0){
          this->grad[i]=0.0;// gradient is killed if neuron didnt fire
        }
      }
    }
    // Backpropagation: Backward Matrix Multiplication (Gradient Flow)
    // Updates weights gradients based on upstream incoming gradients
    static void backward_matmul(Tensor& X,Tensor& W,const Tensor& upstream_grad){
      for(int i=0;i<X.rows;++i){
        for(int j=0;j<X.cols;++j){
          double sum=0;
          for(int k=0;k<W.cols;++k){
            sum+=upstream_grad.grad[i*W.cols+k]*W.data[j*W.cols+k];
          }
          X.grad[i*X.cols+j]=sum;
        }

      }
      for(int i=0;i<W.rows;++i){
        for(int j=0;j<W.cols;++j){
          double sum=0;
          for(int k=0;k<X.rows;++k){
            sum+=X.data[k*X.cols+i]*upstream_grad.grad[k*W.cols+j];
          }
          W.grad[i*W.cols+j]=sum;
        }
      }

    }
    void print_data(const std::string& name) {
        std::cout << "--- " << name << " (Data) ---" << std::endl;
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) std::cout << data[i * cols + j] << "\t";
            std::cout << std::endl;
        }
    }

    void print_grad(const std::string& name) {
        std::cout << "--- " << name << " (Gradients) ---" << std::endl;
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) std::cout << grad[i * cols + j] << "\t";
            std::cout << std::endl;
        }
    }
    // Optimizer: Step function to update weights using Gradient Descent
    void update_weights(double learning_rate){
      for(size_t i=0;i<data.size();++i){
        data[i]-=learning_rate*grad[i];
      }
    }
};
int main() {
    srand(7); // Setup seed
    std::cout << "=== TRAINING A COMPLETE C++ NEURAL NETWORK ===" << std::endl << std::endl;

    // 1. Setup Data
    Tensor X(1, 3); X.data = {1.0, 2.0, 3.0}; // Inputs
    Tensor Target(1, 2); Target.data = {5.0, 10.0}; // What we want the network to learn to output
    
    // 2. Initialize Layer Weights
    Tensor W(3, 2); 
    W.randomize();

    double learning_rate = 0.01;

    // 3. THE TRAINING LOOP (Run for 50 iterations)
    for (int epoch = 1; epoch <= 50; ++epoch) {
        
        // Forward pass
        Tensor hidden_linear = X.matmul(W);
        Tensor Y_pred = hidden_linear.relu(); // Networks current guess

        // CALCULATE LOSS (Mean Squared Error Derivative) 
        // Error = Prediction - Target
        double loss = 0.0;
        Tensor loss_grad(1, 2);
        for (int i = 0; i < 2; ++i) {
            double error = Y_pred.data[i] - Target.data[i];
            loss += 0.5 * error * error;
            loss_grad.grad[i] = error; // This acts as our starting upstream gradient
        }

        // Backpropagation pass
        hidden_linear.grad = loss_grad.grad;
        hidden_linear.backward_relu(Y_pred);
        
        Tensor::backward_matmul(X, W, hidden_linear);

        // Update weights (Learning step)
        W.update_weights(learning_rate);

        // Print progress every 10 steps to see it learn!
        if (epoch == 1 || epoch % 10 == 0) {
            std::cout << "Epoch " << epoch 
                      << " | Total Loss: " << loss 
                      << " | Network Guess: [" << Y_pred.data[0] << ", " << Y_pred.data[1] << "]" 
                      << std::endl;
            // 2. See the exact numerical blame calculated during backprop
            W.print_grad("W (Weight Gradients)");

            // 3. See the state of the weights BEFORE the subtraction step
            W.print_data("W (Weights BEFORE update)");    
        }
    }

    std::cout << "\n=== TRAINING COMPLETE! ===" << std::endl;
    return 0;
}
