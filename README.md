# dbt Data Transformation Project - Extract, Load, Transform (ELT) - Canada Inflation Indicators

## Overview
This project demonstrates the use of [dbt](https://www.getdbt.com/), a SQL-first transformation workflow, for performing Extract, Load, and Transform (ELT) operations on various data sets. It showcases the power of dbt in handling data transformations using SQL, with source and version control managed through GitHub. Additionally, the project highlights dbt's capabilities in conducting Data Quality Testing using SQL queries.

## Purpose
The primary objective of this project is to showcase the effective application of dbt in Extract, Load, and Transform (ELT) processes. The project emphasizes leveraging dbt to establish a structured and efficient approach for data transformation. Key focuses include:

- **Structured Data Transformation:** Utilizing dbt's capabilities to systematically transform data, thereby enhancing the organization and clarity of the data transformation workflow.
- **Ensuring Data Quality:** Implementing dbt's testing features to maintain high standards of data integrity and accuracy throughout the transformation process.
- **Code Consistency and Efficiency:** Employing dbt to ensure that the code used for data transformation is not only consistent across various models but also optimized for efficiency.

This project serves as a practical demonstration of how dbt can streamline ELT processes, making them more reliable, maintainable, and scalable.

## Tools and Technologies
- **dbt:** Used for data transformation and testing.
- **SQL:** Primary language for defining data transformations.
- **GitHub:** For source and version control.
- **Google BigQuery:** Data warehousing solution where the transformed data is loaded.
- **Jinja Templates:** Utilized in dbt for efficient SQL code management.

## Setup dbt cloud
dbt Cloud is the fastest and most reliable way to deploy your dbt jobs. [Setup dbt cloud](https://docs.getdbt.com/docs/cloud/about-cloud-setup)

## Connect dbt cloud to BigQuery
[Quickstart for dbt Cloud and BigQuery](https://docs.getdbt.com/guides/bigquery?step=1)

## Data Sources
The project involves reading data from four different tables located in raw datasets within Google BigQuery. These tables include information on:
- **Canada CPI (Consumer Price Index)** (Table 18-10-0004-01 Consumer Price Index, monthly, not seasonally adjusted. Statistics Canada. https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1810000401)
- **Canada Unemployment Rate** (Table 14-10-0017-01 Labour force characteristics by sex and detailed age group, monthly, unadjusted for seasonality. Statistics Canada. https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1410001701)
- **Canada Interest Rates** (Canadian interest rates and monetary policy variables. Bank of Canada. https://www.bankofcanada.ca/rates/interest-rates/canadian-interest-rates/)
- **Canada Commodities Price Index** (Commodity price index. Bank of Canada. https://www.bankofcanada.ca/rates/price-indexes/bcpi/)

### CSV Files
The raw CSV files used in this project can be found in the repository's `raw` directory. These files contain the extracted data from the above sources, formatted for use in the project's data transformation processes.

Access the CSV files here: [dbt Inflation Indicators - Raw CSV Files](https://github.com/PetePhuaphan/dbt-inflation-indicators/tree/main/raw).

### CSV Files and BigQuery Integration
The raw CSV files corresponding to these data sources are uploaded to Google BigQuery under the `raw` dataset. This step integrates the data into the BigQuery environment, allowing for its subsequent processing and transformation using dbt models.

![Raw dataset in BigQuery](https://github.com/PetePhuaphan/dbt-inflation-indicators/blob/main/raw/Screenshot%202023-12-16%20112524.png?raw=true)

## Transformation Process
The transformation process is a critical component of this project, involving the extraction and transformation of data from four key sources in the BigQuery raw dataset. Each source data set is processed using specific dbt models, and dbt's Jinja templates are employed for efficient SQL code management. All dbt models used for this process are located in the `models` folder of the project.  The process for each data set is as follows:

1. **Commodities Price Index:**
   - dbt Model: `ca_commodities_monthly`
   - materialized: view
   - The model extracts and formats monthly commodity price index data, including total, energy, metals, forestry, agriculture, and fish, from the data source, presenting it in a Year-Month format.

2. **Canada CPI (Consumer Price Index):**
   - dbt Model: `ca_cpi_factors_monthly`
   - materialized: view
   - This model uses Jinja, a template engine, to dynamically generate a SQL query. The purpose of the query is to compile and organize data related to the Consumer Price Index (CPI) across various categories like "Food", "Shelter", "Transportation", etc. The final result is a structured dataset where each CPI category's data is aligned by date, making it convenient for analysis or reporting purposes.

3. **Unemployment Rate:**
   - dbt Model: `ca_unemployment_monthly`
   - materialized: view
   - This model selects monthly unemployment rates for both sexes aged 15 and over.

4. **Interest Rates:**
   - There is no specific dbt model for the transformation of interest rate data. Instead, this data is integrated and joined with other datasets in the `ca_inflation_indicators` model. 

5. **Inflation factors**
   - dbt model: `ca_inflation_indicators`
   - materialized: table
   - This model combines monthly data on CPI factors, interest rates, unemployment rates, and various commodity price indices from previose dbt models. It aligns them by date using LEFT JOINs, creating a comprehensive table that can be used for detailed economic analysis or reporting.
     
![ca_inflation_indicators table](https://github.com/PetePhuaphan/dbt-inflation-indicators/blob/main/raw/Screenshot%202023-12-16%20134906.png?raw=true)

During the transformation process, dbt's Jinja templates are extensively utilized. These templates enable efficient and dynamic SQL code management, allowing for more flexible and maintainable transformations. The use of Jinja templates also aids in parameterization and modularization of the SQL scripts, making the entire process more efficient and scalable.

### Example: Utilizing Jinja Templates in the CPI Model

A key feature of our project is the use of Jinja templates for efficient SQL code management, particularly in handling repetitive SQL structures. Below is a detailed explanation of how we use Jinja templates with a for loop in the CPI (Consumer Price Index) model:

```jinja
{% set cpi_factors = ["All-items", "Food", "Shelter", "Household operations, furnishings and equipment", "Clothing and footwear", "Transportation", "Health and personal care", "Recreation, education and reading", "Alcoholic beverages, tobacco products and recreational cannabis"] %}

WITH
{% for cpi_factor in cpi_factors %}
    `{{cpi_factor}}Data` AS (
    SELECT 
        _REF_DATE_, 
        VALUE AS `{{cpi_factor}}`
    FROM 
        {{ source('raw', 'ca_cpi_monthly') }}
    WHERE 
        `Products_and_product_groups` = '{{cpi_factor}}'
    )
    {%- if not loop.last -%}
    ,
    {%- endif -%}
{% endfor %}
```
## Source Configuration

In dbt, the `source.yml` file is used to define and document the sources of data. This setup is crucial for establishing clear references to the datasets being transformed. Below is an example of the `source.yml` file used in this project:

```yaml
version: 2

sources:
  - name: raw
    schema: raw  
    tables:
      - name: ca_commodity_price_index_monthly
      - name: ca_cpi_monthly
      - name: ca_interest_rate_monthly
      - name: ca_unemployment_rate_monthly
```

## Data Quality Testing

Data quality is a paramount concern in data transformation projects. dbt's SQL-based testing capabilities are utilized to ensure this quality, adding reliability and accuracy to the transformed data. dbt enables the definition of test cases directly within the `schema.yml` file, which is effective in validating data integrity and consistency. Below is an example of how test cases are set up for the `ca_commodities_monthly` model:

```yaml
version: 2

models:
    - name: ca_commodities_monthly
      description: "This model contains transformed data for monthly commodities. It includes various test cases to ensure data quality."
      columns:
          - name: date
            description: "The primary key for this table, representing the date of the data record."
            tests:
                - unique
                - not_null
```

## dbt Documentation and Data Lineage

### Generating Project Documentation

Once the environment is set up and `dbt build` is executed, dbt automatically generates documentation for the project. This documentation is a valuable resource for understanding the structure and flow of the data transformation processes. It includes detailed information about the models, their relationships, and the overall data lineage within the project.

### Lineage Graph

To visualize the data lineage and relationships between models in this project, refer to the lineage graph linked below. This graph offers a graphical representation of how different models are interconnected and how data is processed throughout the project.

![dbt Inflation Indicators - Lineage Graph](https://github.com/PetePhuaphan/dbt-inflation-indicators/blob/main/raw/lineage_graph.png?raw=true)

This lineage graph is an essential tool for anyone looking to understand the data workflow and dependencies within the dbt project.


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [dbt community](https://getdbt.com/community) to learn from other analytics engineers
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
