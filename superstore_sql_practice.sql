use superstore
Select * from superstore;

-- SUPERSTORE ANALYSIS.........
-- (Q1) Display all the records in the table..
Select * from superstore

 -- (Q2)Show only Order ID, Order Date, Sales, and Profit.
 Select `Order ID`,`Order Date`,Sales,Profit from superstore

 -- (Q3)Retrieve all orders where Sales are greater than 500.
 select `Order ID` ,Sales from superstore
 where Sales>500

-- (Q4)Find all orders shipped using "Second Class".
select`Order ID`,`Ship Mode` from superstore
where `Ship Mode`='Second Class';

-- (Q5)List unique values in the Ship Mode column.
Select Distinct `Ship Mode` from superstore;

-- (Q6)Display top 10 highest sales records.
Select Sales as highest_sales
from superstore
order by Sales Desc
limit 10;

-- (Q7)Get all orders placed in California.
select count(State) ,State from superstore 
where State = 'California'

-- (Q8) Show all records where Discount is greater than 0.2
select * from superstore 
where Discount >0.2

-- (Q9)Count how many unique customers are in the dataset.
select Count(Distinct `Customer ID`) as unique_customers from superstore 

-- (Q10) Find the earliest and latest Order Date.
select max(`Order date`) as latest_order,
min(`order date`)as oldest_date 
from superstore

-- (Q11)Find the total sales for the entire dataset.
Select sum(Sales) as total_sales 
from superstore

-- (Q12)Find the average profit per order.
select `order id`,avg(Profit)as avg_profit_per_order 
from superstore
group by `order id`;

-- (Q13)Show total quantity sold per category.
Select Category,sum(Quantity) as total_qty_per_category
from superstore
group by Category;

-- (14)Get total sales by region, sorted by highest sales first.
Select Region,Sum(Sales) as Total_sales
from superstore
group by Region
order by Total_sales desc;

-- (Q15)Find the top 5 cities with the most orders.
Select City, count(`Order ID`) as total_orders
from superstore
group by City
order by total_orders desc
limit 5

-- (Q16)Count how many orders each Ship Mode has.
Select `Ship Mode`, count(`Order ID`) as total_orders
from superstore
group by `Ship Mode`
order by total_orders desc

-- (Q17)Find total profit and average discount per Sub-Category.
Select `Sub-Category`,sum(Profit) as total_profit,avg(discount) as avg_discount
from superstore
group by `Sub-Category`


-- (Q18)Identify the category with the highest total sales.
Select Category,Sum(Sales) as Total_sales
from superstore
group by Category
order by Total_sales desc;

-- (Q19)Find monthly total sales.

-- checking data type for column order date

Select data_type                  
from information_schema.columns
where table_name='superstore'
and column_name='Order Date';

select str_to_date(`Order Date`,'%d/%M/%Y')as Date_converted
from superstore;


SELECT DISTINCT `Order Date`
FROM superstore
ORDER BY `Order Date`
 
 Select
    `Order Date`,
    Case
        When `Order Date` Like '%/%/%' Then STR_TO_DATE(`Order Date`, '%m/%d/%Y')
        When  `Order Date` Like  '____-__-__' Then STR_TO_DATE(`Order Date`, '%Y-%m-%d')
        When`Order Date` Like '%-%-%' Then STR_TO_DATE(`Order Date`, '%d-%b-%Y')
        Else NULL
    End as Converted_Date
From superstore;


ALTER TABLE superstore 
ADD COLUMN connverted_date DATE;

UPDATE superstore
SET connverted_date = CASE
    WHEN `Order Date` LIKE '%/%/%' 
         THEN STR_TO_DATE(`Order Date`, '%m/%d/%Y')
    WHEN `Order Date` LIKE '____-__-__' 
         THEN STR_TO_DATE(`Order Date`, '%Y-%m-%d')
    WHEN `Order Date` LIKE '%-%-%' 
         THEN STR_TO_DATE(`Order Date`, '%d-%b-%Y')
    ELSE NULL
END;


select * from superstore

Select data_type                  
from information_schema.columns
where table_name='superstore'
and column_name='connverted_date';

SELECT 
    date_format(connverted_date, '%y-%m') AS Month,
    SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY date_format(connverted_date, '%y-%m')
