use superstoreDB

select * from Superstore_raw;

--Query 1: Region-wise Total Sales aur Profit
select Region,
sum(sales) as total_sales,
sum(profit) as total_profit,
count(*) as total_orders
from Superstore_raw
group by Region
order by total_sales desc;

--Query 2: Category-wise Total Sales aur Profit
select category,
sum(sales) as total_sales,
sum(profit) as total_profit,
count(*) as total_orders
from Superstore_raw
group by category
order by total_sales desc;

--Query 3: Top 5 Best-Selling Products (by Sales)
select top 5 [product_name],
sum(sales) as total_sales,
sum(quantity) as total_quantity
from Superstore_raw
group by [product_name]
order by total_sales desc;

--Query 4: Top 5 Most Profitable Products
select top 5 [product_name],
sum(profit) as total_profit,
sum(sales) as total_sales
from Superstore_raw
group by [product_name]
order by total_profit desc;

--Query 5: Customer Segment-wise Average Order Value
select segment,
count(*) as total_orders,
avg(sales) as avg_order_value,
avg(sales) as tota_sales
from Superstore_raw
group by segment
order by avg_order_value desc;

--Query 6: Loss-making Sub-Categories
select sub_category,
sum(profit) as total_profit,
sum(sales) as total_sales
from Superstore_raw
group by sub_category
having sum(profit) < 0
order by total_profit asc;

--Query 7: Monthly Sales Trend
select year(order_date) as order_year,
month(order_date) as order_month,
sum(sales) as total_sales,
sum(profit) as total_profit
from Superstore_raw
group by year(order_date),month(order_date)
order by order_year,order_month;

--Query 8: State-wise Top 10 Sales
select top 10 state,
sum(sales) as total_sales,
sum(profit) as total_profit
from Superstore_raw
group by state
order by total_sales desc;

--Query 9: Ship Mode-wise Average Delivery Days
select ship_mode,
avg(datediff(day,order_date,ship_date)) as avg_delivery_days,
count(*) as total_orders
from Superstore_raw
group by ship_mode
order by avg_delivery_days;

--Query 10: High-Discount Orders with Negative Profit
select product_name,
discount,
sales,
profit
from Superstore_raw
where discount > 0.3 and profit < 0
order by discount desc;

select distinct Customer_ID, Customer_Name, Segment, Country, City, State, Postal_Code, Region
into customers
from superstore_raw;

select * from customers;

select distinct Product_ID, Product_Name, Category, Sub_Category
into Products
from superstore_raw;

select * from Products;

--Query 11: Get top 10 order, customer & product names via JOIN.
select top 10 o.Order_id, c.Customer_Name, p.Product_Name, 
       o.Sales, o.Profit, o.Region
from superstore_raw o
join Customers c on o.Customer_id = c.Customer_id
join Products p on o.Product_id = p.Product_id;

--Query 12: Region-wise Top-Selling Product (RANK Window Function)
select Region, Product_Name, Total_Sales, Sales_Rank
from (
   select Region, 
           Product_Name,
           sum(Sales) AS Total_Sales,
          rank() over (partition by Region order by sum(Sales) desc) as Sales_Rank
   from superstore_raw
group by Region, Product_Name
) ranked
where Sales_Rank = 1;

--Query 13: Running Total of Monthly Sales
SELECT YEAR(Order_Date) AS Order_Year,
       MONTH(Order_Date) AS Order_Month,
       SUM(Sales) AS Monthly_Sales,
       SUM(SUM(Sales)) OVER (ORDER BY YEAR(Order_Date), MONTH(Order_Date)) AS Running_Total
FROM superstore_raw
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Order_Year, Order_Month;

--Query 14: Customers Who Spend More Than the Average (Subquery)
SELECT Customer_ID, Customer_Name, SUM(Sales) AS Total_Spend
FROM superstore_raw
GROUP BY Customer_ID, Customer_Name
HAVING SUM(Sales) > (
    SELECT AVG(CustomerTotal.TotalSales)
    FROM (
        SELECT Customer_ID, SUM(Sales) AS TotalSales
        FROM superstore_raw
        GROUP BY Customer_ID
    ) CustomerTotal
)
ORDER BY Total_Spend DESC;

--Query 15: Year-over-Year Sales Growth % (LAG Window Function)
SELECT Order_Year, Yearly_Sales,
       LAG(Yearly_Sales) OVER (ORDER BY Order_Year) AS Prev_Year_Sales,
       ROUND(
         (Yearly_Sales - LAG(Yearly_Sales) OVER (ORDER BY Order_Year)) * 100.0 
         / LAG(Yearly_Sales) OVER (ORDER BY Order_Year), 2
       ) AS YoY_Growth_Percent
FROM (
    SELECT YEAR(Order_Date) AS Order_Year,
           SUM(Sales) AS Yearly_Sales
    FROM superstore_raw
    GROUP BY YEAR(Order_Date)
) yearly
ORDER BY Order_Year;