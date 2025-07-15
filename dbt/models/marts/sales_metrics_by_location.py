import os
import sys
import zipfile
from snowflake.snowpark.functions import col, lit, concat, count, sum as sum_, coalesce
import holidays
# import pctest

def is_holiday(date_col):
    french_holidays = holidays.France()
    return date_col in french_holidays

def model(dbt, session):
    """
    This model demonstrates basic Snowpark transformations using dbt Python models.
    It joins location data with trucks and aggregates metrics by location.
    Uses raw_pos models as sources instead of tb_101 directly.
    """
    dbt.config(
        materialized = "table",
        packages = ["holidays"],
        imports = ['@dbt_demo.dev.packages/pctest.zip'],
    )

    # List files in the stage
    results = session.sql("LIST @mdbt_demo.dev.packages/").collect()
    
    # Extract file names from the result
    rows = [Row(file_name=row['name']) for row in results]

    # Convert list of rows into DataFrame
    return session.create_dataframe(rows)

    # # Snowflake returns a result with a column named "GET_MESSAGE" (the name of the proc)
    # is_holiday_flag = result[0][0]  # or result[0]["GET_MESSAGE"]


    # Get tables using dbt's ref function to reference the raw_pos models
    locations_df = dbt.ref('raw_pos_location')
    trucks_df = dbt.ref('raw_pos_truck')
    orders_df = dbt.ref('raw_pos_order_header')
    
    # Join locations with trucks to get truck counts by location
    location_trucks = (
        trucks_df
        .join(
            locations_df, 
            trucks_df["PRIMARY_CITY"] == locations_df["CITY"], 
            "inner"
        )
        # Use simple column names and case-insensitive approach
        .select(
            locations_df["LOCATION_ID"],
            locations_df["LOCATION"],
            locations_df["CITY"],
            trucks_df["TRUCK_ID"]
        )
        .groupBy("LOCATION_ID", "LOCATION", "CITY")
        .agg(count("TRUCK_ID").alias("TRUCK_COUNT"))
    )
    
    # Join with order data to get sales metrics
    location_metrics = (
        orders_df
        .join(locations_df, "LOCATION_ID", "inner")
        .groupBy("LOCATION_ID")
        .agg(
            sum_("ORDER_TOTAL").alias("TOTAL_SALES"),
            sum_("ORDER_AMOUNT").alias("TOTAL_AMOUNT"),
            sum_("ORDER_TAX_AMOUNT").alias("TOTAL_TAX")
        )
    )
    
    # Create a more simplified final version
    joined_df = location_trucks.join(location_metrics, "LOCATION_ID", "left")
    
    # Add the calculated columns after join to avoid column reference issues
    final_df = (
        joined_df
        .select(
            col("LOCATION_ID"),
            col("LOCATION"),
            col("CITY"),
            col("TRUCK_COUNT"),
            # Use coalesce instead of fillna for Column objects
            coalesce(col("TOTAL_SALES"), lit(0)).alias("TOTAL_SALES"),
            coalesce(col("TOTAL_AMOUNT"), lit(0)).alias("TOTAL_AMOUNT"),
            coalesce(col("TOTAL_TAX"), lit(0)).alias("TOTAL_TAX")
        )
    )
    
    # Add the full location description as a separate step
    final_with_desc = (
        final_df
        .withColumn(
            "LOCATION_DESCRIPTION", 
            concat(
                col("CITY"), 
                lit(" (Trucks: "), 
                col("TRUCK_COUNT").cast("string"), 
                lit(")")
            )
        )
        # .withColumn("HARDCODED_DATE", lit(hardcoded_date))
        # .withColumn("IS_HOLIDAY_FRANCE", lit(is_holiday_flag))
    )
    
    # Return the final dataframe
    return final_with_desc