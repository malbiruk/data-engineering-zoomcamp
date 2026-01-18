#!/usr/bin/env python3
"""Simple script to ingest data from data/ directory into PostgreSQL."""

import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

# Database connection from environment variables
DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_NAME = os.getenv("POSTGRES_DB")
DB_HOST = os.getenv("POSTGRES_HOST", "localhost")
DB_PORT = os.getenv("POSTGRES_PORT", "5432")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

TABLES = [
    {"file": "data/green_tripdata_2025-11.parquet", "table": "green_tripdata"},
    {"file": "data/taxi_zone_lookup.csv", "table": "taxi_zone_lookup"},
]


def read_file(file_path: str) -> pd.DataFrame:
    """Read a file based on its extension."""
    if file_path.endswith(".parquet"):
        return pd.read_parquet(file_path)
    if file_path.endswith(".csv"):
        return pd.read_csv(file_path)
    raise ValueError(f"Unsupported file format: {file_path}")


def ingest(engine, file_path: str, table_name: str):
    """Ingest a file into a database table."""
    print(f"Reading {file_path}...")
    df = read_file(file_path)
    print(f"Ingesting {len(df)} rows into {table_name}...")
    df.to_sql(table_name, engine, if_exists="replace", index=False, chunksize=10000)
    print("Done!")


def main():
    print(f"Connecting to database: {DB_HOST}:{DB_PORT}/{DB_NAME}")
    engine = create_engine(DATABASE_URL)

    for table in TABLES:
        ingest(engine, table["file"], table["table"])

    print("\nAll data ingested successfully!")


if __name__ == "__main__":
    main()
