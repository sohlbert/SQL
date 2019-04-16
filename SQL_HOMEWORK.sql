USE sakila;

/*--1a-- Display the first and last names of all actors from the table actor.*/
SELECT first_name, last_name
FROM actor

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SET sql_safe_updates = 0;
ALTER TABLE actor ADD COLUMN actor_name VARCHAR(50);
UPDATE actor SET actor_name = CONCAT(first_name, ' ', last_name);
SELECT actor_name FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name LIKE 'JOE';

#2b. Find all actors whose last name contain the letters GEN.
SELECT last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

#2c. Find all actors whose last names contain the letters LI. 
#This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name DESC;

#3a. You want to keep a description of each actor. 
#You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB 
#(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor 
DROP COLUMN description; 
SELECT * FROM actor

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name HAVING COUNT(*)>=1;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) FROM actor GROUP BY last_name HAVING COUNT(*)>1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT actor_id, first_name, last_name, actor_name FROM actor WHERE actor_name = "Groucho Williams";
UPDATE actor SET first_name = upper("Harpo"), actor_name = upper("HARPO WILLIAMS") WHERE actor_id = 172;
SELECT actor_id, first_name, last_name, actor_name FROM actor WHERE actor_id = 172;

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET actor_name = upper("Groucho Williams"), first_name = upper("Groucho") where actor_id = 172; 
SELECT actor_id, first_name, last_name, actor_name FROM actor WHERE actor_id = 172;

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address

#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address.address 
FROM staff JOIN address ON address.address_id = staff.address_id; 
#SELECT first_name FROM staff

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(payment.amount) 
FROM staff JOIN payment ON payment.staff_id = staff.staff_id WHERE payment_date LIKE "2005-08%" 
GROUP BY first_name, last_name;

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT title, COUNT(*) AS number_actors
FROM film
INNER JOIN film_actor USING (film_id)
GROUP BY film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(*) FROM inventory
JOIN film USING (film_id)
WHERE title = "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, SUM(amount) as "Total Paid"
FROM customer
JOIN payment USING(customer_id)
GROUP BY customer_id
ORDER BY last_name, first_name;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
JOIN language USING(language_id)
WHERE NAME = "English"
AND title IN
 (SELECT title FROM film WHERE title LIKE "Q%" OR title LIKE "K%");

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT last_name, first_name
FROM actor
WHERE actor_id IN
	(SELECT actor_id FROM film_actor
	WHERE film_id IN 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));

#7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT country, last_name, first_name, email 
FROM country 
LEFT JOIN customer ON country.country_id = customer.customer_id WHERE country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, category FROM film_list WHERE category = 'Family';

#7e. Display the most frequently rented movies in descending order.
SELECT inventory.film_id, film_text.title, COUNT(rental.inventory_id) FROM inventory
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN film_text ON inventory.film_id = film_text.film_id
GROUP BY rental.inventory_id ORDER BY COUNT(rental.inventory_id) DESC;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) FROM store
JOIN staff ON store.store_id = staff.store_id
JOIN payment ON payment.staff_id = staff.staff_id
GROUP BY store.store_id ORDER BY SUM(amount);

#7g. Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city, country FROM store
JOIN customer ON store.store_id = customer.store_id
JOIN staff ON store.store_id = staff.store_id
JOIN address ON customer.address_id = address.address_id
JOIN city ON address.city_id = city.city_id
JOIN country ON city.country_id = country.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT NAME, SUM(payment.amount) FROM category
JOIN film_category JOIN inventory ON inventory.film_id = film_category.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id 
JOIN payment GROUP BY NAME LIMIT 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
DROP VIEW IF EXISTS top_five_genres;
CREATE VIEW top_five_genres (category, total_sales)
AS
SELECT * FROM sales_by_film_category
ORDER BY total_sales DESC
LIMIT 5;

#8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_genres;