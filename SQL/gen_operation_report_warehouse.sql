-- drop SP
drop procedure if exists gen_operation_report;

-- create SP for operation report (warehouse) generation
CREATE PROCEDURE gen_operation_report(IN from_date varchar(8), IN to_date varchar(8))
begin
	-- set date
-- 	set from_date = '20211001';
-- 	set to_date = '20211101';

	CREATE TEMPORARY TABLE operation_report (  
	   region varchar(20),
	   state varchar(20),
	   delivery_lead_time DECIMAL(4,2),
	   return_rate DECIMAL(2,2),
	   sales_qty_tec DECIMAL(4,2),
	   sales_qty_os DECIMAL(4,2),
	   sales_qty_furn DECIMAL(4,2),
	   avg_qty_shipped DECIMAL(4,2),
	   no_of_order int,
	   sales_qty int,
	   num int -- for ordering
	);
	
	-- by state
   	insert into operation_report (region, state, delivery_lead_time, return_rate, no_of_order, sales_qty, sales_qty_tec, sales_qty_os, sales_qty_furn, avg_qty_shipped, num)
   	select region, state, avg(lead_day), (count(returned)/count(order_id)), count(order_id), sum(qty), 0, 0, 0, 0, 1
	from
	(
	select o.order_id, datediff(s.ship_date, o.order_date) as lead_day, a.region, a.state, r.returned, sum(quantity) as qty
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		left join returns r on o.order_id = r.order_id 
		where order_date >= from_date
		and order_date < to_date
		group by (o.order_id)
	) as tmp
	group by (state)
	order by (region);
	
	-- insert sales quantity data by state
	update operation_report as report
	inner join (
			select state,
				SUM(CASE WHEN p.category ='Technology' THEN o.sales ELSE 0 END) / sum(o.sales) AS tec, 
				SUM(CASE WHEN p.category ='Office Supplies' THEN o.sales ELSE 0 END) / sum(o.sales) AS os, 
				SUM(CASE WHEN p.category ='Furniture' THEN o.sales ELSE 0 END) / sum(o.sales) AS furn,
				o.product_id
				from orders o
				join products p on o.product_id = p.product_id 
				join addresses a on o.address_id = a.address_id
				where order_date >= from_date
				and order_date < to_date
				group by (state)
	) as qty_sum on qty_sum.state = report.state
	set report.sales_qty_tec = qty_sum.tec,
		report.sales_qty_os = qty_sum.os,
		report.sales_qty_furn = qty_sum.furn;

	-- insert avg shipped qty by state
	update operation_report as report
	inner join (
		select o.order_id, a.region, a.state, sum(quantity) as qty, sum(quantity) / (SELECT DAYOFMONTH(LAST_DAY(from_date))) as avg_shipped
			from orders o
			join shipments s on o.order_id = s.order_id 
			join addresses a on o.address_id = a.address_id
			where s.ship_date >= from_date
			and s.ship_date < to_date
			group by (state)
	) as ship_result on ship_result.state = report.state
	set report.avg_qty_shipped = ship_result.avg_shipped;
	
	-- by region
   	insert into operation_report (region, state, delivery_lead_time, return_rate, no_of_order, sales_qty, sales_qty_tec, sales_qty_os, sales_qty_furn, avg_qty_shipped, num)
   	select region, region, avg(lead_day), (count(returned)/count(order_id)), count(order_id), sum(qty), 0, 0, 0, 0, 2
	from
	(
	select o.order_id, datediff(s.ship_date, o.order_date) as lead_day, a.region, a.state, r.returned, sum(quantity) as qty
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		left join returns r on o.order_id = r.order_id 
		where order_date >= from_date
		and order_date < to_date
		group by (o.order_id)
	) as tmp
	group by (region)
	order by (region);
	
	-- insert sales data by region
	update operation_report as report
	inner join (
			select region,
				SUM(CASE WHEN p.category ='Technology' THEN o.sales ELSE 0 END) / sum(o.sales) AS tec, 
				SUM(CASE WHEN p.category ='Office Supplies' THEN o.sales ELSE 0 END) / sum(o.sales) AS os, 
				SUM(CASE WHEN p.category ='Furniture' THEN o.sales ELSE 0 END) / sum(o.sales) AS furn,
				o.product_id
				from orders o
				join products p on o.product_id = p.product_id 
				join addresses a on o.address_id = a.address_id
				where order_date >= from_date
				and order_date < to_date
				group by (region)
	) as qty_sum on qty_sum.region = report.state -- for region avg, region is stored in state field
	set report.sales_qty_tec = qty_sum.tec,
		report.sales_qty_os = qty_sum.os,
		report.sales_qty_furn = qty_sum.furn;

	-- insert avg shipped qty by state
	update operation_report as report
	inner join (
		select o.order_id, a.region, sum(quantity) as qty, sum(quantity) / (SELECT DAYOFMONTH(LAST_DAY(from_date))) as avg_shipped
			from orders o
			join shipments s on o.order_id = s.order_id 
			join addresses a on o.address_id = a.address_id
			where s.ship_date >= from_date
			and s.ship_date < to_date
			group by (region)
	) as ship_result on ship_result.region = report.state
	set report.avg_qty_shipped = ship_result.avg_shipped;
	

	select state, delivery_lead_time, 
	CONCAT(TRIM(return_rate*100)+0, '%'),
	CONCAT(TRIM(sales_qty_tec*100)+0, '%'), 
	CONCAT(TRIM(sales_qty_os*100)+0, '%'), 
	CONCAT(TRIM(sales_qty_furn*100)+0, '%'),
	avg_qty_shipped, no_of_order, sales_qty
	from operation_report
	order by region, num, state;

	drop table operation_report;
end;

--generate report for 3 months
call gen_operation_report('20211001','20211101');
call gen_operation_report('20211101','20211201');
call gen_operation_report('20211201','20220101');

