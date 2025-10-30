"""Data preparation script"""
import pandas as pd
import numpy as np
from pathlib import Path

def prepare_data():
    """Prepare training and test datasets"""
    # Generate sample data
    np.random.seed(42)
    n_samples = 10000
    
    data = {
        'user_id': range(n_samples),
        'age': np.random.randint(18, 80, n_samples),
        'tenure': np.random.randint(0, 120, n_samples),
        'monthly_charges': np.random.uniform(20, 200, n_samples),
        'total_charges': np.random.uniform(100, 10000, n_samples),
        'label': np.random.randint(0, 2, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # Save
    Path('data/processed').mkdir(parents=True, exist_ok=True)
    df.to_csv('data/processed/dataset.csv', index=False)
    print(f"✓ Created dataset with {len(df)} samples")

if __name__ == "__main__":
    prepare_data()
