/* CHECK FOR NULL VALUES IN EACH TABLE*/
select 
  countif(order_id is Null) as missing_order,
  countif(customer_id is Null) as missing_customer_id ,
  countif(order_date is Null) as missing_order_date,
  countif(order_amount is Null) as missing_order_amount ,
  countif(shipping_address is Null) as missing_address,
  countif(order_status is Null) as missing_status,
from `customer_orders.customer_orders` ;

select countif(payment_id is Null) as missing_payment,
  countif(order_id is Null) as missing_order,
  countif(payment_date is Null) as missing_payment_date ,
  countif(payment_amount is Null) as missing_payment_amount,
  countif(payment_method is Null) as missing_payment_method ,
  countif(payment_id is Null) as missing_payment_id
from `alt-mobility-task.customer_orders.payments` ;

-- CREATING A VIEW TABLE WHERE YEAR AND MONTHS ARE SEPARATED
-- For the Order table
create or replace view `alt-mobility-task.customer_orders.orders_with_date_parts` as
select
  *,
  extract(year from order_date) as year,
  format_date('%b', order_date) as month
from `alt-mobility-task.customer_orders.customer_orders`;

-- For the payment table
create or replace view `alt-mobility-task.customer_orders.payments_with_date_parts` as
select
  *,
  extract(year from payment_date) as year,
  format_date('%b', payment_date) as month
from `alt-mobility-task.customer_orders.payments`;


-- Order and Sales Analysis
-- Total orders and revenue by order status
select 
  order_status,
  count(order_id) as total_orders,
  sum(order_amount) as total_revenue
from `alt-mobility-task.customer_orders.customer_orders`
group by order_status;

-- MONTHLY RANKING BASED ON TOTAL REVENUE GENERATION
with rank_by_rev as(
  select dense_rank() over (partition by year order by total_revenue desc) rank_,*
from (
  select
    year, month, 
    count(order_id) total_orders, round(sum(order_amount),2) total_revenue
  from `alt-mobility-task.customer_orders.orders_with_date_parts`
  group by year, month
  ) as tot_rev

)
select * from rank_by_rev 
where rank_ <=3
order by year;

/* CUSTOMER SEGMENTATION */
--QUANTILE TABLE CREATION
select * from `customer_orders.customer_orders` limit 10;
select * from `alt-mobility-task.customer_orders.payments` limit 10;
select count(*) from `customer_orders.customer_orders`;
select count(*) from `alt-mobility-task.customer_orders.payments`;

/* QUANTILE TABLE CREATION FOR CUSTOMER SEGMENTATION BASED ON RFM */
CREATE TABLE `alt-mobility-task.customer_orders.quantile` AS
WITH last_first_order AS (
  SELECT customer_id, 
         MAX(order_date) AS last_order_date, 
         MIN(order_date) AS first_order_date, 
         SUM(order_amount) AS monetary, 
         COUNT(order_id) AS num_order
  FROM `customer_orders.customer_orders`
  GROUP BY customer_id
),
/* To calculate the reference date: The last order date in the entire dataset */
cal_ref_date AS (
  SELECT *, 
         MAX(last_order_date) OVER() + 1 AS ref_date, 
         DATE_DIFF(last_order_date, first_order_date, MONTH) + 1 AS life_span
  FROM last_first_order
),
rfm AS (
  SELECT *, 
         DATE_DIFF(ref_date, last_order_date, DAY) AS recency, 
         num_order / (life_span) AS frequency
  FROM cal_ref_date
)
SELECT a.*, 
       -- Percentiles for Monetary
       b.percentile[OFFSET(20)] AS m20,
       b.percentile[OFFSET(40)] AS m40,
       b.percentile[OFFSET(60)] AS m60,
       b.percentile[OFFSET(80)] AS m80,
       b.percentile[OFFSET(100)] AS m100,
       -- Percentiles for Frequency
       c.percentile[OFFSET(20)] AS f20,
       c.percentile[OFFSET(40)] AS f40,
       c.percentile[OFFSET(60)] AS f60,
       c.percentile[OFFSET(80)] AS f80,
       c.percentile[OFFSET(100)] AS f100,
       -- Percentiles for Recency
       d.percentile[OFFSET(20)] AS r20,
       d.percentile[OFFSET(40)] AS r40,
       d.percentile[OFFSET(60)] AS r60,
       d.percentile[OFFSET(80)] AS r80,
       d.percentile[OFFSET(100)] AS r100
FROM rfm a,
     (SELECT APPROX_QUANTILES(monetary, 100) AS percentile FROM rfm) b,
     (SELECT APPROX_QUANTILES(frequency, 100) AS percentile FROM rfm) c,
     (SELECT APPROX_QUANTILES(recency, 100) AS percentile FROM rfm) d;
