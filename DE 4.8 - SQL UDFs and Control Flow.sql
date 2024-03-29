-- Databricks notebook source
-- MAGIC %md <i18n value="931bf77d-810b-4930-b45c-b00c184029a0"/>
-- MAGIC 
-- MAGIC 
-- MAGIC # SQL UDFs and Control Flow
-- MAGIC 
-- MAGIC Databricks added support for User Defined Functions (UDFs) registered natively in SQL starting in DBR 9.1.
-- MAGIC 
-- MAGIC This feature allows users to register custom combinations of SQL logic as functions in a database, making these methods reusable anywhere SQL can be run on Databricks. These functions leverage Spark SQL directly, maintaining all of the optimizations of Spark when applying your custom logic to large datasets.
-- MAGIC 
-- MAGIC In this notebook, we'll first have a simple introduction to these methods, and then explore how this logic can be combined with **`CASE`** / **`WHEN`** clauses to provide reusable custom control flow logic.
-- MAGIC 
-- MAGIC ## Learning Objectives
-- MAGIC By the end of this lesson, you should be able to:
-- MAGIC * Define and registering SQL UDFs
-- MAGIC * Describe the security model used for sharing SQL UDFs
-- MAGIC * Use **`CASE`** / **`WHEN`** statements in SQL code
-- MAGIC * Leverage **`CASE`** / **`WHEN`** statements in SQL UDFs for custom control flow

-- COMMAND ----------

-- MAGIC %md <i18n value="df80ac46-fb12-44ed-bb37-dcc5a4d73d4a"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## Setup
-- MAGIC Run the following cell to setup your environment.

-- COMMAND ----------

-- MAGIC %run ../Includes/Classroom-Setup-04.8

-- COMMAND ----------

-- MAGIC %md <i18n value="f4fec594-3cd7-43c9-b88e-3ccd3a99c6be"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## Create a Simple Dataset
-- MAGIC 
-- MAGIC For this notebook, we'll consider the following dataset, registered here as a temporary view.

-- COMMAND ----------

CREATE OR REPLACE TEMPORARY VIEW foods(food) AS VALUES
("beef"),
("beans"),
("potatoes"),
("bread");

SELECT * FROM foods

-- COMMAND ----------

-- MAGIC %md <i18n value="65577a77-c917-441c-895b-8ba146c837ff"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## SQL UDFs
-- MAGIC At minimum, a SQL UDF requires a function name, optional parameters, the type to be returned, and some custom logic.
-- MAGIC 
-- MAGIC Below, a simple function named **`yelling`** takes one parameter named **`text`**. It returns a string that will be in all uppercase letters with three exclamation points added to the end.

-- COMMAND ----------

CREATE OR REPLACE FUNCTION yelling(text STRING)
RETURNS STRING
RETURN concat(upper(text), "!!!")

-- COMMAND ----------

-- MAGIC %md <i18n value="4cffc92d-3133-45ba-97c8-b0bc4c9e419b"/>
-- MAGIC 
-- MAGIC 
-- MAGIC Note that this function is applied to all values of the column in a parallel fashion within the Spark processing engine. SQL UDFs are an efficient way to define custom logic that is optimized for execution on Databricks.

-- COMMAND ----------

SELECT yelling(food) FROM foods

-- COMMAND ----------

-- MAGIC %md <i18n value="e1749d08-2186-4e1c-9214-18c8199388af"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## Scoping and Permissions of SQL UDFs
-- MAGIC 
-- MAGIC Note that SQL UDFs will persist between execution environments (which can include notebooks, DBSQL queries, and jobs).
-- MAGIC 
-- MAGIC We can describe the function to see where it was registered and basic information about expected inputs and what is returned.

-- COMMAND ----------

DESCRIBE FUNCTION yelling

-- COMMAND ----------

-- MAGIC %md <i18n value="6a6eb6c6-ffc8-49d9-a39a-a5e1f6c230af"/>
-- MAGIC 
-- MAGIC 
-- MAGIC By describing extended, we can get even more information. 
-- MAGIC 
-- MAGIC Note that the **`Body`** field at the bottom of the function description shows the SQL logic used in the function itself.

-- COMMAND ----------

DESCRIBE FUNCTION EXTENDED yelling

-- COMMAND ----------

-- MAGIC %md <i18n value="a31a4ad1-5608-4bfb-aae4-a411fe460385"/>
-- MAGIC 
-- MAGIC 
-- MAGIC SQL UDFs exist as objects in the metastore and are governed by the same Table ACLs as databases, tables, or views.
-- MAGIC 
-- MAGIC In order to use a SQL UDF, a user must have **`USAGE`** and **`SELECT`** permissions on the function.

-- COMMAND ----------

-- MAGIC %md <i18n value="155c70b7-ed5e-47d2-9832-963aa18f3869"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## CASE/WHEN
-- MAGIC 
-- MAGIC The standard SQL syntactic construct **`CASE`** / **`WHEN`** allows the evaluation of multiple conditional statements with alternative outcomes based on table contents.
-- MAGIC 
-- MAGIC Again, everything is evaluated natively in Spark, and so is optimized for parallel execution.

-- COMMAND ----------

SELECT *,
  CASE 
    WHEN food = "beans" THEN "I love beans"
    WHEN food = "potatoes" THEN "My favorite vegetable is potatoes"
    WHEN food <> "beef" THEN concat("Do you have any good recipes for ", food ,"?")
    ELSE concat("I don't eat ", food)
  END
FROM foods

-- COMMAND ----------

-- MAGIC %md <i18n value="50bc0847-94d2-4167-befe-66e42b287ad0"/>
-- MAGIC 
-- MAGIC 
-- MAGIC ## Simple Control Flow Functions
-- MAGIC 
-- MAGIC Combining SQL UDFs with control flow in the form of **`CASE`** / **`WHEN`** clauses provides optimized execution for control flows within SQL workloads.
-- MAGIC 
-- MAGIC Here, we demonstrate wrapping the previous logic in a function that will be reusable anywhere we can execute SQL.

-- COMMAND ----------

CREATE FUNCTION foods_i_like(food STRING)
RETURNS STRING
RETURN CASE 
  WHEN food = "beans" THEN "I love beans"
  WHEN food = "potatoes" THEN "My favorite vegetable is potatoes"
  WHEN food <> "beef" THEN concat("Do you have any good recipes for ", food ,"?")
  ELSE concat("I don't eat ", food)
END;

-- COMMAND ----------

-- MAGIC %md <i18n value="05cb00cc-097c-4607-8738-ab4353536dda"/>
-- MAGIC 
-- MAGIC 
-- MAGIC Using this method on our data provides the desired outcome.

-- COMMAND ----------

SELECT foods_i_like(food) FROM foods

-- COMMAND ----------

-- MAGIC %md <i18n value="24ee3267-9ddb-4cf5-9081-273502f5252a"/>
-- MAGIC 
-- MAGIC 
-- MAGIC While the example provided here are simple string methods, these same basic principles can be used to add custom computations and logic for native execution in Spark SQL. 
-- MAGIC 
-- MAGIC Especially for enterprises that might be migrating users from systems with many defined procedures or custom-defined formulas, SQL UDFs can allow a handful of users to define the complex logic needed for common reporting and analytic queries.

-- COMMAND ----------

-- MAGIC %md <i18n value="9405ddea-5fb0-4168-9fd2-2b462d5809d9"/>
-- MAGIC 
-- MAGIC  
-- MAGIC Run the following cell to delete the tables and files associated with this lesson.

-- COMMAND ----------

-- MAGIC %python
-- MAGIC DA.cleanup()
