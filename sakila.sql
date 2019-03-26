-- 1a Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name 
FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(first_name, ' ', last_name) 
AS 'Actor Name'
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name='Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor 
ADD description LONGBLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'number of actors'
FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'number of actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'WILLIAMS' AND first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE last_name = 'WILLIAMS' AND first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html]

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT first_name, last_name, address
FROM staff
LEFT JOIN address ON staff.address_id=address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, sum(amount)
FROM staff
JOIN payment ON staff.staff_id=payment.staff_id
WHERE payment_date BETWEEN '2005-08-01' AND '2005-08-31'  -- select date range
GROUP by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, COUNT(actor_id) AS 'number of actors'
FROM film a
INNER JOIN film_actor b ON a.film_id=b.film_id 
GROUP BY title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(film_id) AS "Number of copies (Hunchback Impossible)"
FROM inventory
WHERE film_id IN
	(SELECT film_id             -- subquery to get the film id of the movie
	FROM film
	WHERE title='Hunchback Impossible');

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT  last_name,first_name,SUM(amount) AS "total paid"
FROM payment a
JOIN customer b ON a.customer_id = b.customer_id
GROUP BY a.customer_id 
ORDER BY last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title LIKE 'Q%' OR title LIKE 'K%' AND language_id IN
	(SELECT language_id             -- subquery to get the language id for English
    FROM language
    WHERE name = 'English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name,last_name        -- find the name according to actor id
FROM actor
WHERE actor_id IN 
    (SELECT actor_id               -- find the actor id according to film id
	FROM film_actor
	WHERE film_id IN
		(SELECT film_id             -- find the film_id for Alone Trip
		FROM film
		WHERE title = 'Alone Trip')
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT a.first_name, a.last_name,a.email,b.address_id, b.city_id, b.country  -- get the name and email accodring to address id
FROM customer a                          
JOIN (SELECT a.address_id,b.city_id,b.country -- get the address ids according to city id
	FROM address a
    JOIN (SELECT city_id,country         -- get the city ids according to Canada country id
		FROM city a
        JOIN country b ON a.country_id=b.country_id
		WHERE b.country='Canada') b
	ON a.city_id=b.city_id) b
ON a.address_id=b.address_id;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title, description, rental_rate    -- find the title... according to film id
FROM film 
WHERE film_id IN
	(SELECT film_id             -- get the film id according to category id for all family movie
	FROM film_category
	WHERE category_id IN
		(SELECT category_id    -- get the category id for family movie
		FROM category
		WHERE name='Family'));

-- 7e. Display the most frequently rented movies in descending order.
SELECT a.title, b.film_rented_times                        -- match the title to the film id
FROM film a
JOIN
(SELECT a.film_id, SUM(b.rented_times) AS film_rented_times  -- match the film id for each inventory, and count the total rented times
FROM inventory a
RIGHT JOIN 
	(SELECT inventory_id, COUNT(inventory_id) AS rented_times  -- count how many times each inventory rented
	FROM rental
	GROUP BY inventory_id) b
ON a.inventory_id=b.inventory_id
GROUP BY a.film_id) b
ON a.film_id=b.film_id
ORDER BY b.film_rented_times DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT a.store_id, SUM(b.total)                -- match the customer ids to store id, and count the total amount each store make
FROM customer a
JOIN (
	SELECT customer_id, SUM(amount) AS total     -- count the total amount each customer spent
	FROM payment
	GROUP BY customer_id) b
ON a. customer_id = b. customer_id
GROUP BY a.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT a.store_id,a.city, b.country   -- get the country name according to country_id by joining country table
FROM 
	(SELECT a.store_id,b.city, b.country_id  -- get the city name according to city_id by joining city table
	FROM 
		(SELECT b.store_id, a.city_id   -- get the city_id for each store
		FROM address a
		JOIN store b
		ON a.address_id=b.address_id) a
	JOIN city b
	ON a.city_id=b.city_id) a
JOIN country b
ON a.country_id=b.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT b.name AS top_category, a.category_total AS gross_revenue   -- find the name for each category
FROM	
    (SELECT SUM(a.film_total) AS category_total, b.category_id   -- SUM total for each category
	FROM
		(SELECT SUM(a.inventory_total) AS film_total, b.film_id  -- get the total payment for each film by joining table film 
		FROM 
			(SELECT inventory_id,sum(amount) as inventory_total  -- get the total payment for each inventory by joining inventory with rental
			FROM payment a
			JOIN rental b
			ON a.rental_id=b.rental_id
			GROUP BY inventory_id) a
		JOIN inventory b
		ON a.inventory_id=b.inventory_id
		GROUP BY film_id) a
	JOIN film_category b
	ON a.film_id=b.film_id
	GROUP BY category_id
	ORDER BY category_total DESC
	LIMIT 5 ) a
JOIN category b
ON a.category_id=b.category_id;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres AS
SELECT b.name AS top_category, a.category_total AS gross_revenue   -- find the name for each category
FROM	
    (SELECT SUM(a.film_total) AS category_total, b.category_id   -- SUM total for each category
	FROM
		(SELECT SUM(a.inventory_total) AS film_total, b.film_id  -- get the total payment for each film by joining table film 
		FROM 
			(SELECT inventory_id,sum(amount) as inventory_total  -- get the total payment for each inventory by joining inventory with rental
			FROM payment a
			JOIN rental b
			ON a.rental_id=b.rental_id
			GROUP BY inventory_id) a
		JOIN inventory b
		ON a.inventory_id=b.inventory_id
		GROUP BY film_id) a
	JOIN film_category b
	ON a.film_id=b.film_id
	GROUP BY category_id
	ORDER BY category_total DESC
	LIMIT 5 ) a
JOIN category b
ON a.category_id=b.category_id;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres
