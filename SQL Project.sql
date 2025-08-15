-- Sold Quantity
-- Gross Price Per Item
-- Gross Price Total


SELECT s.date, s.product_code,
		p.product,p.variant,s.sold_quantity,
        g.gross_price,
        ROUND(g.gross_price*s.sold_quantity,2) as "Gross_Price Total"
FROM fact_sales_monthly s
JOIN dim_product p
ON p.product_code=s.product_code
JOIN fact_gross_price g
ON g.product_code=s.product_code AND g.fiscal_year=get_fiscal_year(s.date)
where 
	customer_code=90002002 AND
    get_fiscal_year(date)=2021 AND
    get_fiscal_quarter(date)="Q4"
order by date asc



-- As a product owner, I need an aggeregate monthly gross sale report for Croma India customer so that I can 
-- Track how much sales this particular customer is genereting for AtliQ and manage our relationship accordingly

-- The report should have the following fields
-- 1. Months
-- 2. Total gross sales amount to Croma in this month

SELECT s.date,g.gross_price,
	SUM(g.gross_price*s.sold_quantity) as Gross_Sale_Total
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
ON 
	s.product_code=g.product_code AND
	g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
GROUP BY s.date
ORDER BY s.date ASC

-- 1) Generate a yearly report for Croma India where there are two columns

-- 	1. Fiscal Year
-- 	2. Total Gross Sales amount In that year from Croma

SELECT 
	get_fiscal_year(date) as Fiscal_year,
    SUM(ROUND(gross_price*sold_quantity,2)) as Yearly_sales
	FROM fact_sales_monthly s
	JOIN fact_gross_price g
ON 
	g.product_code=s.product_code AND 
    g.fiscal_year=get_fiscal_year(s.date)
WHERE customer_code=90002002
GROUP BY get_fiscal_year(date)
ORDER BY fiscal_year


-- Create a store procedure that can determine the market badge based on the fillowing logic,

-- If Total sold quantity >5 million that market is considered Gold else it is Silver

-- My Input will be 
-- 	Market
-- 	Fiscal Year
-- Output
-- 	Market Budget

SELECT 
	c.market,
	SUM(sold_quantity) as total_qty
	FROM fact_sales_monthly s
	JOIN dim_customer c
ON s.customer_code=c.customer_code
WHERE get_fiscal_year(s.date)=2021 and c.market="India"
GROUP BY c.market



### Module: Problem Statement and Pre-Invoice Discount Report

-- Include pre-invoice deductions in Croma detailed report
 
	select 
		*,
    (gross_price_total - gross_price_total*pre_invoice_discount_pct) as net_invoice_sales 
    from sales_preinv_discount
--
-- pre-invoice deductions Net Sales
	select 
		*,
   (1 pre_invoice_discount_pct)*gross_price_total as net_invoice_sales 
    from sales_preinv_discount s
    join fact_post_invoice_deduction po
    on s.date=po.date and
    s.product_code=po.product_code and
    s.customer_code=po.customer_code AND
    
   ### Module: Performance Improvement # 1

-- creating dim_date and joining with this table and avoid using the function 'get_fiscal_year()' to reduce the amount of time taking to run the query
	SELECT 
    	    s.date, 
            s.customer_code,
            s.product_code, 
            p.product, p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_date dt
        	ON dt.calendar_date = s.date
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=dt.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=dt.fiscal_year
	WHERE 
    		dt.fiscal_year=2021     
	LIMIT 1500000;






### Module: Performance Improvement # 2

-- Added the fiscal year in the fact_sales_monthly table itself
	SELECT 
    	    s.date, 
            s.customer_code,
            s.product_code, 
            p.product, p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=s.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=s.fiscal_year
	WHERE 
    		s.fiscal_year=2021     
	LIMIT 1500000;

   
   
-- Module: Database Views: Introduction

