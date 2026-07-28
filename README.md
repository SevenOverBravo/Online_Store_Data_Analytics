# Online_Store_Data_Analytics

## Summary
This investigation attempted to increase the revenue of an online shopping website utilizing a large dataset of order, customer, product, and seller records. Such records were used to create a relational database in MySQL, with SQL queries being employed to identify traits that coincide with a high average items per order (AIPO) which were then used to recommend a targeted marketing based around such traits. While the marketing effort failed to produce an annual revenue increase above the benchmark of 10%, the project as a whole revealed insights that can be applied to a more comprehensive promotion initiative and thus provide a larger boost to company cash flows.

## Data, Analysis Plan, and Additional Methodology
The project utilizes an [open-source dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data?select=olist_products_dataset.csv) from Olist, a Brazilian e-commerce website. An ER Diagram modeling the dataset can be found in the "diagrams" folder. Note that any prices or figures representing currency are listed in Brazilian Real, which has been translated into USD in later figures according to the 2019 exchange rate of 0.25 USD = 1 Real. 

In pursuit of identifying means to increase revenue, the anlysis will focus on the metric of average items per order (the mean quantity of items attributed to each order ID, abbreviated as AIPO). Since a higher AIPO indicates a greater number of items purchased and thus larger revenue figures, it is significantly relevant in the pursuit of increasing company cash flow. By investigating the relationship between AIPO and specific traits within entities, intuition suggests that a promotion plan centered on attributes associated with high AIPOs would increase the overall AIPO of a given period, therefore generating higher revenue. Examples of such traits include the location of a customer, time of year an order was placed, city a seller account is based in, and category of a product. The full analysis plan containing an organized diagram of each attribute can be found in the "diagrams" folder.

To find the total effect of emphasizing certain customer, order, seller, or product characteristics on the Olist website, revenue from 2018 (the most recent year in the dataset) and two scenarios in 2019 (revenue with and without promotion plan) will be calculated using the following formula: Revenue = Number of Orders * AIPO * Median Price per Item (median will be used as a measure of average price per item instead of mean, as the price column contains many large outliers). In finding the these figures for 2019, the following will be assumed:

* The growth in number of orders from 2017 to 2018 is roughly identical to that of 2018 to 2019
* Both AIPO and median price per item in the 2019 non-promotion scenarios are equal to those in 2018

Once revenue for each 2019 scenario is calculated, they'll each be measured against the 2018 revenue figure to find the percent growth in revenue between them. Finally, the total effect of the promotion plan will be represented within the percent growth between 2018 and the 2019 scenario with the promotion plan minus that between 2018 and the 2019 without it. 

Hence, the goal of this analysis is as follows: "Utilize Olist customer and order records to detect traits of customers, orders, sellers, or products that show signs of a higher quantity of average items purchased per order, eventually proposing a solution to increase said metric so that annual revenue in 2019 will increase by at least 10% from a control"

### Notes on Data Cleaning
Before the analysis could begin, there were a host of issues plaguing the usability of the Olist dataset. Hence, the following measures were taken in Excel:

* Replace all accented/special Brazilian Portuguese characters with their English language counterparts (i.e. "á" becomes "a", "õ" becomes "o", and "ç" becomes "c") to ensure no errors would arise from any symbols outside of the UTF-8 file format
  * It's true that some Portuguese words change their meaning when certain letters are not accented, but since this analysis won't utilize any string data (at   least, not in any context where the meaning of each string is important), such a measure is defensible
* Reformat all datetime values so they're compatible with MySQL (i.e. format so each datetime values reads as YYYY-MM-DD hh:mm:ss)
* Remove all incomplete orders (i.e. rows in the orders table without any purchase timestamps) from the dataset
* Aggregate geolocation entries on zip code to give the table its primary key
  * The "city" and "state" entries in each aggregated row were filled with the city and state associated with each zip code, while the each latitude and longitude value was averaged between all values from each zip code

## Key Findings and Results
The analysis in MySQL found a series of attributes that correlate with an above average AIPO, including the following:

