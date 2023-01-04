-- Подзапросы в FROM
/* 1/5
Найдите топ-40 самых длинных фильмов, аренда которых составляет больше 2 долларов. 
Выведите на экран название фильма (поле title), цену аренды (поле rental_rate), 
длительность фильма (поле length) и возрастной рейтинг (поле rating).
*/
SELECT 
    title,
    rental_rate,
    length,
    rating
    
FROM movie
WHERE rental_rate > 2
ORDER BY length DESC
LIMIT 40

/* 2/5
Проанализируйте данные о возрастных рейтингах отобранных фильмов. Выгрузите в итоговую таблицу следующие поля:
 - возрастной рейтинг (поле rating);
 - минимальное и максимальное значения длительности (поле length); назовите поля min_length и max_length соответственно;
 - среднее значение длительности (поле length); назовите поле avg_length;
 - минимум, максимум и среднее для цены просмотра (поле rental_rate); назовите поля min_rental_rate, max_rental_rate, avg_rental_rate соответственно.
Отсортируйте среднюю длительность фильма по возрастанию.
*/
SELECT 
	   top_40.rating,
       MIN(top_40.length) AS min_length,
       MAX(top_40.length) AS max_length,
       AVG(top_40.length) AS avg_length,
       MIN(top_40.rental_rate) AS min_rental_rate,
       MAX(top_40.rental_rate) AS max_rental_rate,
       AVG(top_40.rental_rate) AS avg_rental_rate
       
FROM 
    (SELECT title,
        rental_rate,
	    length,
	    rating
    FROM movie
    WHERE rental_rate > 2
    ORDER BY length DESC
    LIMIT 40) AS top_40

GROUP BY top_40.rating
ORDER BY avg_length

/* 3/5
Найдите средние значения полей, в которых указаны минимальная и максимальная длительность отобранных фильмов. 
Отобразите только два этих поля. 
Назовите их avg_min_length и avg_max_length соответственно.
*/
SELECT 
    AVG(query.min_length) AS avg_min_length, 
    AVG(query.max_length) AS avg_max_length 
FROM    
    (SELECT top.rating,
       MIN(top.length) AS min_length,
       MAX(top.length) AS max_length,
       AVG(top.length) AS avg_length,
       MIN(top.rental_rate) AS min_rental_rate,
       MAX(top.rental_rate) AS max_rental_rate,
       AVG(top.rental_rate) AS avg_rental_rate
    FROM
      (SELECT title,
          rental_rate,
          length,
          rating
       FROM movie
       WHERE rental_rate > 2
       ORDER BY length DESC
       LIMIT 40) AS top
       GROUP BY top.rating
       ORDER BY avg_length) AS query
       
/* 4/5
Отберите альбомы, названия которых содержат слово 'Rock' и его производные. 
В этих альбомах должно быть восемь или более треков. 
Выведите на экран одно число — среднее количество композиций в отобранных альбомах.
*/

SELECT AVG(query.count_track) 
FROM
    (SELECT a.title,
        COUNT(t.track_id) as count_track
    FROM album AS a
    LEFT JOIN track AS t ON t.album_id = a.album_id
    WHERE (a.title LIKE '%Rock%')
    GROUP BY a.title
    HAVING  COUNT(t.track_id) >= 8) AS query

/* 5/5

Для каждой страны посчитайте среднюю стоимость заказов в 2009 году по месяцам. 
Отберите данные за 2, 5, 7 и 10 месяцы и сложите средние значения стоимости заказов. 
Выведите названия стран, у которых это число превышает 10 долларов.
*/

SELECT query2.billing_country
FROM
    (SELECT 
        query.billing_country,
        SUM(query.avg)
        FROM
            (SELECT 
                billing_country, 
                EXTRACT(MONTH FROM CAST(invoice_date AS date)) AS invoice_month,
                AVG(total)
        FROM invoice
        WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2009
        GROUP BY billing_country, invoice_month) AS query
    WHERE query.invoice_month IN (2,5,7,10)
    GROUP BY query.billing_country) AS query2
WHERE query2.sum > 10

-- Подзапросы в WHERE

