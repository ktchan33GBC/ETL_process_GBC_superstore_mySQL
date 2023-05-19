-- drop SP
drop procedure if exists gen_exec_report;

-- create SP for executive report generation
CREATE PROCEDURE gen_exec_report()
begin
	declare from_date varchar(8);
	declare to_date varchar(8);

	-- set date
	set from_date = '20200101';
	set to_date = '20210101';

	CREATE TEMPORARY TABLE last_year_data (  
	   region varchar(20),
	   category varchar(20),
	   season_1 DECIMAL(10,4),
	   season_2 DECIMAL(10,4),
	   season_3 DECIMAL(10,4),
	   season_4 DECIMAL(10,4),
	   year_sum DECIMAL(12,4),
	   data_type varchar(10)
	);

	CREATE TEMPORARY TABLE this_year_data (  
	   region varchar(20),
	   category varchar(20),
	   season_1 DECIMAL(10,4),
	   season_2 DECIMAL(10,4),
	   season_3 DECIMAL(10,4),
	   season_4 DECIMAL(10,4),
	   year_sum DECIMAL(12,4),
	   data_type varchar(10)
	);

	CREATE TEMPORARY TABLE final_report (  
	   region varchar(20),
	   category varchar(20),
	   season_1 DECIMAL(10,4),
	   season_1_perc DECIMAL(10,4),
	   season_2 DECIMAL(10,4),
	   season_2_perc DECIMAL(10,4),
	   season_3 DECIMAL(10,4),
	   season_3_perc DECIMAL(10,4),
	   season_4 DECIMAL(10,4),
	   season_4_perc DECIMAL(10,4),
	   year_sum DECIMAL(12,4),
	   year_sum_perc DECIMAL(12,4),
	   data_type varchar(10)
	);
	
	-- collect year 2020's data (sales)
   	insert into last_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, p.category,
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.sales ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.sales ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.sales ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.sales ELSE 0 END) AS season_4,
	sum(o.sales) as year_sum,
	'SALES'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region, category
	order by region, category;
	

	-- collect year 2020's data (shipment)
	insert into last_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
	select region, ship_mode,
	SUM(CASE WHEN quarter(order_date) = 1 THEN 1 ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(order_date) = 2 THEN 1 ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(order_date) = 3 THEN 1 ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(order_date) = 4 THEN 1 ELSE 0 END) AS season_4,
	count(*) as year_sum,
	'SHIPMENT'
	from(
		select o.order_id, o.order_date, a.region, s.ship_mode
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		where order_date >= from_date
		and order_date < to_date
		group by o.order_id
	)as t
	group by region, ship_mode
	order by region, ship_mode;

	-- collect year 2020's data (profit)
   	insert into last_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, p.category,
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.profit ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.profit ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.profit ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.profit ELSE 0 END) AS season_4,
	sum(o.profit) as year_sum,
	'PROFIT'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region, category
	order by region, category;



	-- find this year's data
	set from_date = '20210101';
	set to_date = '20220101';

	-- collect year 2021's data (sales)
   	insert into this_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, p.category,
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.sales ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.sales ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.sales ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.sales ELSE 0 END) AS season_4,
	sum(o.sales) as year_sum,
	'SALES'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region, category
	order by region, category;

	-- collect year 2021's data (shipment)
	insert into this_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
	select region, ship_mode,
	SUM(CASE WHEN quarter(order_date) = 1 THEN 1 ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(order_date) = 2 THEN 1 ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(order_date) = 3 THEN 1 ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(order_date) = 4 THEN 1 ELSE 0 END) AS season_4,
	count(*) as year_sum,
	'SHIPMENT'
	from(
		select o.order_id, o.order_date, a.region, s.ship_mode
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		where order_date >= from_date
		and order_date < to_date
		group by o.order_id
	)as t
	group by region, ship_mode
	order by region, ship_mode;

	-- collect year 2021's data (profit)
   	insert into this_year_data (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, p.category,
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.profit ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.profit ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.profit ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.profit ELSE 0 END) AS season_4,
	sum(o.profit) as year_sum,
	'PROFIT'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region, category
	order by region, category;


	insert into final_report (region, category, season_1, season_1_perc, season_2, season_2_perc,
			season_3, season_3_perc, season_4, season_4_perc, year_sum, year_sum_perc, data_type)
	select t.region, t.category, 
	t.season_1,
	(t.season_1 - l.season_1)/l.season_1 * SIGN(l.season_1), -- multiply the sign to cater percentage change issue due to negative value
	t.season_2,
	(t.season_2 - l.season_2)/l.season_2 * SIGN(l.season_2), 
	t.season_3,
	(t.season_3 - l.season_3)/l.season_3 * SIGN(l.season_3), 
	t.season_4,
	(t.season_4 - l.season_4)/l.season_4 * SIGN(l.season_4), 
	t.year_sum,
	(t.year_sum - l.year_sum)/l.year_sum * SIGN(l.year_sum),
	t.data_type
	from this_year_data t, last_year_data l
	where t.region = l.region
	and t.category = l.category
	and t.data_type = l.data_type;


	-- collect regional summary of year 2021's data (sales)
   	insert into final_report (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, 'Xseasonal',
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.sales ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.sales ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.sales ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.sales ELSE 0 END) AS season_4,
	sum(o.sales) as year_sum,
	'SALES'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region
	order by region;

	-- collect regional summary of year 2021's data (shipment)
	insert into final_report (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
	select region, 'Xseasonal',
	SUM(CASE WHEN quarter(order_date) = 1 THEN 1 ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(order_date) = 2 THEN 1 ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(order_date) = 3 THEN 1 ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(order_date) = 4 THEN 1 ELSE 0 END) AS season_4,
	count(*) as year_sum,
	'SHIPMENT'
	from(
		select o.order_id, o.order_date, a.region, s.ship_mode
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		where order_date >= from_date
		and order_date < to_date
		group by o.order_id
	)as t
	group by region
	order by region;

	-- collect regional summary of year 2021's data (profit)
   	insert into final_report (region, category, season_1, season_2, season_3, season_4, year_sum, data_type)
   	select a.region, 'Xseasonal',
	SUM(CASE WHEN quarter(o.order_date) = 1 THEN o.profit ELSE 0 END) AS season_1, 
	SUM(CASE WHEN quarter(o.order_date) = 2 THEN o.profit ELSE 0 END) AS season_2, 
	SUM(CASE WHEN quarter(o.order_date) = 3 THEN o.profit ELSE 0 END) AS season_3,
	SUM(CASE WHEN quarter(o.order_date) = 4 THEN o.profit ELSE 0 END) AS season_4,
	sum(o.profit) as year_sum,
	'PROFIT'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date
	group by region
	order by region;

	-- collect total summary of year 2021 (sales)
  	insert into final_report (region, year_sum, data_type)
   	select 'XTotalSum',
	SUM(o.sales),
	'SALES'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date;

	-- collect total summary of year 2021 (shipment)
	insert into final_report (region, year_sum, data_type)
	select 'XTotalSum',
	count(*) as year_sum,
	'SHIPMENT'
	from(
		select o.order_id, o.order_date, a.region, s.ship_mode
		from orders o
		join shipments s on o.order_id = s.order_id 
		join addresses a on o.address_id = a.address_id
		where order_date >= from_date
		and order_date < to_date
		group by o.order_id
	)as t;

	-- collect total summary of year 2021 (profit)
  	insert into final_report (region, year_sum, data_type)
   	select 'XTotalSum',
	SUM(o.profit),
	'PROFIT'
	from orders o
	join products p on o.product_id = p.product_id 
	join addresses a on o.address_id = a.address_id
	where order_date >= from_date
	and order_date < to_date;

	select region, category, season_1, CONCAT(TRIM(season_1_perc*100)+0, '%'),
			season_2, CONCAT(TRIM(season_2_perc*100)+0, '%'),
			season_3, CONCAT(TRIM(season_3_perc*100)+0, '%'),
			season_4, CONCAT(TRIM(season_4_perc*100)+0, '%'),
			year_sum, CONCAT(TRIM(year_sum_perc*100)+0, '%'),
			data_type
			from final_report
	order by data_type, region, category;

	drop table last_year_data;
	drop table this_year_data;
	drop table final_report;
end;


-- generate report
call gen_exec_report();