## Report (Sales Data Forecasting)

This report documents my approach to the sales forecasting assessment, covering database setup, SQL-based analysis, and predictive modeling. The goal was to simulate a realistic data warehousing and forecasting pipeline, starting from ingesting CSV data into PostgreSQL, analyzing key business questions through SQL queries, and finally building forecasting models in Python to predict future revenue.

The workflow is structured in three main parts:

Setting up a reproducible PostgreSQL environment using Docker and managing the schema through VS Code.

Writing SQL queries to answer business questions and validating results.

Developing univariate and multivariate forecasting models, performing feature engineering, tuning hyperparameters, evaluating performance across multiple metrics, and generating a final forecast for October 2025.

Beyond building models, I also paid attention to data assumptions, feature design, and potential pitfalls such as data leakage, documenting the challenges I encountered and how I overcame them. The final section highlights not just the forecast, but also which features were most important for driving revenue predictions, offering insights that can support business decision-making.


# Contents: 
1. Overview of the approach
2. Feature engineering
3. Model selection
4. Evaluation metrics
5. Assumptions
6. Challenges
7. Final results

# 1. Overview of the approach
- Part 1: Database Setup & Warehousing
    To simulate a data warehouse environment (similar to AWS Redshift), I deployed PostgreSQL locally using Docker. Below are the steps I followed:
    - Step 1: Docker & Docker Compose
        - I created a docker-compose.yaml file along with a .env file containing credentials (username, password, database name).
        - The docker-compose.yaml defines a PostgreSQL service and mounts a local volume for persistent storage.
    
    - Step 2: Starting the Database
        - With Docker running, I launched the container by running the command : "docker-compose up -d" on the terminal.
        - On the first run, Docker automatically pulls the official PostgreSQL image, creates a container, and starts the database server
    
    - Step 3: Connection to the server via VS code
        - Installed the official PostgreSQL VS Code extension to manage the database directly inside VS Code.
        - Connected to the PostgreSQL server using the credentials from the .env file.
        - From there, I could run SQL scripts (create_schema.sql, queries.sql) and interact with the database.
    
    - step 4: ingestion of csv data into the database
        - Mounted the local folder ./zeller_data into the Docker container as /data so PostgreSQL could access the CSV files.
        - Run the sql scripts in the create_schema.sql to create the SCHEMA and the TABLES for the 4 csv files.
        - Used SQL COPY commands to bulk-load data from the CSVs (customers.csv, products.csv, orders.csv, order_items.csv) into their respective tables.
        - Repeated the same process for all four tables.
        - Verified the data load with quick sanity checks such as row counts: SELECT COUNT(*) FROM sales.customers;

    I chose to set up PostgreSQL using Docker with a docker-compose.yaml because it made the process much easier and fully reproducible. With a single command (docker-compose up -d), I could spin up a clean database environment without manual installation. This approach is portable, isolated, and can be replicated on any system with Docker. Combined with the PostgreSQL VS Code extension, it gave me a simple and developer-friendly way to manage the schema, run queries, and validate results.

    
-   Part 2: SQL-Based Data Analysis 
    
    To answer the business questions in the assessment, I wrote SQL queries in a separate file (queries.sql). The steps I followed were:
    
    - Step 1: Executed SQL queries against the PostgreSQL database using the VS Code PostgreSQL extension.

    - Step2 :  Created queries to address each task:
        - Top 10 best-selling products by total revenue.
        - Top 5 customers by total spending.
        - Total revenue per month.
        - Product category with the highest average number of items per order.

    - Step 3: Validated results by exporting query outputs and performing quick cross-checks in Excel (e.g., verifying sums, grouping totals, and top rankings). This gave confidence that the SQL logic was correct and aligned with the raw CSV data.

