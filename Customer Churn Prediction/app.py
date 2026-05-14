import streamlit as st
import joblib
import numpy as np

@st.cache_resource
def load_model():
    # assumes churn_model.pk1 is in the SAME folder as this file
    return joblib.load("churn_model.pkl")

model = load_model()

st.title("Customer Churn Prediction")
st.markdown("Enter customer details to predict churn likelihood.")

total_charges = st.number_input("Total Charges (₹)", 0.0, 10000.0, 2000.0)
monthly_charges = st.number_input("Monthly Charges (₹)", 0.0, 1000.0, 100.0)
tenure = st.slider("Tenure (months)", 0, 72, 12)

if st.button("Predict churn"):
    X = np.array([[total_charges, monthly_charges, tenure]])
    pred = model.predict(X)[0]
    st.error("Customer is likely to churn 😞") if pred == 1 else st.success("Customer is likely to stay 🎉")
