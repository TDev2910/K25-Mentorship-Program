-- 1. What is the total amount each customer spent at the restaurant?
-- Tổng số tiền mỗi khách hàng chi tiêu tại nhà hàng là bao nhiêu?
Select 
	customer_id,
    Sum(price) as total_amount
From sales as s 
Inner join menu as m
On s.product_id = m.product_id
Group by 
	customer_id
Order by 
	customer_id;
-- 2. How many days has each customer visited the restaurant?
-- Mỗi khách hàng đã đến nhà hàng bao nhiêu ngày?
Select 
	customer_id,
    Count(Distinct order_date) as days
From sales as s
Group by 
	customer_id
Order by 
	customer_id;
-- 3. What was the first item from the menu purchased by each customer?
-- Món đầu tiên trong thực đơn mà mỗi khách hàng mua là gì?
With CTE as (
	SELECT 
    customer_id,
    order_date,
    product_name,
    RANK() Over (
        PARTITION BY customer_id 
        ORDER BY order_date ASC
    ) AS rnk,
    Row_Number() Over(
      	PARTITION BY customer_id 
        ORDER BY order_date ASC
    ) AS rn 
    FROM sales as s
    INNER JOIN menu as m
    ON s.product_id = m.product_id)
Select 
	customer_id,
    product_name
From CTE
Where rn = 1;
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- Món ăn nào được mua nhiều nhất trong thực đơn và được tất cả khách hàng mua bao nhiêu lần?
Select TOP 1
	product_name,
    Count(order_date) as orders
From Sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
Group by product_name
Order by orders DESC	
-- 5.Which item was the most popular for each customer?
-- Mặt hàng nào được mỗi khách hàng ưa chuộng nhất?
With CTE as (
	Select 
	product_name,
    customer_id,
    Count(order_date) as orders,
    RANK() Over (
        PARTITION BY customer_id 
        ORDER BY Count(order_date) Desc
    ) as rnk,
    Row_Number() Over(
      	PARTITION BY customer_id 
        ORDER BY Count(order_date) DESC
    ) AS rn 
    From Sales as s
    INNER JOIN menu as m
    ON s.product_id = m.product_id
    Group by product_name ,customer_id )
 Select 
 	customer_id,
    product_name
 From CTE
 Where rn = 1;
 -- 6. Which item was purchased first by the customer after they became a member?
-- Khách hàng mua sản phẩm nào đầu tiên sau khi trở thành thành viên?
With CTE AS (
    Select 
        s.customer_id,
        s.order_date,
        m.join_date,
        mn.product_name,
        RANK() Over (
            PARTITION BY s.customer_id 
            ORDER BY order_date
        ) as rnk,
        Row_Number() Over(
            PARTITION BY s.customer_id 
            ORDER BY order_date 
        ) AS rn 
    From Sales as s
    Inner join Members as m
    On m.customer_id = s.customer_id
    Inner join Menu as mn
    On mn.product_id = s.product_id
    Where order_date >= join_date )
 Select 
 	customer_id,
    product_name
 From CTE
 Where rnk = 1;
-- 7. Which item was purchased just before the customer became a member? 
-- Mặt hàng nào được mua ngay trước khi khách hàng trở thành thành viên?
With CTE AS (
    Select 
        s.customer_id,
        s.order_date,
        m.join_date,
        mn.product_name,
        RANK() Over (
            PARTITION BY s.customer_id 
            ORDER BY order_date Desc
        ) as rnk,
        Row_Number() Over(
            PARTITION BY s.customer_id 
            ORDER BY order_date Desc
        ) AS rn 
    From Sales as s
    Inner join Members as m
    On m.customer_id = s.customer_id
    Inner join Menu as mn
    On mn.product_id = s.product_id
    Where order_date < join_date )
 Select 
	customer_id,
    product_name
 From CTE
 Where rnk = 1
-- 8. What is the total items and amount spent for each member before they became a member?
-- Tổng số vật phẩm và số tiền mà mỗi thành viên đã chi tiêu trước khi trở thành thành viên là bao nhiêu?
Select 
     s.customer_id,
     Count(product_name) as total_items,
     Sum(price) as total_pay
From Sales as s
Inner join Members as m
On m.customer_id = s.customer_id
Inner join Menu as mn
On mn.product_id = s.product_id
Where order_date < join_date 
Group by s.customer_id
    Order by s.customer_id ASC;
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- Nếu mỗi $1 chi tiêu tương ứng với 10 điểm và sushi có hệ số nhân điểm là 2x thì mỗi khách hàng sẽ có bao nhiêu điểm?
Select
	customer_id,
Sum(Case
When 
    product_name = 'sushi' then price *10*2
Else
	Price *10
End ) as points
From Menu as m
Inner join Sales as s
On s.product_id = m.product_id
Group by customer_id
Order by customer_id ASC;    