-- Get the net_invoice_sales amount using the CTE's
	WITH cte1 AS (
		SELECT 
    		    s.date, 
    		    s.customer_code,
    		    s.product_code, 
                    p.product, p.variant, 
                    s.sold_quantity, 
                    g.gross_price as gross_price_per_item,
                    ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
                    pre.pre_invoice_discount_pct
		FROM fact_sales_monthly s
		JOIN dim_product p
        		ON s.product_code=p.product_code
		JOIN fact_gross_price g
    			ON g.fiscal_year=s.fiscal_year
    			AND g.product_code=s.product_code
		JOIN fact_pre_invoice_deductions as pre
        		ON pre.customer_code = s.customer_code AND
    			pre.fiscal_year=s.fiscal_year
		WHERE 
    			s.fiscal_year=2021) 
	SELECT 
      	    *, 
    	    (gross_price_total-pre_invoice_discount_pct*gross_price_total) as net_invoice_sales
	FROM cte1
	LIMIT 1500000;
    
    -- Creating the view `sales_preinv_discount` and store all the data in like a virtual table
	CREATE  VIEW `sales_preinv_discount` AS
	SELECT 
    	    s.date, 
            s.fiscal_year,
            s.customer_code,
            c.market,
            s.product_code, 
            p.product, 
            p.variant, 
            s.sold_quantity, 
            g.gross_price as gross_price_per_item,
            ROUND(s.sold_quantity*g.gross_price,2) as gross_price_total,
            pre.pre_invoice_discount_pct
	FROM fact_sales_monthly s
	JOIN dim_customer c 
		ON s.customer_code = c.customer_code
	JOIN dim_product p
        	ON s.product_code=p.product_code
	JOIN fact_gross_price g
    		ON g.fiscal_year=s.fiscal_year
    		AND g.product_code=s.product_code
	JOIN fact_pre_invoice_deductions as pre
        	ON pre.customer_code = s.customer_code AND
    		pre.fiscal_year=s.fiscal_year
    
-- Now generate net_invoice_sales using the above created view "sales_preinv_discount"
	SELECT 
            *,
    	    (gross_price_total-pre_invoice_discount_pct*gross_price_total) as net_invoice_sales
	FROM gdb0041.sales_preinv_discount


    
CREATE OR REPLACE VIEW `sales_postinv_discount` AS
SELECT 
    s.date AS sale_date, 
    s.fiscal_year,
    s.customer_code, 
    s.market,
    s.product_code, 
    s.product, 
    s.variant,
    s.sold_quantity, 
    s.gross_price_total,
    s.pre_invoice_discount_pct,
    (s.gross_price_total - s.pre_invoice_discount_pct * s.gross_price_total) AS net_invoice_sales,
    (po.discounts_pct + po.other_deductions_pct) AS post_invoice_discount_pct
FROM sales_preinv_discount AS s
JOIN fact_post_invoice_deductions AS po
    ON po.customer_code = s.customer_code 
    AND po.product_code = s.product_code 
    AND po.date = s.date;
    
    -- Create a report for net sales
	SELECT 
            *, 
    	    net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
	FROM gdb0041.sales_postinv_discount;

-- Finally creating the view `net_sales` which inbuiltly use/include all the previous created view and gives the final result
	CREATE VIEW `net_sales` AS
	SELECT 
            *, 
    	    net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
	FROM gdb0041.sales_postinv_discount;

### Module: Top Markets and Customers 

-- Get top 5 market by net sales in fiscal year 2021
	SELECT 
    	    market, 
            round(sum(net_sales)/1000000,2) as net_sales_mln
	FROM gdb0041.net_sales
	where fiscal_year=2021
	group by market
	order by net_sales_mln desc
	limit 5

-- Stored proc to get top n markets by net sales for a given year
	CREATE PROCEDURE `get_top_n_markets_by_net_sales`(
        	in_fiscal_year INT,
    		in_top_n INT
	)
	BEGIN
        	SELECT 
                     market, 
                     round(sum(net_sales)/1000000,2) as net_sales_mln
        	FROM net_sales
        	where fiscal_year=in_fiscal_year
        	group by market
        	order by net_sales_mln desc
        	limit in_top_n;
	END

