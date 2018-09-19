
Use Sakila;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
select upper(concat(first_name,'  ', last_name)) AS 'Actor Name' FROM actor;
-- 2 
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name='Joe';
-- 2b. Find all actors whose last name contain the letters GEN
select * from actor
where last_name like '%GEN%';
-- 2c.Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor 
where last_name like '%LI%'
order by  last_name, first_name;
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
select country_id , country from country 
where country in ( 'Afghanistan', 'Bangladesh', 'China');
-- 3
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE `sakila`.`actor` 
ADD COLUMN `description` BLOB NULL AFTER `first_name`;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor DROP description;
select * from actor;
-- 4

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name,count(last_name) as 'lastname count' from actor
group by last_name;

-- 4b.4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name,count(last_name) as 'lastname count' from actor
group by last_name
having count(last_name)> 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor 
set first_name='HARPO' 
where first_name= 'GROUCHO' and last_name='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO' and actor_id = 172;
-- 5
SHOW CREATE TABLE address;
 
-- 6 
-- Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select * from staff;
select * from address;

select staff.first_name, staff.last_name , address.address
 from staff inner join address 
 on staff.address_id=address.address_id;
 
 -- Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment
 select * from payment;
 select * from staff;
select staff.first_name, staff.last_name,sum(payment.amount)  as 'Total Amount by Staff' ,payment.payment_date
from staff
inner join payment
on staff.staff_id = payment.staff_id
group by staff.staff_id;

--  How many copies of the film Hunchback Impossible exist in the inventory system

select count(*) as ' Hunchback Impossible number of copy ' from inventory where film_id in 
(	select film_id from film
	where title='Hunchback Impossible '
);
-- Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select customer.first_name, customer.last_name, sum(payment.amount) as 'Total payment'  from payment
 inner join customer on payment.customer_id=customer.customer_id
 group by payment.customer_id 
 order by customer.last_name;
-- 7

-- 7a.The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title,language_id  from film where language_id in 
(	select language_id from language
	where name='English'
)
and title like'k%' or title like 'Q%';

-- 7.b Use subqueries to display all actors who appear in the film Alone Trip

select first_name, last_name from actor where actor_id in 
(select actor_id from film_actor where film_id in 
	(	select film_id from film 
		where title='Alone Trip'
	)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name,last_name, email from customer where address_id in 
(select address_id from address where city_id in 
	(select city_id from city where country_id in 
		(	select country_id from country
			where country='Canada'
		)
	)
); 
-- 7e. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select title, rating, film_id  from film where film_id in 
(select film_id from film_category where category_id in 
	(	select category_id from category
		where name='Family'
	)
);

-- 7e. Display the most frequently rented movies in descending order.
select title, rental_duration from film
order by rental_duration DESC  ;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select staff.store_id, sum(payment.amount) as 'Total per store' from payment inner join staff 
on payment.staff_id=staff.staff_id
group by staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select city.city, country.country,store.store_id 
from city 
join country 
on city.country_id=country.country_id 
join address
on address.city_id=city.city_id
join store 
on store.address_id=address.address_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name as 'Genre', sum(payment.amount) As 'Gross Rev'  
from category 
join film_category 
on category.category_id =film_category.category_id 
join inventory
on inventory.film_id =film_category.film_id
join rental
on rental.inventory_id =inventory.inventory_id
join payment 
on payment.rental_id =rental.rental_id
group by category.name
order by sum(payment.amount) DESC 
limit 5;

-- 8
-- create viwe: 
CREATE VIEW top_five_genres AS
select category.name as 'Genre', sum(payment.amount) As 'Gross Rev'  
from category 
join film_category 
on category.category_id =film_category.category_id 
join inventory
on inventory.film_id =film_category.film_id
join rental
on rental.inventory_id =inventory.inventory_id
join payment 
on payment.rental_id =rental.rental_id
group by category.name
order by sum(payment.amount) DESC 
limit 5;

-- Display view:
SELECT * FROM top_five_genres; 

-- Drop View:
DROP VIEW top_five_genres; 