ORDER BY Month;

-- if we want to check for particular month then........
SELECT 
    date_format(connverted_date, '%y-%m') AS Month,
    SUM(Sales) AS Total_Sales
FROM superstore
where year(connverted_date)=2015
GROUP BY date_format(connverted_date, '%y-%m')
ORDER BY Month;


-- (Q20)Get total profit per state, but only include states where profit > 5000.
select State,sum(Profit) as Total_profit_bystate
from superstore
where Profit>5000
group by State;


-- splitting the Table  for joins questions
CREATE TABLE orders (
    OrderID VARCHAR(50) PRIMARY KEY,
    OrderDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(50),
    CustomerName VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    Region VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    PostalCode int
);

INSERT INTO Orders (OrderID, OrderDate, ShipMode, CustomerID, CustomerName, Segment, Country, Region, State, City, PostalCode)
SELECT DISTINCT 
    `Order ID`,
    `connverted_date`,
    `Ship Mode`,
    `Customer ID`,
    `Customer Name`,
    Segment,
    Country,
    Region,
    State,
    City,
    `Postal Code`
FROM superstore;

select* from orders


CREATE TABLE products (
    ProductDetailID INT AUTO_INCREMENT PRIMARY KEY,  -- unique row identifier
    ProductID VARCHAR(50),
    OrderID VARCHAR(50),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(255),
    Sales DECIMAL(14,6),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(14,6),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);
INSERT INTO products (ProductID, OrderID, Category, SubCategory, ProductName, Sales, Quantity, Discount, Profit)
SELECT DISTINCT 
    `Product ID`,
    `Order ID`,
    Category,
    `Sub-Category`,
    `Product Name`,
    Sales,
    Quantity,
    Discount,
    Profit
FROM superstore;

-- (Q21)Create a query to join orders and products based on Order ID.
select * 
from orders o
join products p on o.OrderID = p.OrderID;

-- (Q22) Show each customer with their products ordered..
select 
 o.CustomerName,
 p.ProductName,
 p.Category,
 p.SubCategory
from orders o
join products p on o.OrderID=p.OrderID
order by o.CustomerName;

-- (Q23)find total sales by customer.....
select
 o.CustomerName,
 sum(p.Sales) as total_sales
from orders o 
join products p on o.OrderID = p.OrderID
group by o.CustomerName
order by o.CustomerName

-- (Q24) Find customers who ordered products from more than 2 categories..
select 
  o.CustomerName,
  count(distinct p.Category) as category_count
from orders o
join products p on o.OrderID=p.OrderID
group by o.CustomerName
having count(distinct p.Category) > 2
order by category_count desc;

-- (Q25)Find orders where Sales are above the overall average sales.
Select `Order ID`,Sales
 from superstore
where Sales > (select avg(Sales) from superstore)

-- (Q26)Identify customers whose total profit is greater than the average profit of all customers.
select `Customer Name`,
 sum(Profit)as total_profit 
from superstore
group by `Customer Name`
having sum(profit) > (select avg(Profit) from superstore)


-- (Q27)Find the second highest sales value in the dataset.
select max(Sales) as second_highest_sales from superstore
where Sales < (select max(Sales) from superstore)

-- alternate method,,

select Sales as second_highest_sales from superstore
where Sales < (select max(Sales) from superstore)
order by second_highest_sales desc
limit 2

-- (Q28) Get the list of states that have total sales greater than 20,000.
SELECT 
    State,
    SUM(Sales) AS TotalSales
FROM superstore
GROUP BY State
HAVING SUM(Sales) > 20000
ORDER BY TotalSales DESC;

-- (Q29) Find the Product Name that had the highest quantity sold.
select `Product Name`, MAX(Quantity) as highest_qty_sold
FROM superstore
group by `Product Name`
order by highest_qty_sold desc
limit 1;

-- (Q30) Show all orders that belong to the top 3 customers by total sales.
select `Customer Name`, Sum(Sales) as total_sales
from superstore
group by `Customer Name`
order by total_sales desc
limit 3


-- (Q31)Find the profit margin for each order (Profit / Sales * 100)..
Select `Order ID`,
 `Product ID`,
 Sales,
 Profit,
 ROUND((Profit / Sales) * 100, 2) AS ProfitMarginPercent
