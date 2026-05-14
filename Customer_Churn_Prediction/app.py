import streamlit as st
import pickle
import numpy as np
import os
# Load the model
model_path = os.path.join(os.path.dirname(__file__), "churn_model.pkl")
with open(model_path, "rb") as f:
    model = pickle.load(f)

st.title("Customer Churn Prediction")

# Get user input
tenure = st.slider("Tenure (months)", 0, 72, 12)
monthly_charges = st.slider("Monthly Charges ($)", 0, 150, 50)
total_charges = st.slider("Total Charges ($)", 0, 10000, 1000)

# Make prediction
if st.button("Predict Churn"):
    input_data = np.array([[tenure, monthly_charges, total_charges]])
    prediction = model.predict(input_data)
    
    if prediction[0] == 1:
        st.warning("⚠️ This customer is likely to churn")
    else:
        st.success("✅ This customer is likely to stay")
