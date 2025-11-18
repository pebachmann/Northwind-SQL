-- Agora somente os clientes que estão nos grupos 3, 4 e 5 
--  para que seja feita uma análise de Marketing especial com eles.

create view v_marketing_clients as
with Marketing_segmentation as (
select 
	c.company_name,
	sum((od.quantity*od.unit_price)*(1-od.discount)) as total,
	ntile(5) over(order by sum((od.quantity*od.unit_price)*(1-od.discount))) as revenue_group
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join order_details od
on o.order_id = od.order_id
group by c.customer_id
order by total desc
)
select
	*
from Marketing_segmentation
where revenue_group >=3