/* 1/6
Вы уже сравнивали выручку в разных странах, но теперь можно усовершенствовать запросы. 
Напишите код для первого подзапроса. Таблица invoice_line хранит информацию о купленных треках. 
Выгрузите из неё только те заказы (поле invoice_id), которые включают больше пяти треков.
*/

SELECT 
    iid.invoice_id
        
FROM invoice_line AS iid
LEFT JOIN track AS t ON t.track_id = iid.track_id
GROUP BY iid.invoice_id
HAVING COUNT(t.track_id) > 5

/* 2/6
Теперь напишите код для второго подзапроса. 
С помощью той же таблицы найдите среднее значение цены одного трека (поле unit_price).
*/
SELECT 
    AVG(unit_price)
FROM invoice_line    

/* 3/6
Для каждой страны (поле billing_country) посчитайте минимальное, максимальное и среднее значение выручки из поля total. 
Назовите поля так: min_total, max_total и avg_total. Нужные поля для выгрузки хранит таблица invoice. 
При подсчёте учитывайте только те заказы, которые включают более пяти треков. 
Стоимость заказа должна превышать среднюю цену одного трека. Используйте код, написанный в предыдущих заданиях. 
Отсортируйте итоговую таблицу по значению в поле avg_total от большего к меньшему.
*/

SELECT 
    billing_country,
    MIN(total) AS min_total, 
    MAX(total) AS max_total,
    AVG(total) AS avg_total --SUM(total) / COUNT(total) AS avg_total
FROM invoice
WHERE (invoice_id IN (SELECT 
                        il.invoice_id
        
                     FROM invoice_line AS il
                     GROUP BY il.invoice_id
                     HAVING COUNT(il.track_id) > 5))

     AND
     
     (total > (SELECT 
                AVG(unit_price)
              FROM invoice_line))

GROUP BY billing_country
ORDER BY avg_total  DESC

/* 4/6
Отберите десять самых коротких по продолжительности треков и выгрузите названия их жанров. 
*/

SELECT name
FROM genre
WHERE genre_id IN (SELECT 
     genre.genre_id
FROM track
LEFT JOIN genre ON genre.genre_id = track.genre_id
ORDER BY milliseconds ASC
LIMIT 10)

/* 5/6
Выгрузите уникальные названия городов, в которых стоимость заказов превышает среднее значение за 2009 год.
*/

SELECT DISTINCT billing_city
FROM invoice
WHERE total > (SELECT 
    AVG(total)
    FROM invoice 
    WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2009)

/* 6/6
Найдите возрастной рейтинг с самыми дорогими для аренды фильмами. 
Для этого посчитайте среднюю стоимость аренды фильма каждого рейтинга. 
Выведите на экран названия категорий фильмов с этим рейтингом. 
Добавьте второе поле со средним значением продолжительности фильмов.
*/

SELECT 
    name,
    AVG(m.length)
FROM category AS c
LEFT JOIN film_category AS fc ON fc.category_id = c.category_id
LEFT JOIN movie AS m ON m.film_id = fc.film_id
WHERE m.rating = (SELECT 
                    rating
                  FROM movie 
                  GROUP BY rating
                  ORDER BY AVG(rental_rate) DESC
                  LIMIT 1)
GROUP BY name

-- Как сочетать объединения и подзапросы

/* 1/4
Составьте сводную таблицу. 
Посчитайте заказы, оформленные за каждый месяц в течение нескольких лет: с 2011 по 2013 год. 
Итоговая таблица должна включать четыре поля: invoice_month, year_2011, year_2012, year_2013. 
Поле month должно хранить месяц в виде числа от 1 до 12. 
Если в какой-либо месяц заказы не оформляли, номер такого месяца всё равно должен попасть в таблицу.
В этом задании не будет подсказок. Используйте любые методы, которые посчитаете нужными.
*/

WITH 
i AS (SELECT EXTRACT(MONTH FROM CAST(invoice_date AS DATE)) AS invoice_month, 
             EXTRACT(YEAR FROM CAST(invoice_date AS DATE)) AS year, 
             COUNT(invoice_id) AS total 
      FROM invoice 
      GROUP BY invoice_month, year),

j AS (SELECT invoice_month AS invoice_month, total AS year_2011 
      FROM i 
      WHERE i.year = '2011' ),
      
y AS (SELECT invoice_month AS invoice_month, total AS year_2012 
      FROM i 
      WHERE i.year = '2012' ),