--CUSTOMER SEGMENTATION BASED ON RFM
SELECT * FROM `alt-mobility-task.customer_orders.quantile` LIMIT 10;
with score as (
  select customer_id, m_score, f_score, r_score,
 recency, frequency, monetary,
 cast(round((f_score+m_score)/2, 0) as INT64) fm_score
from (
  select *,
    case when monetary <=m20 then 1
         when monetary <= m40 and monetary >m20 then 2
         when monetary <= m60 and monetary >m40 then 3
         when monetary <= m80 and monetary >m60 then 4
         when monetary <= m100 and monetary >m80 then 5
    end as m_score, 
    case when frequency <=f20 then 1
         when frequency <= f40 and frequency >f20 then 2
         when frequency <= f60 and frequency >f40 then 3
         when frequency <= f80 and frequency >f60 then 4
         when frequency <= f100 and frequency >f80 then 5
    end as f_score, 
    case when recency <=r20 then 5          /* RECENCY SCORED IN REVERSE WAY*/
         when recency <= r40 and recency >r20 then 4
         when recency <= r60 and recency >r40 then 3
         when recency <= r80 and recency >r60 then 2
         when recency <= r100 and recency >r80 then 1
    end as r_score, 
    
  from `alt-mobility-task.customer_orders.quantile`)
)
select customer_id, recency, frequency, monetary, r_score, f_score, m_score, fm_score,
  case when (r_score = 5 and fm_score = 5) 
            or (r_score = 5 and fm_score = 4) 
            or (r_score = 4 and fm_score = 5)
       then 'Champions'
       when (r_score = 5 and fm_score = 3) 
            or (r_score = 4 and fm_score = 4) 
            or (r_score = 3 and fm_score = 5) 
            or (r_score = 3 and fm_score = 4)
       then 'Loyal Customers'
       when (r_score = 5 and fm_score = 2) 
            or (r_score = 4 and fm_score = 2) 
            or (r_score = 3 and fm_score = 3) 
            or (r_score = 4 and fm_score = 3)
       then 'Potential Loyalists'
       when (r_score = 5 and fm_score = 1) 
       then 'Recent Customers'
       when (r_score = 4 and fm_score = 1) 
            or (r_score = 3 and fm_score = 1)
       then 'Promising'
       when (r_score = 3 and fm_score = 2) 
            or (r_score = 2 and fm_score = 3) 
            or (r_score = 2 and fm_score = 2)
       then 'Customers Needing Attention'
       when (r_score = 2 and fm_score = 1) 
       then 'About to Sleep'
       when (r_score = 2 and fm_score = 5) 
            or (r_score = 2 and fm_score = 4) 
            or (r_score = 1 and fm_score = 3)
       then 'At Risk'
       when (r_score = 1 and fm_score = 5) 
            or (r_score = 1 and fm_score = 4)
       then 'Cant Lose Them'
       when (r_score = 1 and fm_score = 2)
       then 'Hibernating'
       when (r_score = 1 and fm_score = 1)
       then 'Lost'
       end as rfm_segment
from score
order by customer_id

-- payment status analysis

-- payment status count
select 
  payment_status,
  count(payment_id) as total_payments,
  sum(payment_amount) as total_amount
from `alt-mobility-task.customer_orders.payments`
group by payment_status;

-- monthly payment trend
select 
  year,month, 
  payment_status,
  count(payment_id) as total_transactions,
  sum(payment_amount) as total_amount
from `alt-mobility-task.customer_orders.payments_with_date_parts`  /* From View Table */
group by year,month, payment_status
order by year, month;

select month, count(payment_id) total_number_of_payments
from `alt-mobility-task.customer_orders.payments_with_date_parts`
group by month
order by 2 desc;

--Payment status dynamics over month
with payment_dynamics as (
  select 
    year, month,
    countif(payment_status = 'completed') as successful_payments,
    countif(payment_status = 'failed') as failed_payments,
    round(
      countif(payment_status = 'completed') / count(payment_id), 2
    ) as success_rate
  from `alt-mobility-task.customer_orders.payments_with_date_parts`
  group by year, month
),

ranked_success as (
  select *,
    dense_rank() over (partition by year order by success_rate desc) as success_rank
    -- dense_rank() over (partition by year order by failed_payments desc) as failure_rank /* check whether there's gateway problem in any a specific month*/
  from payment_dynamics
)

select *
from ranked_success
where success_rank <= 3
--where failure_rank <=3
order by year, success_rank;
--order by year, failure_rank;

-- full order and payment details report
with full_table as (select 
  co.order_id,
  co.customer_id,
  co.order_date,
  co.order_amount,
  co.order_status,
  p.payment_id,
  p.payment_status,
  p.payment_amount,
  p.payment_method,
  p.payment_date
from `alt-mobility-task.customer_orders.customer_orders` co
left join `alt-mobility-task.customer_orders.payments` p
  on co.order_id = p.order_id)
/*select *
from full_table
order by order_id;*/

-- Distribution of Missing Payments Records Across Order Statuses
select order_status,
  countif(payment_id is null) missing_payment, count(order_id) total_order,  
  concat(round(countif(payment_id is null)*100/count(order_id),2),'%') percentage_of_missing_payment
from full_table
group by order_status


-- aggregated customer-level order and payment summary

select 
  customer_id,
  count(distinct order_id) as total_orders,
  sum(order_amount) as total_order_value,
  count(distinct payment_id) as total_payments,
  sum(payment_amount) as total_paid_amount,
  countif(payment_status = 'completed') as successful_payments,
  countif(payment_status = 'pending') as pending_payments,
  countif(payment_status = 'failed' or payment_status is null) as failed_or_missing_payments,
  round(
    countif(payment_status = 'completed') / nullif(count(distinct payment_id), 0),
    2
  ) as payment_success_rate,
  -- payment failure or missing payment_id
  round(
    countif(payment_status = 'failed' or payment_status is null) / count(distinct order_id),
    2
  ) as payment_miss_fail_rate
from full_table
group by customer_id
order by total_orders desc;
