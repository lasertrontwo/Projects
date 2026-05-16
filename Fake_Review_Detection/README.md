## 🚀 Project Overview

This project is a Machine Learning web application that detects whether a product review is likely to be fake or genuine.

The model is trained using Amazon product review data. The review text is converted into numerical features using TF-IDF, and a machine learning model is used to classify the review.

## 🛠️ Technologies Used

- Python
- Pandas
- NumPy
- Scikit-learn
- Streamlit
- Joblib
- TF-IDF Vectorizer

## 📂 Project Structure

```text
Fake_Review_Detection/
├── app_steam.py
├── fake_review_detection.pk1
├── tfidf_vectorizer.pk1
├── requirements.txt
└── README.md
📊 Machine Learning Workflow
1. Data Cleaning

The dataset was cleaned by handling null values and duplicate values.

Rows with missing review text were removed because review text is the main input for prediction.

2. Feature Engineering

New features were created from review text:

Review length
Word count
User review count

A rule-based label was created to mark reviews as suspicious or normal.

3. Text Vectorization

The review text was converted into numerical format using TF-IDF Vectorizer.

TF-IDF helps convert text into numbers so that the machine learning model can understand the review.

4. Model Training

The following models were tested:

Logistic Regression
Random Forest Classifier

The final trained model was saved as:

fake_review_detection.pk1

The TF-IDF vectorizer was also saved as:

tfidf_vectorizer.pk1

Both files are required for prediction in the Streamlit app.

🌐 Streamlit App

The Streamlit app allows users to paste a product review and check whether it is:

Fake Review
Genuine Review

The app also displays the prediction confidence.

▶️ How to Run Locally

Install the required libraries:

pip install -r requirements.txt

Run the Streamlit app:

streamlit run app_steam.py
📦 Requirements
streamlit
scikit-learn==1.6.1
joblib
numpy
pandas
🚀 Deployment

The app is deployed using Streamlit Community Cloud.

Deployment settings:

Repository: GitHub repository
Branch: main
Main file path: Fake_Review_Detection/app_steam.py
Python version: 3.11
📚 Dataset

Dataset used: Amazon Consumer Reviews Dataset

Source: Kaggle

✅ Output

After entering a review, the app predicts whether the review is fake or genuine.

Example output:

Prediction: FAKE REVIEW
Confidence: 92.45%

or

Prediction: GENUINE REVIEW
Confidence: 88.10%
