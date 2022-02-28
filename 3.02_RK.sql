USE sakila;

-- 1- How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT * FROM sakila.film f
WHERE title = 'Hunchback Impossible';

SELECT title, i.inventory_id FROM sakila.film f
JOIN sakila.inventory i
ON f.film_id = i.film_id
Having title = 'Hunchback Impossible';

-- There are 6 copies available

-- 2. List all films whose length is longer than the average of all the films.

SELECT avg(length) FROM sakila.film;

SELECT title, f.length FROM sakila.film f
WHERE 
f.length > (SELECT avg(length) FROM sakila.film)
ORDER BY f.length DESC;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

Select concat(a.first_name," ",a.last_name) as actor_name FROM sakila.film_actor fa
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE film_id = (Select film_id FROM sakila.film f
WHERE title = 'Alone Trip');

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

Select title, c.name FROM sakila.film f
JOIN sakila.film_category fc
ON f.film_id = fc.film_id
Join sakila.category c
ON fc.category_id = c.category_id
Where fc.category_id = (SELECT category_id FROM sakila.category
WHERE name = "Family");

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

-- subquery

SELECT concat(c.first_name," ", c.last_name) as name FROM customer c
JOIN address a
ON c.address_id = a.address_id
Join city ct
ON a.city_id = ct.city_id
WHERE ct.country_id = (SELECT country_id FROM sakila.country
WHERE country='Canada');


-- joins

SELECT co.country, concat(c.first_name," ", c.last_name) as name FROM customer c
JOIN address a
ON c.address_id = a.address_id
Join city ct
ON a.city_id = ct.city_id
Join country co
ON ct.country_id = co.country_id
HAVING co.country ='Canada';


-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT actor_id, count(distinct film_id) FROM film_actor fa
Group BY actor_id
Order BY count(distinct film_id) DESC
LIMIT 1;


SELECT f.title, actor_id FROM film_actor fa
JOIN film f
ON fa.film_id = f.film_id
WHERE fa.actor_id =
(SELECT fa.actor_id  FROM film_actor fa
Group BY actor_id
Order BY count(distinct film_id) DESC
LIMIT 1);


-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT customer_id, sum(amount) as lifetime_spendings FROM sakila.payment p
GROUP BY p.customer_id
ORDER BY lifetime_spendings DESC;

SELECT title FROM sakila.film f
JOIN sakila.inventory i
ON f.film_id = i.film_id
JOIN sakila.rental r
ON i.inventory_id = r.inventory_id
WHERE r.customer_id = (
SELECT p.customer_id FROM sakila.payment p
GROUP BY p.customer_id
ORDER BY sum(amount) DESC
LIMIT 1);


-- 8. Customers who spent more than the average payments.

-- Spending per Customer
SELECT 
	distinct(customer_id),
	sum(amount) over (partition by customer_id)  as lifetime_spendings
FROM sakila.payment p;

-- Average spending per customer
SELECT 
	sum(amount)/count(distinct(customer_id))
FROM sakila.payment p;

-- Select Customers

SELECT 
	distinct(customer_id),
    sum(amount) over (partition by customer_id)  as lifetime_spendings
FROM sakila.payment
WHERE sum(amount) over (partition by customer_id) > (SELECT	sum(amount)/count(distinct(customer_id)) FROM sakila.payment p);

