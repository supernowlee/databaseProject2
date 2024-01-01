--琩高
EXPLAIN PLAN FOR 
SELECT
product_category_name, count(1)
FROM
    orders join orderitems on orders.order_id = orderitems.order_id
      join products  on products.product_id = orderitems.product_id
where (product_category_name  like 'c%' or product_category_name  like 'a%' or product_category_name  like 't%')  
and order_delivered_carrier_date > '2017-01-01' and order_delivered_carrier_date > '2018-01-01'
and order_status = 'delivered'
    group by product_category_name;
select * from table(dbms_xplan.display);

CREATE INDEX IDX_order_delivered_carrier_date
ON orders (order_delivered_carrier_date);
CREATE INDEX IDX_product_category_name
ON products (product_category_name);


--琩高
EXPLAIN PLAN FOR 
SELECT
product_category_name, avg(review_score),count(1)
FROM
    orderitems join products  on products.product_id = orderitems.product_id
    join orderreviews on orderitems.order_id = orderreviews.order_id
    join orders on orderitems.order_id = orders.order_id
    join customer on orders.customer_id = customer.customer_id
where order_delivered_carrier_date >= '2018-01-01' and order_delivered_carrier_date <= '2018-03-01'
and orders.customer_id in (
select customer_id from customer
where customer_city in (
'sao paulo'
,'montes claros'
,'salvador'
,'belo horizonte'
,'franca') 
)
 group by product_category_name;
select * from table(dbms_xplan.display);
-- 琩高纔て
EXPLAIN PLAN FOR 
SELECT
product_category_name, avg(review_score),count(1)
FROM
    orderitems join products  on products.product_id = orderitems.product_id
    join orderreviews on orderitems.order_id = orderreviews.order_id
    join orders on orderitems.order_id = orders.order_id
    join customer on orders.customer_id = customer.customer_id
where order_delivered_carrier_date BETWEEN '2018-01-01' and '2018-06-01'
and customer_city in (
'sao paulo'
,'montes claros'
,'salvador'
,'belo horizonte'
,'franca')  
group by product_category_name;
select * from table(dbms_xplan.display);

--琩高 
-- 承Ы羬–坝珇キА蝶だ
CREATE GLOBAL TEMPORARY TABLE avg_ratings_temp1 (
    product_id VARCHAR(100),
    avg_rating NUMBER(3,1)
) ON COMMIT PRESERVE ROWS;
EXPLAIN PLAN FOR 

INSERT INTO avg_ratings_temp1
SELECT product_id, ROUND(AVG(review_score), 1) AS avg_rating
FROM orderitems join orderreviews on orderitems.order_id = orderreviews.order_id
GROUP BY product_id
HAVING COUNT(1) > 10;

SELECT o.review_comment_message
FROM orderreviews o
JOIN orderitems i ON o.order_id = i.order_id
JOIN avg_ratings_temp1 a ON i.product_id = a.product_id
WHERE a.avg_rating = (
    SELECT MIN(avg_rating)
    FROM avg_ratings_temp1
);
select * from table(dbms_xplan.display);

drop table  avg_ratings_temp1;

EXPLAIN PLAN FOR 
SELECT review_comment_message
FROM (
    SELECT oi.product_id, AVG(orv.review_score) AS avg_rating
    FROM orderitems oi
    JOIN orderreviews orv ON oi.order_id = orv.order_id
    GROUP BY oi.product_id
    HAVING COUNT(1) > 10
    ORDER BY avg_rating
    FETCH FIRST 1 ROWS ONLY
)  lowest_rated_product
JOIN orderitems oi ON lowest_rated_product.product_id = oi.product_id
JOIN orderreviews orv ON oi.order_id = orv.order_id;
select * from table(dbms_xplan.display);