- Part 3: Predictive Modeling
    
    I have used python as the language, VS code as the IDE on my windows machine.
    
    - Step 1: Loaded all the necessary libraries for the whole program. 
    - Step 2: Connect and load Data from Postgres SQL database
        - Loaded the environment variables into Python using python-dotenv. Read the database credentials (username, password, database name, port) securely in a .env file.
        - Built a connection string for PostgreSQL using SQLAlchemy with the psycopg driver.
        - Successfully connected to the running PostgreSQL instance from Python.
        - Verified the connection by querying metadata (database name, user, and available tables).
        - Loaded all four tables (customers, products, orders, order_items) into pandas DataFrames for further analysis and feature engineering
    - Step 3: Data cleaning and preparation:
        - Merged dataframes:
            - Combined order_items with products based on product_id.
            - Combined orders with customers based on customer_id.    
            - Merged both results into a single master sales dataset.
        - Created revenue column : Added a revenue column (quantity × price_per_item) required as target variable for prediction.
        - Checked data quality: Inspected missing values, duplicates, and ensured correct data types (order_date, join_date).
        - Cleaned data:
            - Removed non-essential columns (email, order_item_id, join_date, name).
            - Quick check to identify any missmatch / discount on any product by comparing price_per_item with product’s listed price (to account for any discounts)
        - Prepared for visual analysis:
            - Aggregated daily revenue (with zero-fill for missing days).
            - Aggregated monthly revenue with year_month column.
            - Built category-wise revenue trends.
            - Analyzed order status changes over time.
            - Calculated seasonality patterns by month.
            - Explanation: 
                Preparing the data for visualization helps uncover important patterns before modeling. By plotting daily and monthly revenue, category trends, and order status over time, I was able to identify seasonality (recurring monthly/annual patterns), check for stationarity (whether the statistical properties remain stable over time), and detect outliers or anomalies in the data. These insights are crucial for selecting appropriate forecasting models and ensuring the model learns meaningful patterns rather than noise.
    - Step 4: Univariate forecasting: 
        - why did i do it ? 
            I first carried out a univariate forecasting approach, focusing only on the target variable (monthly revenue). The motivation was to establish a baseline model that captures core time-series patterns without relying on external explanatory variables. This helps to understand whether the sales data itself contains enough signal (trend, seasonality, stationarity) to generate meaningful forecasts. 
        - Steps followed as:
            - Parial months : Excluded sep-2023 and estimated sep-2025 to 30 days (Read the assumptions section for more details)
            - Data aggregation: Converted the transaction-level dataset into monthly revenue series.
            - Data splitting: Split the data chronologically into training (first 80%) and testing (last 20%) to avoid leakage.
            - Feature engineering: Created time-based features suitable for univariate modeling:
            - Lag features (e.g., revenue in the previous month).
            - Rolling mean and rolling standard deviation features to capture recent momentum and volatility.
            - Date-related features such as year and month (numeric) for trend/seasonality signals.
            - Stationarity checks: Visualized series and transformations to assess stability of mean/variance.
            - Feature engineering:
                - Lags: lag_1, lag_2 of revenue.
                - Rolling stats on shifted series: roll_mean_3, roll_std_3 (momentum & volatility).
                - Calendar & cyclical encodings: month, quarter, sin(2π·month/12), cos(2π·month/12).
                - Drop initial rows created by lags/rolls to avoid NA leakage.
            - Models applied:
                - ARIMA/SARIMA
                - XGBoost (univariate setup)
            - Hyperparameter tuning:
                - For ARIMA/SARIMA: tuned (p, d, q) and seasonal parameters manually/iteratively.
                - For XGBoost: performed optuna for best hyperparameters such as: n_estimators, max_depth, learning_rate, subsample, colsample_bytree, reg_alpha, reg_lambda
            - Evaluation on test data with metrics such as MAE, RMSE, MAPE
            - Forecasting oct-2025 using all 3 models along with reported evaluation metrixs and plotted actual vs. predicted to visually confirm stability and error structure.

        Outcome:

        This univariate modeling provided a strong baseline, confirming that the revenue series is relatively stationary with weak seasonality, and that models like XGBoost can leverage lagged features effectively for short-term forecasting. But the error in forcasting is quite high with average 25086.921 which is significant incomparision with the total revenue generation per month of 250,000. So moving ahead with mutivariate forecast modelling for better predictions.


    - Step 5: Multivariate forecasting:

        - Followed similar approach as done in Univariate forecasting until feature engineering.
        - Feature engineering: Generated a total of 19 features. 
        ['num_customers', 'num_products', 'total_quantity', 'num_repeat_customers', 'num_repeat_orders', 'completed', 'pending', 'shipped', 'total_orders', 'completed_rate'].
        Discussed breifly in section "Feature Engineering". 
        - Models applied:
            Linear regularized : Lasso and Ridge Regression
            Tree-based : Random Forest Regressor and XGBoost Regressor
        - Hyper parameter tuning : Performed only for XGBoost Regressor similar to the approach done in univariate case.
        - Evaluation and forecasting similar to approach followed in univariate case

        Outcome

        Linear models (Ridge, Lasso) offered interpretable but less accurate
        results, limited by the assumption of linearity. Random Forest improved accuracy but tended to overfit due to the relatively small dataset. XGBoost with Optuna tuning consistently outperformed others, striking the best balance of accuracy and generalization.

        Multivariate features (especially repeat customer share, order status rates, and product diversity) contributed noticeably to improved forecasting over the univariate baseline.

        

            
