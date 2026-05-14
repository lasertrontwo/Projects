import streamlit as st
import joblib
import pandas as pd
import os

# Load the model
model_path = os.path.join(os.path.dirname(__file__), "churn_model.pkl")
model = joblib.load(model_path)

st.title("Customer Churn Prediction")

# -----------------------------
# User inputs
# -----------------------------

gender = st.selectbox("Gender", ["Female", "Male"])
senior_citizen = st.selectbox("Senior Citizen", [0, 1])
partner = st.selectbox("Partner", ["No", "Yes"])
dependents = st.selectbox("Dependents", ["No", "Yes"])

tenure = st.slider("Tenure (months)", 0, 72, 12)

phone_service = st.selectbox("Phone Service", ["No", "Yes"])
multiple_lines = st.selectbox("Multiple Lines", ["No", "No phone service", "Yes"])

internet_service = st.selectbox("Internet Service", ["DSL", "Fiber optic", "No"])
online_security = st.selectbox("Online Security", ["No", "No internet service", "Yes"])
online_backup = st.selectbox("Online Backup", ["No", "No internet service", "Yes"])
device_protection = st.selectbox("Device Protection", ["No", "No internet service", "Yes"])
tech_support = st.selectbox("Tech Support", ["No", "No internet service", "Yes"])
streaming_tv = st.selectbox("Streaming TV", ["No", "No internet service", "Yes"])
streaming_movies = st.selectbox("Streaming Movies", ["No", "No internet service", "Yes"])

contract = st.selectbox("Contract", ["Month-to-month", "One year", "Two year"])
paperless_billing = st.selectbox("Paperless Billing", ["No", "Yes"])
payment_method = st.selectbox(
    "Payment Method",
    [
        "Bank transfer (automatic)",
        "Credit card (automatic)",
        "Electronic check",
        "Mailed check"
    ]
)

monthly_charges = st.slider("Monthly Charges ($)", 0.0, 150.0, 50.0)
total_charges = st.slider("Total Charges ($)", 0.0, 10000.0, 1000.0)

# -----------------------------
# Encoding mappings
# These follow common LabelEncoder alphabetical order
# -----------------------------

binary_map = {
    "No": 0,
    "Yes": 1
}

gender_map = {
    "Female": 0,
    "Male": 1
}

multiple_lines_map = {
    "No": 0,
    "No phone service": 1,
    "Yes": 2
}

internet_service_map = {
    "DSL": 0,
    "Fiber optic": 1,
    "No": 2
}

internet_related_map = {
    "No": 0,
    "No internet service": 1,
    "Yes": 2
}

contract_map = {
    "Month-to-month": 0,
    "One year": 1,
    "Two year": 2
}

payment_method_map = {
    "Bank transfer (automatic)": 0,
    "Credit card (automatic)": 1,
    "Electronic check": 2,
    "Mailed check": 3
}

# -----------------------------
# Create input dataframe
# Column order must match training data
# -----------------------------

input_data = pd.DataFrame({
    "gender": [gender_map[gender]],
    "SeniorCitizen": [senior_citizen],
    "Partner": [binary_map[partner]],
    "Dependents": [binary_map[dependents]],
    "tenure": [tenure],
    "PhoneService": [binary_map[phone_service]],
    "MultipleLines": [multiple_lines_map[multiple_lines]],
    "InternetService": [internet_service_map[internet_service]],
    "OnlineSecurity": [internet_related_map[online_security]],
    "OnlineBackup": [internet_related_map[online_backup]],
    "DeviceProtection": [internet_related_map[device_protection]],
    "TechSupport": [internet_related_map[tech_support]],
    "StreamingTV": [internet_related_map[streaming_tv]],
    "StreamingMovies": [internet_related_map[streaming_movies]],
    "Contract": [contract_map[contract]],
    "PaperlessBilling": [binary_map[paperless_billing]],
    "PaymentMethod": [payment_method_map[payment_method]],
    "MonthlyCharges": [monthly_charges],
    "TotalCharges": [total_charges]
})

# -----------------------------
# Prediction
# -----------------------------

if st.button("Predict Churn"):
    prediction = model.predict(input_data)

    if prediction[0] == 1:
        st.warning("⚠️ This customer is likely to churn")
    else:
        st.success("✅ This customer is likely to stay")
