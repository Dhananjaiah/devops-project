# Python Environment Cheat Sheet

## uv (Recommended)
```bash
# Install
curl -LsSf https://astral.sh/uv/install.sh | sh

# Create venv
uv venv --python 3.11
source .venv/bin/activate

# Install packages
uv pip install pandas scikit-learn mlflow

# Install from pyproject.toml
uv pip install -e ".[dev]"

# Generate lock file
uv pip freeze > requirements.lock
```

## Poetry (Alternative)
```bash
poetry init
poetry add pandas scikit-learn
poetry install
poetry shell
```

## pip + venv
```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
pip freeze > requirements.lock
```