# 2. Assumptions

In preparing the dataset for forecasting, I had to handle partial months carefully to avoid introducing bias or errors into model training and evaluation. The following assumptions were made:

### September 2023 (ignored)

Only ~10 days of data were available. I decided to exclude September 2023 entirely because extrapolating from so few days would introduce large uncertainty. Including it would have distorted model learning by underestimating monthly revenue.

### September 2025 (extrapolated)

At the cut-off point, only part of September 2025 was available. To keep this month in the dataset for forecasting, I extrapolated it to a full month by:

- Scaling observed revenue and quantity to account for the missing days.

- Randomly resampling existing transactions and assigning them to the unobserved days.

- Adjusting the synthetic records so that the totals (revenue and quantity) matched the extrapolated monthly targets.

This approach assumes that the sales patterns, product mix, and category distribution during the missing days would be similar to those observed earlier in the month.

Why this matters
These assumptions allowed me to maintain a consistent time series of complete months for training and evaluation. Without excluding September 2023 and extrapolating September 2025, the models would have been trained on incomplete or biased data, reducing the reliability of the forecasts.

# 3. Feature Engineering: 

For the multivariate approach, I designed a set of features beyond just past revenue. These additional predictors capture customer behavior, product diversity, order dynamics, and temporal signals that can help the model learn richer relationships.

- Base monthly aggregation
    - num_customers: number of unique customers per month.
    Significance: captures demand size and customer base growth/shrinkage.
    - num_products: number of unique products sold per month.
    Significance: measures product variety, linked to sales opportunities.
    - total_quantity: total items sold per month.
    Significance: reflects overall sales volume, independent of revenue.

- Customer behavior features
    - num_repeat_customers: customers ordering more than once in a month.

        Significance: loyalty metric, indicates stability in sales.
    - num_repeat_orders: number of orders placed by repeat customers.
        
        Significance: captures concentration of sales from loyal customers.
    - Derived shares (repeat_customer_share, repeat_order_share).
        
        Significance: relative measure of repeat activity, normalizing for scale.

- Order status features
    - Counts of completed, pending, and shipped orders per month.
    - Derived rates (completed_rate, pending_rate, shipped_rate).
    
    Significance: show operational flow and fulfillment performance; delays or high pending rates may predict lower realized revenue.

- Time-based features

    - month, quarter, year.
    
    Significance: encode seasonality and calendar trends explicitly.

- Lag features (optional)

    - revenue_lag1: previous month’s revenue.
    
        Significance: short-term momentum, key for forecasting.

    - revenue_lag3: 3-month rolling mean of past revenue.
    
        Significance: smooths short-term noise, reflects medium-term trend.

Why these features mattered for my analysis: 

Including these multivariate features helped me move beyond looking at revenue in isolation. By adding demand-side factors (number of customers and products), I could see how the scale of the customer base and product variety influenced sales. The loyalty dynamics (repeat customers and orders) gave me useful signals about stability and recurring demand, which improved model robustness. The operational features (completed, pending, shipped rates) provided insight into fulfillment efficiency, which turned out to be an important indicator of realized revenue. Finally, the time-based signals (month, quarter, year) ensured that the model could capture calendar-driven effects more effectively than revenue alone. Together, these features made the forecasting more reliable, especially since the raw revenue series itself was fairly stationary with only mild seasonal patterns.


# 4. Model Selection 

### Univariate

