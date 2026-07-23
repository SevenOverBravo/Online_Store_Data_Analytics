# Online_Store_Data_Analytics

## Summary
This investigation attempted to increase the revenue of an online shopping website utilizing a large dataset of order, customer, product, and seller records. Such records were used to create a relational database in MySQL, with SQL queries being employed to identify traits that coincide with a high average items per order (AIPO) which were then used to recommend a targetted marketing based around such traits. While the marketing effort failed to produce an annual revenue increase above the benchmark of 10%, the project as a whole revealed insights that can be applied to a more comprehensive promotion initiative and thus provide a larger boost to company cash flows.

## Data and Analysis Plan
The project utilizes an [open-source dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data?select=olist_products_dataset.csv) from Olist, a Brazilian e-commerce wesbite. An ER Diagram modeeling the dataset can be found in the "diagrams" folder.

In pursuit of identifying means to increase revenue, the anlysis will focus on the metric of average items per order (the mean quantity of items attributed to each order ID, abbreivated as AIPO). Since a higher AIPO indicates a greater number of items purchased and thus larger revenue figures, it is significantly revelant in the pursuit of increasing company cash flow. By investigating the relationship between AIPO and specific traits within entities, intuition suggests that a promotion plan centered on attributes associated with high AIPOs would increase the overall AIPO of a given period, therefore improving revenue. Examples of such traits include the location of a customer, time of year an order was placed, city a seller account is based in, and category of a product. The full analysis plan containing an organized diagram of each attribute can be found in the "diagrams" folder.


Hence, the goal of this analysis is as follows: "Utilize Olist customer and order records to detect traits of customers, orders, sellers, or products that show signs of a higher quantity of average items purchased per order, eventually proposing a solution to increase said metric so that annual revenue in 2019 will increase by at least 10% from a control"

## Key Findings and Results

## Future Research