-- stored procedure that takes market, fiscal_year and top n as an input and returns top n customers by net sales in that given fiscal year and market
	CREATE PROCEDURE `get_top_n_customers_by_net_sales`(
        	in_market VARCHAR(45),
        	in_fiscal_year INT,
    		in_top_n INT
	)
	BEGIN
        	select 
                     customer, 
                     round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                on s.customer_code=c.customer_code
        	where 
		    s.fiscal_year=in_fiscal_year 
		    and s.market=in_market
        	group by customer
        	order by net_sales_mln desc
        	limit in_top_n;
	END




   
### Module: Window Functions: OVER Clause

-- show % of total expense
	select 
             *,
    	     amount*100/sum(amount) over() as pct
	from random_tables.expenses 
	order by category;

-- show % of total expense per category
	select 
            *,
    	    amount*100/sum(amount) over(partition by category) as pct
	from random_tables.expenses 
	order by category,  pct desc;

-- Show expenses per category till date
	select 
             *,
             sum(amount) over(partition by category order by date) as expenses_till_date
	from random_tables.expenses;







### Module: Window Functions: Using it In a Task

-- find out customer wise net sales percentage contribution 
	with cte1 as (
		select 
                    customer, 
                    round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                    on s.customer_code=c.customer_code
        	where s.fiscal_year=2021
        	group by customer)
	select 
            *,
            net_sales_mln*100/sum(net_sales_mln) over() as pct_net_sales
	from cte1
	order by net_sales_mln desc





### Module: Exercise: Window Functions: OVER Clause

-- Find customer wise net sales distibution per region for FY 2021
	with cte1 as (
		select 
        	    c.customer,
                    c.region,
                    round(sum(net_sales)/1000000,2) as net_sales_mln
                from gdb0041.net_sales n
                join dim_customer c
                    on n.customer_code=c.customer_code
		where fiscal_year=2021
		group by c.customer, c.region)
	select
             *,
             net_sales_mln*100/sum(net_sales_mln) over (partition by region) as pct_share_region
	from cte1
	order by region, pct_share_region desc




### Module: Window Functions: ROW_NUMBER, RANK, DENSE_RANK

-- Show top 2 expenses in each category
	select * from 
	     (select 
                  *, 
    	          row_number() over (partition by category order by amount desc) as row_num
	      from random_tables.expenses) x
	where x.row_num<3

--  If two items have same expense then row_number doesnt work. We need a true rank for which we need to use either a rank or dense_rank() function.(demo using student_marks table)
	select 
	     *,
             row_number() over (order by marks desc) as row_num,
             rank() over (order by marks desc) as rank_num,
             dense_rank() over (order by marks desc) as dense_rank_num
	from random_tables.student_marks;

-- Find out top 3 products from each division by total quantity sold in a given year
	with cte1 as 
		(select
                     p.division,
                     p.product,
                     sum(sold_quantity) as total_qty
                from fact_sales_monthly s
                join dim_product p
                      on p.product_code=s.product_code
                where fiscal_year=2021
                group by p.product),
           cte2 as 
	        (select 
                     *,
                     dense_rank() over (partition by division order by total_qty desc) as drnk
                from cte1)
	select * from cte2 where drnk<=3

-- Creating stored procedure for the above query
	CREATE PROCEDURE `get_top_n_products_per_division_by_qty_sold`(
        	in_fiscal_year INT,
    		in_top_n INT
	)
	BEGIN
	     with cte1 as (
		   select
                       p.division,
                       p.product,
                       sum(sold_quantity) as total_qty
                   from fact_sales_monthly s
                   join dim_product p
                       on p.product_code=s.product_code
                   where fiscal_year=in_fiscal_year
                   group by p.product),            
             cte2 as (
		   select 
                        *,
                        dense_rank() over (partition by division order by total_qty desc) as drnk
                   from cte1)
	     select * from cte2 where drnk <= in_top_n;
	END










    
    