I started with ARIMA/SARIMA as a classical baseline because they are standard models for time-series forecasting, well-suited for capturing autoregressive patterns and weak seasonality. I then applied XGBoost in a univariate setup (using lagged revenue and rolling statistics as features) to test whether a machine learning approach could better capture short-term dependencies.

These choices gave me both a traditional time-series benchmark (ARIMA) and a modern machine-learning baseline (XGBoost), ensuring I understood how much predictive power lay purely in past revenue.

### Multivariate

To benchmark the multivariate feature set, I first included Linear Regression and its regularized variants (Ridge, Lasso). These models are simple, interpretable, and act as a check on whether the added features provide predictive signal in a linear setting. Next, I tested tree-based models (Random Forest, XGBoost), since they are well known for handling complex, non-linear interactions and mixed feature types. Random Forest provided a bagging-based ensemble benchmark, while XGBoost allowed for fine-tuned boosting to maximize accuracy.

Together, this mix of models let me compare interpretability vs accuracy, and linear vs non-linear learners, ensuring that my final choice (XGBoost) was based on systematic evaluation rather than assumption.

# 5. Evaluation metrics

To evaluate the forecasting models, I used a broad set of metrics that capture different aspects of prediction quality.

- MAE (Mean Absolute Error) : measures the average absolute difference between predicted and actual values. Simple and easy to interpret in the same units as revenue.
- RMSE (Root Mean Squared Error) : penalizes larger errors more heavily. Useful when large deviations are particularly costly.
- R² (Coefficient of Determination) : explains how much of the variance in the target is captured by the model. A higher R² confirms that the multivariate features (customers, repeat orders, status rates) added meaningful predictive power compared to univariate.
- MedAE (Median Absolute Error) : more robust to outliers compared to MAE. This reassures me that a few unusual months (with spikes or dips) don’t dominate the evaluation.
- MAPE (%) (Mean Absolute Percentage Error) : expresses errors as percentages, making it easier to interpret forecasting accuracy in business terms.
- sMAPE (%) (Symmetric Mean Absolute Percentage Error) : an adjusted percentage error metric that is more stable when actual values are small. Commonly used in forecasting competitions.
- MBE (Mean Bias Error) : indicates whether the model systematically over-predicts or under-predicts. In my case, it helped check that forecasts weren’t consistently optimistic or conservative.


Beyond the common metrics, I explored additional ones like sMAPE and MBE after coming across their frequent use in Kaggle competitions, GitHub repositories, and online forecasting resources. 


![alt text](Revenue_forecast_comparision.png)
### 📊 Model Comparison (Train/Test Performance)

| Model        | MAE        | RMSE        | R²       | MAPE (%) | sMAPE (%) | MedAE     | MBE (bias)   |
|--------------|------------|-------------|----------|----------|-----------|-----------|--------------|
| XGBoost      | 5450.297645 | 6081.420868 | 0.837514 | 2.363855 | 2.334991  | 4899.875625 | -3490.347395 |
| RandomForest | 5014.977005 | 6587.359238 | 0.809354 | 2.223082 | 2.183755  | 4042.236008 | -3398.082605 |
| Ridge        | 30275.445452| 55915.245448| -12.736155| 12.964618| 16.811159 | 6455.343547 | 13905.266448 |
| Lasso        | 18095.777528| 30968.342426| -3.213477 | 7.766612 | 7.034531  | 6888.152989 | -10826.176090|

From the comparison table, it is clear that tree-based models (XGBoost, Random Forest) far outperformed the linear models (Ridge, Lasso) across all metrics.

XGBoost achieved the best overall balance, with MAE ≈ 5,450 and MAPE ≈ 2.36%, meaning predictions were on average within ~2–3% of the actual monthly revenue. Its R² of 0.84 shows that the features explained most of the variance in revenue. The bias (MBE ≈ -3,490) indicates a slight tendency to underpredict, but the error level is acceptable and consistent.

Random Forest performed competitively, slightly better on MAE (≈ 5,015) but worse on RMSE (≈ 6,587), showing it captured median errors well but struggled more with extreme months compared to XGBoost.

Ridge and Lasso performed poorly. Negative R² values (-12.7 and -3.2) indicate that they explained less variance than even a naïve baseline. High MAE and MAPE confirm that linear models were unable to capture the non-linear relationships in the data.

