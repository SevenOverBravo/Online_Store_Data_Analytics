# Online_Store_Data_Analytics

## Summary
This investigation attempted to increase the revenue of an online shopping website utilizing a large dataset of order, customer, product, and seller records. Such records were used to create a relational database in MySQL, with SQL queries being employed to identify traits that coincide with a high average items per order (AIPO) which were then used to recommend a targetted marketing based around such traits. While the marketing effort failed to produce an annual revenue increase above the benchmark of 10%, the project as a whole revealed insights that can be applied to a more comprehensive promotion initiative and thus provide a larger boost to company cash flows.

## Data, Analysis Plan, and Additional Methodology
The project utilizes an [open-source dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data?select=olist_products_dataset.csv) from Olist, a Brazilian e-commerce wesbite. An ER Diagram modeeling the dataset can be found in the "diagrams" folder.

In pursuit of identifying means to increase revenue, the anlysis will focus on the metric of average items per order (the mean quantity of items attributed to each order ID, abbreivated as AIPO). Since a higher AIPO indicates a greater number of items purchased and thus larger revenue figures, it is significantly revelant in the pursuit of increasing company cash flow. By investigating the relationship between AIPO and specific traits within entities, intuition suggests that a promotion plan centered on attributes associated with high AIPOs would increase the overall AIPO of a given period, therefore improving revenue. Examples of such traits include the location of a customer, time of year an order was placed, city a seller account is based in, and category of a product. The full analysis plan containing an organized diagram of each attribute can be found in the "diagrams" folder.

To find the total affect of emphasizing certain customer, order, seller, or product characteristics on the Olist website, revenue from 2018 (the most recent year in the dataset) and two scenarios in 2019 (revenue with and without promotion plan) will be calculated using the following formula: Revenue = Number of Orders * AIPO * Median Price per Item (median will be used as a measure of average price per item instead of mean, as the price column contains many large outliers). In finding the these figures for 2019, the following will be assumed:

* The growth in number of orders from 2017 to 2018 is roughly identical to that of 2018 to 2019
* Both AIPO and median price per item in 2019 remain the same from 2018
* 

Hence, the goal of this analysis is as follows: "Utilize Olist customer and order records to detect traits of customers, orders, sellers, or products that show signs of a higher quantity of average items purchased per order, eventually proposing a solution to increase said metric so that annual revenue in 2019 will increase by at least 10% from a control"

## Key Findings and Results

### Promotion Plan

## Future Research
