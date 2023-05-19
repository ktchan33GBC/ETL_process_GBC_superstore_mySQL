-- drop SP
drop procedure if exists gen_operation_sales_report;


-- create SP for operation report (sales) generation
CREATE PROCEDURE gen_operation_sales_report(IN from_date varchar(8), IN to_date varchar(8))
begin
	-- set date
-- 	set from_date = '20211001';
-- 	set to_date = '20211101';

	CREATE TEMPORARY TABLE operation_sales_report (  
	   region varchar(20),
	   category varchar(20),
	   sub_category varchar(20),
	   sales DECIMAL(10,4),
	   quantity int,
	   avg_discount DECIMAL(4,4),
	   total_profit DECIMAL(8,4),
	   avg_profit DECIMAL(8,4),
	   avg_cost DECIMAL(8,4),
	   no_of_return int
	);

	insert into operation_sales_report (region, category, sub_category, 
				sales, quantity, avg_discount, total_profit, avg_profit, avg_cost, no_of_return)
	select regional_managers.region, category, sub_category, 0, 0, 0, 0, 0, 0, 0
	from products, regional_managers
	group by region, sub_category
	order by region, category;

-- update sub_category data
	update operation_sales_report as report
	inner join (
			select a.region, p.sub_category,
					sum(o.sales) as sales, 
					sum(o.quantity) as quantity, 
					sum(o.sales * o.discount)/sum(o.sales) as avg_discount, 
					sum(o.profit) as profit, 
					sum(o.profit)/sum(o.quantity) as avg_profit, 
					(sum(o.sales)-sum(o.profit))/sum(o.quantity) as avg_cost,
					count(r.returned) as no_of_return
				from orders o
				join products p on o.product_id = p.product_id 
				join addresses a on o.address_id = a.address_id
				left join returns r on o.order_id = r.order_id 
				where order_date >= from_date
				and order_date < to_date
				group by region, sub_category
	) as cat_sum on cat_sum.sub_category = report.sub_category and
					cat_sum.region = report.region
	set report.sales = cat_sum.sales,
		report.quantity = cat_sum.quantity,
		report.avg_discount = cat_sum.avg_discount,
		report.total_profit = cat_sum.profit,
		report.avg_profit = cat_sum.avg_profit,
		report.avg_cost = cat_sum.avg_cost,
		report.no_of_return = cat_sum.no_of_return;
	
	-- insert sub total by category
	insert into operation_sales_report (region, category, sub_category,
			sales, quantity, avg_discount, total_profit, avg_profit, avg_cost, no_of_return)
	select a.region, p.category, 'Xtotal',
		sum(o.sales) as sales, 
		sum(o.quantity) as quantity, 
		sum(o.sales * o.discount)/sum(o.sales) as avg_discount,
		sum(o.profit) as profit, 
		sum(o.profit)/sum(o.quantity) as avg_profit, 
		(sum(o.sales)-sum(o.profit))/sum(o.quantity) as avg_cost,
		count(r.returned) as no_of_return
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	left join returns r on o.order_id = r.order_id 
	where order_date >= from_date
	and order_date < to_date
	group by region, category;
	
	-- insert sub total by region
	insert into operation_sales_report (region, category, sub_category,
		sales, quantity, avg_discount, total_profit, avg_profit, avg_cost, no_of_return)
	select a.region, 'Xtotal', null,
		sum(o.sales) as sales, 
		sum(o.quantity) as quantity, 
		sum(o.sales * o.discount)/sum(o.sales) as avg_discount,
		sum(o.profit) as profit, 
		sum(o.profit)/sum(o.quantity) as avg_profit, 
		(sum(o.sales)-sum(o.profit))/sum(o.quantity) as avg_cost,
		count(r.returned) as no_of_return
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	left join returns r on o.order_id = r.order_id 
	where order_date >= from_date
	and order_date < to_date
	group by region;

	-- insert total
	insert into operation_sales_report (region, category, sub_category,
		sales, quantity, avg_discount, total_profit, avg_profit, avg_cost, no_of_return)
	select 'Xtotal', null, null,
		sum(o.sales) as sales, 
		sum(o.quantity) as quantity, 
		sum(o.sales * o.discount)/sum(o.sales) as avg_discount,
		sum(o.profit) as profit, 
		sum(o.profit)/sum(o.quantity) as avg_profit, 
		(sum(o.sales)-sum(o.profit))/sum(o.quantity) as avg_cost,
		count(r.returned) as no_of_return
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	left join returns r on o.order_id = r.order_id 
	where order_date >= from_date
	and order_date < to_date;


	select * from operation_sales_report
	order by region, category, sub_category;
	
	drop table operation_sales_report;
end;

-- generate report for 3 months
call gen_operation_sales_report('20211001','20211101');
call gen_operation_sales_report('20211101','20211201');
call gen_operation_sales_report('20211201','20220101');