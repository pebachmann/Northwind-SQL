# Relatórios Avançados em SQL Northwind

## Objetivo

Este repositório tem como objetivo apresentar relatórios construídos em SQL. As análises disponibilizadas aqui podem ser aplicadas nas empresas, em áreas como marketing, vendas, financeiro e operações. Através destes relatórios, organizações poderão extrair insights valiosos de seus dados, ajudando na tomada de decisões estratégicas, promovendo uma cultura Data Driven.

## Relatórios que vamos criar

1. **Relatórios de Receita**
    
    * Qual foi o total de receitas no ano de 1997?

    ```sql
    create view v_1997_revenue as
    select 
	    extract(year from o.order_date) as ano,
	    sum((od.unit_price * od.quantity)*(1-od.discount)) as total_price
    from order_details od
    join orders o on od.order_id = o.order_id
    where extract(year from o.order_date) =1997
    group by ano
    ```

    * Faça uma análise de crescimento mensal e o cálculo de YTD

    ```sql
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
	    Revenue - lag(Revenue) over (partition by years order by months) as     monthly_difference,
	    YTD_revenue,
	    (Revenue - lag(Revenue) over (partition by years order by months)) / lag(Revenue) over (partition by years order by months) * 100 as percentual_monthly_variation
    from Accumulated_revenue
    order by years,months
    ```

2. **Segmentação de clientes**
    
    * Qual é o valor total que cada cliente já pagou até agora?

    ```sql
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
    ```

    * Separe os clientes em 5 grupos de acordo com o valor pago por cliente

    ```sql
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
    ```


    * Agora somente os clientes que estão nos grupos 3, 4 e 5 para que seja feita uma análise de Marketing especial com eles

    ```sql
    create view v_marketing_clients as
    with Marketing_segmentation as (
    select 
	    c.company_name,
	    sum((od.quantity*od.unit_price)*(1-od.discount)) as total,
	    ntile(5) over(order by sum((od.quantity*od.unit_price)*(1-od.discount))) as     revenue_group
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
    ```

3. **Top 10 Produtos Mais Vendidos**
    
    * Identificar os 10 produtos mais vendidos.

    ```sql
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
    ```

4. **Clientes do Reino Unido que Pagaram Mais de 1000 Dólares**
    
    * Quais clientes do Reino Unido pagaram mais de 1000 dólares?

    ```sql
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
    ```

## Contexto

O banco de dados `Northwind` contém os dados de vendas de uma empresa  chamada `Northwind Traders`, que importa e exporta alimentos especiais de todo o mundo. 

O banco de dados Northwind é ERP com dados de clientes, pedidos, inventário, compras, fornecedores, remessas, funcionários e contabilidade.

O conjunto de dados Northwind inclui dados de amostra para o seguinte:

* **Fornecedores:** Fornecedores e vendedores da Northwind
* **Clientes:** Clientes que compram produtos da Northwind
* **Funcionários:** Detalhes dos funcionários da Northwind Traders
* **Produtos:** Informações do produto
* **Transportadoras:** Os detalhes dos transportadores que enviam os produtos dos comerciantes para os clientes finais
* **Pedidos e Detalhes do Pedido:** Transações de pedidos de vendas ocorrendo entre os clientes e a empresa

O banco de dados `Northwind` inclui 14 tabelas e os relacionamentos entre as tabelas são mostrados no seguinte diagrama de relacionamento de entidades.

![northwind](https://github.com/pebachmann/Northwind-SQL/blob/main/pics/northwind-er-diagram.png?raw=true)

## Configuração Inicial

### Manualmente

Utilize o arquivo SQL fornecido, `nortwhind.sql`, para popular o seu banco de dados.

### Com Docker e Docker Compose

**Pré-requisito**: Instale o Docker e Docker Compose

* [Começar com Docker](https://www.docker.com/get-started)
* [Instalar Docker Compose](https://docs.docker.com/compose/install/)

### Passos para configuração com Docker:

1. **Iniciar o Docker Compose** Execute o comando abaixo para subir os serviços:
    
    ```
    docker-compose up
    ```
    
    Aguarde as mensagens de configuração, como:
    
    ```csharp
    Creating network "northwind_psql_db" with driver "bridge"
    Creating volume "northwind_psql_db" with default driver
    Creating volume "northwind_psql_pgadmin" with default driver
    Creating pgadmin ... done
    Creating db      ... done
    ```
       
2. **Conectar o PgAdmin** Acesse o PgAdmin pelo URL: [http://localhost:5050](http://localhost:5050), com a senha `postgres`. 

Configure um novo servidor no PgAdmin:
    
    * **Aba General**:
        * Nome: db
    * **Aba Connection**:
        * Nome do host: db
        * Nome de usuário: postgres
        * Senha: postgres Em seguida, selecione o banco de dados "northwind".

3. **Parar o Docker Compose** Pare o servidor iniciado pelo comando `docker-compose up` usando Ctrl-C e remova os contêineres com:
    
    ```
    docker-compose down
    ```
    
4. **Arquivos e Persistência** Suas modificações nos bancos de dados Postgres serão persistidas no volume Docker `postgresql_data` e podem ser recuperadas reiniciando o Docker Compose com `docker-compose up`. Para deletar os dados do banco, execute:
    
    ```
    docker-compose down -v
    ```