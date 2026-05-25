from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine

# -----------------------------
# Configuration
# -----------------------------

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_PATH = BASE_DIR / "data" / "0. raw"

SERVER = "localhost\\SQLEXPRESS"
DATABASE = "BrazilianEcommerceAnalytics"
DRIVER = "ODBC Driver 17 for SQL Server"

CONNECTION_STRING = (
    f"mssql+pyodbc://@{SERVER}/{DATABASE}"
    f"?driver={DRIVER.replace(' ', '+')}"
)

engine = create_engine(CONNECTION_STRING)

# -----------------------------
# Load CSVs into Bronze
# -----------------------------
print(f"Looking for CSVs in: {DATA_PATH}")

for csv_file in DATA_PATH.glob("*.csv"):
    table_name = csv_file.stem.lower()

    print(f"Loading {csv_file.name} -> bronze.{table_name}")

    df = pd.read_csv(csv_file)

    df.to_sql(
        name=table_name,
        schema="bronze",
        con=engine,
        if_exists="replace",
        index=False
    )

print("Bronze layer load completed successfully.")
