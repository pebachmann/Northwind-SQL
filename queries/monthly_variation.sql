--Faça uma análise de crescimento mensal e o cálculo de YTD

create view v_monthly_variation as
with monthly_revenue as (
select 
	extract (year from o.order_date) as years,
	extract (month from o.order_date) as months,
	sum((od.unit_price * od.quantity) * (1 - od.discount)) as Revenue
from order_details od
join orders o
on od.order_id = o.order_id
group by 1,2
),
Accumulated_revenue as (
select
	years,
	months,
	Revenue,
	sum(Revenue) over (partition by years order by months) as YTD_revenue
from monthly_revenue
)
select
	years,
	months,
	Revenue,
	Revenue - lag(Revenue) over (partition by years order by months) as monthly_difference,
	YTD_revenue,
	(Revenue - lag(Revenue) over (partition by years order by months)) / lag(Revenue) over (partition by years order by months) * 100 as percentual_monthly_variation
from Accumulated_revenue
order by years,months

