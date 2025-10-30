"""Model training script"""
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score
import mlflow
import argparse

def train_model(n_estimators=100):
    """Train Random Forest model"""
    # Load data
    df = pd.read_csv('data/processed/dataset.csv')
    X = df.drop(['user_id', 'label'], axis=1)
    y = df['label']
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    # Train
    model = RandomForestClassifier(n_estimators=n_estimators, random_state=42)
    model.fit(X_train, y_train)
    
    # Evaluate
    y_pred = model.predict(X_test)
    metrics = {
        'accuracy': accuracy_score(y_test, y_pred),
        'precision': precision_score(y_test, y_pred),
        'recall': recall_score(y_test, y_pred)
    }
    
    return model, metrics

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--n_estimators', type=int, default=100)
    args = parser.parse_args()
    
    mlflow.set_experiment("churn-prediction")
    
    with mlflow.start_run():
        mlflow.log_param("n_estimators", args.n_estimators)
        
        model, metrics = train_model(args.n_estimators)
        
        for key, value in metrics.items():
            mlflow.log_metric(key, value)
            print(f"{key}: {value:.3f}")
        
        mlflow.sklearn.log_model(model, "model")
        print("✓ Model logged to MLflow")