* Product Category: Orders that included items from any of the furniture product categories had higher AIPOs than those that didn't, which is further confirmed by high order counts in these classes 
* Seller IDs: Orders associated with certain seller accounts have above average AIPO, although only a few specific sellers have high enough order counts to consider the AIPO accurate under the Law of Large Numbers
* Customer Location: Orders from customers that live in certain states (like Minas Gerais and Goiás) have above-average AIPOs. Although this is only by a small margin, the large population of both of these states signals a market development opportunity

For the sake of this analysis, only one of these relationships will be employed in the promotion plan. Since the furniture product categories listed above not only have a high AIPO, but also possess large order quantities that ensure the given AIPO figure is close to its true value under the Law of Large Numbers, making this avenue the most likely to obtain high returns.

### Promotion Plan and Final Calculations
As mentioned previously, the idea behind promoting high AIPO characteristics (in this case, furniture products) increases the number of orders associated with said traits, thereby increasing AIPO and revenue. To model this, any product categories associated with furniture will be assumed to grow in order count at a 50% higher rate from a baseline between 2018 and 2019. For example, the percent increase in orders between 2017 and 2018 was 19.76%. Since this is asssumed to be the same growth rate for the next year, all furniture products will have 29.64% more orders (50% more than 19.76%) in 2019 compared to 2018. The 50% figure was chosen as an upper-bound result of the promotion plan for the sake of testing its significance. Essentially, if revenue growth does not meet the benchmark despite a wildly successful marketing outcome, the promotion plan can be confidently determined to be uneffective.  

After creating both scenarios for 2019, the following totals were obtained:
| Year and Scenario | Non-Furniture Order Count | Furniture Order Count | Average Items Per Order | Median Price per Item | Total Orders | Total Revenue (USD) | % Revenue Growth from 2018 |
|---|---|---|---|---|---|---|---|
| 2019, No Promotion | 59,836 | 4,847 | 1.142 | $74.99 | 64,681 | $1,384,797.25 | 19.76% |
| 2019, With Promotion | 59,836 | 5,248 | 1.151 | $76.50 | 65,083 | $1,432,663.94 | 23.89% |

Note: Revenue for 2018 is $1,158,283.30

The table indicates that, with the promotion plan, the estimated revenue from 2019 increases by a margin of 4.1% or ~$50,000. Not only is this figure below the benchmark of 10%, but when factoring in the potential costs of the promotion plan, it's likely that a portion of the revenue increase could be eaten up by marketing provisions. Furthermore, it's worth nothing that AIPO, despite being the target metric of this analysis, barely grew as a result of the promotion plan, with most of the revenue increase resulting from improved order counts and a higher median price per item.

A dashboard of useful visualizations is present in the "diagrams" folder. 

## Conclusion and Future Research
As evident from the results, the promotion of high AIPO furniture products did not to achieve a significant effect on annual revenue. However, it's worth noting that the promotion plan in question was extremely simple, only advertising a single variety of product out of dozens of categories. There's a possibility that promoting multiple classes of products at once would produce revenue growth conducive to that of the 10% baseline. For example, goods within the home construction and bed & bath categories displayed large order counts (both over 10,000) and above-average AIPOs in regard to the orders they were associated with. If these products were added to the current promotion plan, it's likely that revenue in 2019 would see additional growth through increased AIPO and order numbers.

Speaking of order counts, the findings of this project indicate that AIPO may not have been the most effective metric to focus on. Such a fact is evident when noting that most of the additional revenue growth in the promotion plan scenario was not due to AIPO (which increased by only 0.009), but rather the rise in order count and median price per item. Thus, future research would focus less on increasing average items per order and more so on the other two factors of the revenue equation. Rather than identifying characteristics of the dataset that correspond with high AIPO, such an analysis would instead focus on promoting attributes associated with high order counts and median price per product. 

Ultimately, although the AIPO promotion plan proved not to be worth Olist's time, the analysis revealed multiple other paths to take in the pursuit of increasing revenue.

