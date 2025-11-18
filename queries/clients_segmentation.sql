-- Separe os clientes em 5 grupos de acordo com o valor pago por cliente

create view v_clients_segmentation as
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