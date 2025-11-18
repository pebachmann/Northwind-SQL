-- Quais clientes do Reino Unido pagaram mais de 1000 dólares?

create view v_UK_clients_paid_over_1000 as
with Expense_by_client as (
select
	c.customer_id as client,
	c.country as country,
	sum((od.unit_price * od.quantity)*(1-od.discount)) as total
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join order_details od
on od.order_id = o.order_id
group by 1,2
)
select
	client,
	total
from Expense_by_client
where 1=1
and lower(country) = 'uk'
and total > 1000