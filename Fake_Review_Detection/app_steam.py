import streamlit as st
import joblib
import os

# Load model and TF-IDF vectorizer
model_path = os.path.join(os.path.dirname(__file__), "fake_review_detection.pk1")
vectorizer_path = os.path.join(os.path.dirname(__file__), "tfidf_vectorizer.pk1")

model = joblib.load(model_path)
vectorizer = joblib.load(vectorizer_path)

st.title("Fake Review Detector")
st.subheader("Paste a product review to check if it is fake or genuine")

review_input = st.text_area("Enter your review text here")

if st.button("Detect"):
    if not review_input.strip():
        st.warning("Please enter a review.")
    else:
        X = vectorizer.transform([review_input])
        prediction = model.predict(X)[0]
        confidence = model.predict_proba(X)[0][prediction]

        label = "FAKE REVIEW" if prediction == 1 else "GENUINE REVIEW"

        st.markdown(f"### Prediction: {label}")
        st.markdown(f"**Confidence:** {confidence * 100:.2f}%")
