-- Materialized view das vendas acumuladas mensais

create materialized view mv_sales_accumulated_monthly as
select
	extract (year from o.order_date) as year,
	extract (month from o.order_date) as month,
	sum (od.unit_price * od.quantity * (1 - od.discount)) as accumulated_sales
from order_details od
join orders o
on o.order_id = od.order_id
group by 1,2
order by 1,2;

-- refresh materialized view function
create or replace function refresh_mv_sales_accumulated_monthly()
returns trigger as $$
begin
	refresh materialized view mv_sales_accumulated_monthly;
	return null;
end;
$$ language plpgsql; 

-- triggers
create trigger trg_refresh_mv_accumulated_monthly_order_details
after insert or update or delete on order_details
for each statement
execute function refresh_mv_sales_accumulated_monthly();

create trigger trg_refresh_mv_sales_accumulated_monthly_orders
after insert or update or delete on orders
for each statement
execute function refresh_mv_sales_accumulated_monthly();