z AS (SELECT invoice_month AS invoice_month, total AS year_2013 
      FROM i 
      WHERE i.year = '2013' )

SELECT DISTINCT z.invoice_month AS invoice_month, 
       j.year_2011 AS year_2011, 
       y.year_2012 AS year_2012, 
       z.year_2013 AS year_2013 
FROM i
LEFT JOIN j ON i.invoice_month=j.invoice_month 
LEFT JOIN y ON j.invoice_month=y.invoice_month 
LEFT JOIN z ON y.invoice_month=z.invoice_month

/* 2/4
Отберите фамилии пользователей, которые:
оформили хотя бы один заказ в январе 2013 года,
а также сделали хотя бы один заказ в остальные месяцы того же года.
Пользователей, которые оформили заказы только в январе, а в остальное время ничего не заказывали, 
в таблицу включать не нужно.
*/
SELECT 
    c.last_name
FROM 
(SELECT DISTINCT customer_id
FROM invoice
WHERE CAST(invoice_date AS date) BETWEEN '2013-02-01' AND '2013-12-31') AS other
LEFT JOIN client AS c ON c.customer_id = other.customer_id
WHERE other.customer_id IN
(SELECT DISTINCT customer_id
FROM invoice
WHERE CAST(invoice_date AS date) BETWEEN '2013-01-01' AND '2013-01-31')

/* 3/4
Сформируйте статистику по категориям фильмов. Отобразите в итоговой таблице два поля:
- название категории;
- число фильмов из этой категории.
Фильмы для второго поля нужно отобрать по условию. 
Посчитайте фильмы только с теми актёрами и актрисами, которые больше семи раз снимались в фильмах, 
вышедших после 2013 года. 
Назовите поля name_category и total_films соответственно. 
Отсортируйте таблицу по количеству фильмов от большего к меньшему, 
а затем по полю с названием категории в лексикографическом порядке.
*/
SELECT 
    c.name AS name_category,
    COUNT(fc.film_id) AS total_films
 
FROM film_category AS  fc
LEFT JOIN category AS c ON c.category_id = fc.category_id

WHERE fc.film_id IN
(SELECT film_id
FROM film_actor
WHERE actor_id IN

(SELECT 
    fa.actor_id--,
    --count(fa.film_id)
FROM film_actor AS fa
WHERE fa.film_id IN
(SELECT 
    film_id
FROM movie
WHERE release_year > 2013)
GROUP BY fa.actor_id
HAVING count(fa.film_id)  > 7))

GROUP BY name_category
ORDER BY total_films DESC,
         name_category ASC
		 
/* 4/4
Определите, летом какого года общая выручка в магазине была максимальной. 
Затем проанализируйте данные за этот год по странам. Выгрузите таблицу с полями:
- country — название страны;
- total_invoice — число заказов, оформленных в этой стране в тот год, когда общая выручка за лето была максимальной;
- total_customer — число клиентов, зарегистрированных в этой стране.
Отсортируйте таблицу по убыванию значений в поле total_invoice, 
а затем добавьте сортировку по названию страны в лексикографическом порядке.
*/

SELECT 
    tot_inv.country,
    tot_inv.total_invoice,
    tot_cust.total_customer
FROM
(SELECT
    billing_country AS country ,
    COUNT(total) AS total_invoice 
   
FROM invoice

WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = (SELECT 
                                                        EXTRACT(YEAR FROM CAST(invoice_date AS date)) AS year--,
                                                        --SUM(total) as summer_sum
                                                        FROM invoice 
                                                       WHERE EXTRACT(MONTH FROM CAST(invoice_date AS date)) IN (6, 7, 8)
                                                       GROUP BY year
                                                       ORDER BY SUM(total) DESC
                                                       LIMIT 1)
GROUP BY   billing_country) as tot_inv 
LEFT JOIN
(SELECT
    billing_country,
    COUNT(DISTINCT customer_id) AS total_customer 
FROM invoice
GROUP BY billing_country ) AS tot_cust ON tot_inv.country = tot_cust.billing_country

ORDER BY total_invoice DESC,
         country ASC
		 
-- Временные таблицы

