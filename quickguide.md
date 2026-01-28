# Quick Start Guide

## Getting Started

1. **Start Docker Engine** - Ensure Docker Desktop is running on your system
2. **Open VS Code** - Navigate to this project directory
3. **Install PostgreSQL Extension** - Install the PostgreSQL extension in VS Code for database management and queries
4. **Setup Database Connection** - Configure the PostgreSQL extension by building the connection using credentials found in the `.env` file

![alt text](image.png)

After this step run the lines in the Schema_table_creation.sql to create the Schema and necessary table to inget csv files into the database. This step might take few minutes to load the data into the database. if you dont see the querry results then try it again in few minutes.
Next run the querries in the querries.sql file to get data for the relevant querries from the assessment sheet


5. **Run Docker Compose**: 
   ```bash
   docker compose up -d
   ```
   This pulls the PostgreSQL image if not available and starts the database container in detached mode.

4. **Open the main notebook**: `Sales_Data_Forecast_main.ipynb`
5. **Install dependencies** (if running for the first time):
   ```bash
   pip install -r Requirements.txt
   ```
   This ensures all necessary modules are included.

## File Descriptions

- **`Sales_Data_Forecast_main.ipynb`** - Main forecasting notebook containing the core analysis and prediction models
- **`Prediction_with_univariate_Extra.ipynb`** - Additional analysis with univariate forecasting methods (optional, interesting for extended results but not necessary for evaluation)
- **`docker-compose.yaml`** - Docker configuration to set up PostgreSQL database environment
- **`Requirements.txt`** - Python dependencies list for all required packages and modules
- **`Schema_table_creation.sql`** - SQL script to create the database schema and table structures
- **`querries.sql`** - SQL queries for data extraction and analysis operations
- **`SUMMARY.md`** - Project summary and overview documentation
- **`Final_forecast.png`** - Visualization of the final forecasting results
- **`Revenue_forecast_comparision.png`** - Comparison chart of different revenue forecasting approaches
- **`zellerfeld_data/`** - Directory containing CSV data files:
  - `customers.csv` - Customer information and demographics data
  - `order_items.csv` - Individual order line items with product details
  - `orders.csv` - Order transactions and metadata
  - `products.csv` - Product catalog with specifications and pricing