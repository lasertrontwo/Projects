🚀 Project Overview

Customer churn prediction helps businesses identify customers who are likely to stop using their services.

This project uses Machine Learning models trained on the Telco Customer Churn Dataset to classify customers into:

✅ Likely to Stay
❌ Likely to Churn

🛠️ Technologies Used
Python
Pandas
NumPy
Scikit-learn
Streamlit
Joblib

📂 Project Structure


churn-prediction-app/
│
├── app.py
├── churn_model.pkl
├── requirements.txt
├── README.md
└── Customer_Churn.ipynb



📊 Machine Learning Workflow
1️⃣ Data Cleaning
Removed null and blank values
Converted TotalCharges column to numeric
Encoded categorical columns using LabelEncoder

2️⃣ Feature Engineering
Features used:
The model uses customer-related features such as:
Gender
Senior Citizen
Partner
Dependents
Tenure
Phone Service
Internet Service
Contract
Payment Method
Monthly Charges
Total Charges


3️⃣ Model Training
Models tested:
Logistic Regression
Decision Tree
Random Forest Classifier

4️⃣ Best Model
✅ Random Forest performed best with approximately 79% accuracy.

🌐 Streamlit App Features
Simple user interface
User input sliders and forms
Real-time churn prediction

##How to Deploy on Streamlit Community Cloud
The project is deployed using Streamlit Community Cloud.

To deploy the app:

1. Upload all required project files to GitHub:

Customer_Churn_Prediction/


├── app.py
├── churn_model.pkl
├── requirements.txt
└── README.md


Go to Streamlit Community Cloud.
Sign in using your GitHub account.
Click on Create App or New App.
Connect your GitHub repository.
Select the repository that contains this project.
Set the main file path as:
Customer_Churn_Prediction/app.py
Select the correct Python version, preferably:
Python 3.11
Click Deploy.

After deployment, Streamlit will provide a public app link that can be shared with others.

The app directly loads the trained model file:

churn_model.pkl

So the model does not need to be trained again during deployment.



After the connection  established
<img width="1234" height="702" alt="image" src="https://github.com/user-attachments/assets/8524bf40-0471-497c-bf5c-ce6a6d2d7848" />
<img width="1366" height="637" alt="image" src="https://github.com/user-attachments/assets/1fbba83d-9e7e-44c1-a182-35f86d567032" />
<img width="1365" height="643" alt="image" src="https://github.com/user-attachments/assets/63d44c3c-3ab4-4a73-9d7f-b0ae559015b5" />



📚 Dataset

Dataset used:
Telco Customer Churn Dataset

Source:
Kaggle