/* 1/3

Перепишите один из своих прошлых запросов с использованием оператора WITH. 
Выведите топ-40 самых длинных фильмов, аренда которых составляет больше 2 долларов. 
Проанализируйте данные о возрастных рейтингах отобранных фильмов. 
Выгрузите в итоговую таблицу следующие поля:
- возрастной рейтинг (поле rating);
- минимальное и максимальное значения длительности (поле length), назовите поля min_length и max_length соответственно;
- среднее значение длительности (поле length), назовите поле avg_length;
- минимум, максимум и среднее для цены просмотра (поле rental_rate), назовите поля min_rental_rate, max_rental_rate, avg_rental_rate соответственно.
Отсортируйте среднюю длительность фильма по возрастанию.
*/

WITH
top_40 AS (SELECT 
            title,
            rental_rate,
            length,
            rating
    
           FROM movie
           WHERE rental_rate > 2
           ORDER BY length DESC
           LIMIT 40)
           
           
           
SELECT 
	   top_40.rating,
       MIN(top_40.length) AS min_length,
       MAX(top_40.length) AS max_length,
       AVG(top_40.length) AS avg_length,
       MIN(top_40.rental_rate) AS min_rental_rate,
       MAX(top_40.rental_rate) AS max_rental_rate,
       AVG(top_40.rental_rate) AS avg_rental_rate
       
FROM top_40

GROUP BY top_40.rating
ORDER BY avg_length

/* 2/3
Перепишите один из своих прошлых запросов, используя оператор WITH. 
Составьте сводную таблицу. 
Посчитайте заказы, оформленные за каждый месяц в течение нескольких лет: с 2011 по 2013 год. 
Итоговая таблица должна включать четыре поля: invoice_month, year_2011, year_2012, year_2013. 
Поле month должно хранить месяц в виде числа от 1 до 12. 
Если в какой-либо месяц заказы не оформляли, номер такого месяца всё равно должен попасть в таблицу.
*/
WITH
y2011 AS (SELECT 
            EXTRACT(MONTH FROM CAST(invoice_date AS date)) as month,
            COUNT(total) as sum
          FROM invoice
          WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2011
          GROUP BY month),
y2012 AS (SELECT 
            EXTRACT(MONTH FROM CAST(invoice_date AS date)) as month,
            COUNT(total) as sum
          FROM invoice
          WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2012
          GROUP BY month),
y2013 AS (SELECT 
            EXTRACT(MONTH FROM CAST(invoice_date AS date)) as month,
            COUNT(total) as sum
          FROM invoice
          WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2013
          GROUP BY month)
         
          
SELECT 
    y2011.month AS invoice_month,
    y2011.sum AS year_2011,
    y2012.sum AS year_2012,
    y2013.sum AS year_2013
    
FROM y2011 LEFT JOIN y2012 ON y2012.month = y2011.month LEFT JOIN y2013 ON y2013.month = y2011.month

/* 3/3
Проанализируйте данные из таблицы invoice за 2012 и 2013 годы. 
В итоговую таблицу должны войти поля:
 - month — номер месяца;
 - sum_total_2012 — выручка за этот месяц в 2012 году;
 - sum_total_2013 — выручка за этот месяц в 2013 году;
 - perc — процент, который отображает, насколько изменилась месячная выручка в 2013 году по сравнению с 2012 годом.
Округлите значение в поле perc до ближайшего целого числа. 
Отсортируйте таблицу по значению в поле month от меньшего к большему.
*/

WITH
y2012 AS (SELECT 
            EXTRACT(MONTH FROM CAST(invoice_date AS date)) as month,
            SUM(total) as sum
          FROM invoice
          WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2012
          GROUP BY month),

y2013 AS (SELECT 
            EXTRACT(MONTH FROM CAST(invoice_date AS date)) as month,
            SUM(total) as sum
          FROM invoice
          WHERE EXTRACT(YEAR FROM CAST(invoice_date AS date)) = 2013
          GROUP BY month)
          
SELECT 
    y2012.month AS month,
    y2012.sum AS sum_total_2012,
    y2013.sum AS sum_total_2013, 
    ROUND(((y2013.sum-y2012.sum)/y2012.sum)*100)  AS perc

FROM y2012 LEFT JOIN y2013 ON y2012.month = y2013.month
ORDER BY month ASC
