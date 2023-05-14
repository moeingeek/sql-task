create or replace function create_tables()
returns int
language plpgsql
as 
$$
begin
	create table sale(
		id serial not NULL unique primary key,
		order_id integer,
		customer varchar(4),
		product varchar(4),
		date integer check(date > 0),
		quantity integer check(quantity > 0),
		unit_price integer check(unit_price > 0)
	);
	create table sale_profit(
		id serial not NULL unique primary key,
		product varchar(4),
		profit_ratio integer check(profit_ratio >= 0 and profit_ratio <= 100)
	);
	create table chart(
		id serial not NULL unique primary key,
		name varchar(120),
		manager varchar(120) NULL,
		manager_id integer NULL references chart(id)
	);

return 1;
end;
$$

select create_tables();


-- insert data in tables (or import from file)

-- q1. total_sale
select sum(quantity*unit_price) as total_sale from sale;

-- q2. unique customers
select count(distinct customer) as unique_customers from sale;

-- q3. sale per product
select product, sum(quantity*unit_price) as total_price
	from sale 
	group by product;
	
-- q4. 
select order_id, customer, sum(quantity*unit_price) as order_price
	from sale
	group by order_id, customer
	having sum(quantity*unit_price) > 1500
	order by order_id;
	
-- q5.
select sum(x.avg::decimal*product_price::decimal/100) as total_profit, 
		(sum(x.avg::decimal*product_price::decimal/100) / sum(x.product_price))*100 as total_ratio
from (select sale.product, sum(sale.quantity*sale.unit_price) as product_price, avg(sale_profit.profit_ratio) 
	from sale 
	inner join sale_profit on sale.product=sale_profit.product
	group by sale.product
	order by sale.product) x;
	
	
-- q6.
select count(x) as total_customer
 from (select customer, date from sale group by customer, date) x;