Key takeaway:
The evaluation confirms that non-linear, tree-based models are the best fit for this forecasting problem, with XGBoost emerging as the most reliable and consistent performer. Linear models failed to capture the complexity of multivariate features, while boosting and ensemble methods leveraged them effectively to achieve business-useful accuracy (within ~2–3%).



# 6. Challenges

- Avoiding Data Leakage
    - Challenge: 
        While experimenting with Ridge regression, I initially obtained “perfect” results (MAE = 0, RMSE = 0, R² = 1). This was unrealistic and indicated a case of data leakage. Some of the features I had engineered were indirectly derived from revenue, meaning the model could reconstruct the target instead of truly forecasting it. Identifying this issue was a challenge, because at first the performance looked excellent.

    - Solution:
        After careful analysis, I realized the leakage and removed such features from the training set. This ensured that the model only learned from independent drivers of revenue (customers, categories, statuses, lags, etc.). This experience highlighted how easily leakage can occur in forecasting tasks and reinforced the importance of validating feature design.

- Partial Months
    - Challenge: September 2023 and September 2025 were incomplete, which could bias training and evaluation.
    - Solution: Chose to drop September 2023 entirely and extrapolated September 2025 using scaled totals and synthetic rows to complete the month.

- Hyperparameter Tuning

    - Challenge: Choosing the best parameters for the model training.
    - Solution: Used Optuna with careful search spaces and chronological validation splits to tune models without leaking future data.


# 7.Final results

Using the tuned XGBoost multivariate model, I generated a forecast for October 2025.

Predicted Revenue for (Oct 2025) based on univariate modelling using XGBoost Regressor : 210,141
Predicted Revenue for (Oct 2025) based on multivariate modelling using XGBoost Regressor : 216,271.53


### Feature Importance Analysis

To understand what drives the revenue forecasts, I analyzed XGBoost feature importances using three methods: Gain, Cover, and Permutation Importance.

- Total quantity and total orders consistently emerged as the strongest predictors across all importance metrics. This aligns with intuition: months with higher order volume directly contribute to revenue.

- Repeat customer metrics (repeat orders, repeat customer share) were also influential. This shows that loyalty and returning customers are strong drivers of stable revenue.

- Order status rates (completed, shipped, pending) contributed meaningful signal. Operational efficiency and timely order fulfillment therefore had a measurable effect on monthly revenue outcomes.

- Time-based features (month, quarter, year) had a smaller but noticeable impact, capturing mild seasonality patterns in the data

Business interpretation:

The analysis highlights that demand-side volume (orders and quantities) is the main revenue driver, but customer loyalty and operational efficiency also play important supporting roles. For the business, this suggests that focusing on increasing repeat customer activity and improving completion/shipping rates could help sustain revenue growth, not just expanding order volume.

### Univariate vs multivariate

Compared to the univariate models, the multivariate approach consistently delivered more accurate and reliable forecasts. While the univariate setup could only leverage past revenue and lagged patterns, the multivariate design introduced additional signals such as customer counts, repeat orders, product diversity, and order status rates. These features provided richer context for explaining fluctuations in monthly revenue. As a result, the multivariate XGBoost model achieved lower errors (MAE and MAPE) and produced forecasts that aligned more closely with actual test data, demonstrating that sales drivers beyond revenue history were critical for capturing the true dynamics of the business.

Interestingly, the univariate models forecasted revenue for October 2025 at 217,141 (ARIMA), which is very close to the multivariate forecast of 216,271.53. While this convergence is reassuring, it is important to note that the univariate model performed poorly across the test window, often underpredicting and failing to capture fluctuations. In contrast, the multivariate model consistently aligned more closely with actuals and provided stable accuracy across multiple months. This shows that although univariate models can sometimes deliver reasonable point estimates, the multivariate approach is more reliable and business-ready because it leverages broader signals beyond past revenue alone


![alt text](Final_forecast.png)

The plot below compares actual vs. predicted revenue for the training and test periods, and shows the forecast for October 2025 (shaded region). The model tracked the test set closely, with only minor deviations, and produced a realistic forecast value consistent with the recent revenue levels.