FROM superstore;

-- (Q32) Identify loss-making orders where Profit < 0..
SELECT 
    `Order ID`,
    `Product ID`,
    Sales,
    Profit
FROM superstore
WHERE Profit < 0
ORDER BY Profit ASC;

-- (Q33) Find the percentage contribution of each category to total sales..
select 
 Category,
 Round((sum(Sales)/( select sum(Sales) from superstore))*100, 2 )as percentage_contribution
from superstore
group by Category
order by percentage_contribution desc;

-- (Q34)Calculate year-over-year (YoY) sales growth..
Select
   Year(`connverted_date`) as Year,
   Sum(Sales) as Total_sales,
   LAG(sum(Sales)) OVER (order by Year(`connverted_date`)) as previous_year_sales,
   ROUND(((Sum(Sales) - LAG(sum(Sales)) OVER (order by Year(`connverted_date`)))/LAG(sum(Sales)) OVER (order by Year(`connverted_date`))*100),2)AS YOY
from superstore
group by Year(`connverted_date`)
order by Year;
 
 -- (Q35)Identify the most frequently ordered product in each region.
select `Product Name`,Region,count(`Product Name`) as ordered_product
from superstore
group by Region,`Product Name`
order by ordered_product desc;

-- (Q36)Assign a row number to each order sorted by Order Date
Select `Order ID`, `connverted_date`,
ROW_NUMBER() OVER (order by `connverted_date`) as ROW_NUM
from superstore;

-- (Q37) Find the running total of sales for each region
select Region,`connverted_date`,Sales,
sum(Sales) over (partition by Region order by `connverted_date`) as running_total
from superstore
order by Region,`connverted_date`;

-- (Q38)Rank customers based on their total sales
select
  `Customer Name`,
  Sum(Sales) as Total_sales,
  RANK() OVER (ORDER BY sum(Sales) desc) as Row_rank
from superstore
group by `Customer Name`
order by Row_rank;

-- (Q39)For each Category, find the product with the highest sales..
SELECT Category, `Product Name`, TotalSales
FROM (
    SELECT 
        Category,
        `Product Name`,
        SUM(Sales) AS TotalSales,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS rnk
    FROM superstore
    GROUP BY Category, `Product Name`
) AS ranked
WHERE rnk = 1
ORDER BY Category;

-- (Q40)Month-over-Month (MoM) Sales Growth...
SELECT 
    Year,
    Month,
    TotalSales,
    PreviousMonthSales,
    ROUND(
        ((TotalSales - PreviousMonthSales) / PreviousMonthSales) * 100, 2
    ) AS MoM_Growth_Percent
FROM (
    SELECT 
        YEAR(`Order Date`) AS Year,
        MONTH(`Order Date`) AS Month,
        SUM(Sales) AS TotalSales,
        LAG(SUM(Sales)) OVER (ORDER BY YEAR(`Order Date`), MONTH(`Order Date`)) AS PreviousMonthSales
    FROM superstore
    GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
) AS final
ORDER BY Year, Month;

-- (Q41)Calculate Total Sales per Customer (Sales > 10,000)
With Customersales as
  (select `Customer Name`,
  sum(Sales) as total_sales
  from superstore
  group by `Customer Name`)
select * from Customersales
where total_sales > 10000
Order by total_sales desc;

-- (Q42)Categorize Profits Using CASE...
select 
 `Order ID`,
 `Customer ID`,
 Profit, 
 CASE
   when Profit > 100 then 'High'
   when Profit between 0 and 100 then 'Medium'
   When Profit < 0 then 'Loss'
end as Profit_category
from superstore;

-- (Q43)Top 3 Customers per Region Using CTE + RANK

With Rankedcustomers as
(select
  `Customer Name`,
  Region,
  sum(Sales) as total_sales,
  rank() over(partition by Region order by sum(sales))as rnk
  from superstore
  group  by Region,`Customer Name`)
select * from Rankedcustomers
where rnk <=3
order by Region, rnk; 

-- (Q44)Most Profitable Segment...
SELECT 
    Segment,
    SUM(Profit) AS TotalProfit
FROM superstore
GROUP BY Segment
ORDER BY TotalProfit DESC
LIMIT 1;

