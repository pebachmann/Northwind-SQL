--Top 10 Produtos Mais Vendidos
-- order_details, orders, products

create view v_Top_10_products_sold as
select
	p.product_name,
	sum((od.unit_price * od.quantity)*(1-od.discount)) as total
from orders o
inner join order_details od
on o.order_id = od.order_id
inner join products p
on od.product_id = p.product_id
group by p.product_name
order by total desc
limit 10