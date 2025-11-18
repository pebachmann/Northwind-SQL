-- Qual é o valor total que cada cliente já pagou até agora?
-- customer_id, orders, order_id

create view v_total_paid_by_customer as
select 
	c.company_name,
	sum((od.quantity*od.unit_price)*(1-od.discount)) as total
from customers c
inner join orders o
on c.customer_id = o.customer_id
inner join order_details od
on o.order_id = od.order_id
group by c.customer_id
order by total desc