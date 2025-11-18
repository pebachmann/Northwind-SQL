-- Qual foi a receita em 1997?
-- calcular o total de receita
-- 


create view v_1997_revenue as
select 
	extract(year from o.order_date) as ano,
	sum((od.unit_price * od.quantity)*(1-od.discount)) as total_price
from order_details od
join orders o on od.order_id = o.order_id
where extract(year from o.order_date) =1997
group by ano