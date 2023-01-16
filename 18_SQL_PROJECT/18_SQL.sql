/*
В этих заданиях нужно проанализировать данные о фондах и инвестициях и написать запросы к базе. Задания будут постепенно усложняться, но всё необходимое для их выполнения: операторы, функции, методы работы с базой — вы уже изучили на курсе.

*/

/* 1/23
Посчитайте, сколько компаний закрылось. */

SELECT COUNT(status)
FROM company
WHERE status = 'closed'

/* 2/23
Отобразите количество привлечённых средств для новостных компаний США. Используйте данные из таблицы company. 
Отсортируйте таблицу по убыванию значений в поле funding_total. */

SELECT  funding_total
FROM company
WHERE category_code = 'news' AND country_code = 'USA'
ORDER BY funding_total DESC

/* 3/23
Найдите общую сумму сделок по покупке одних компаний другими в долларах. 
Отберите сделки, которые осуществлялись только за наличные с 2011 по 2013 год включительно. */

SELECT  SUM(price_amount )
FROM acquisition
WHERE (acquired_at BETWEEN '2011-01-01' AND '2013-12-31' ) AND term_code  = 'cash'

/* 4/23
Отобразите имя, фамилию и названия аккаунтов людей в твиттере, у которых названия аккаунтов начинаются на 'Silver'. */

SELECT first_name, last_name, twitter_username
FROM people
WHERE twitter_username LIKE  ('Silver%' )

/* 5/23
Выведите на экран всю информацию о людях, у которых названия аккаунтов в твиттере содержат подстроку 'money', а фамилия начинается на 'K'. */

SELECT *
FROM people
WHERE twitter_username LIKE  ('%money%' )
    AND
    last_name LIKE ('K%')
	
/* 6/23
Для каждой страны отобразите общую сумму привлечённых инвестиций, которые получили компании, зарегистрированные в этой стране. 
Страну, в которой зарегистрирована компания, можно определить по коду страны. Отсортируйте данные по убыванию суммы. */

SELECT country_code, SUM(funding_total)
FROM company
GROUP BY country_code
ORDER BY SUM(funding_total) DESC

/* 7/23
Составьте таблицу, в которую войдёт дата проведения раунда, а также минимальное и максимальное значения суммы инвестиций, привлечённых в эту дату.
Оставьте в итоговой таблице только те записи, в которых минимальное значение суммы инвестиций не равно нулю и не равно максимальному значению. */

SELECT funded_at, MIN(raised_amount ), MAX(raised_amount ) as max
FROM funding_round
GROUP BY funded_at
HAVING MIN(raised_amount ) <> 0 AND (MIN(raised_amount )  <> MAX(raised_amount ))

/* 8/23

Создайте поле с категориями:
  - Для фондов, которые инвестируют в 100 и более компаний, назначьте категорию high_activity.
  - Для фондов, которые инвестируют в 20 и более компаний до 100, назначьте категорию middle_activity.
  - Если количество инвестируемых компаний фонда не достигает 20, назначьте категорию low_activity.
Отобразите все поля таблицы fund и новое поле с категориями. */

SELECT *,
       CASE
           WHEN invested_companies  >= 20 AND invested_companies  < 100 THEN 'middle_activity'
           WHEN invested_companies  >= 100 THEN 'high_activity'
           ELSE 'low_activity'
       END as cat
FROM fund

/* 9/23
Для каждой из категорий, назначенных в предыдущем задании, посчитайте округлённое до ближайшего целого числа среднее количество инвестиционных раундов, в которых фонд принимал участие. 
Выведите на экран категории и среднее число инвестиционных раундов. Отсортируйте таблицу по возрастанию среднего. */

WITH
fund_cat AS   ( SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
    FROM fund)
    
SELECT activity, ROUND(AVG(investment_rounds)) as avg
FROM fund_cat
GROUP BY activity
ORDER BY avg

/* 10/23

Проанализируйте, в каких странах находятся фонды, которые чаще всего инвестируют в стартапы. 
Для каждой страны посчитайте минимальное, максимальное и среднее число компаний, в которые инвестировали фонды этой страны, основанные с 2010 по 2012 год включительно. 
Исключите страны с фондами, у которых минимальное число компаний, получивших инвестиции, равно нулю. Выгрузите десять самых активных стран-инвесторов.
Отсортируйте таблицу по среднему количеству компаний от большего к меньшему, а затем по коду страны в лексикографическом порядке. */

SELECT country_code, 
        MIN(invested_companies ) as min,
        MAX(invested_companies ) as max,
        AVG(invested_companies ) as avg
FROM fund
WHERE founded_at BETWEEN '2010-01-01' AND '2012-12-31'
GROUP BY country_code
HAVING MIN(invested_companies ) <> 0
ORDER BY avg DESC,
         country_code ASC
LIMIT 10

/* 11/23

Отобразите имя и фамилию всех сотрудников стартапов. Добавьте поле с названием учебного заведения, которое окончил сотрудник, если эта информация известна. */

SELECT first_name, last_name, e.instituition 
FROM people AS p
LEFT JOIN education AS e ON e.person_id  = p.id

/* 12/23

Для каждой компании найдите количество учебных заведений, которые окончили её сотрудники. 
Выведите название компании и число уникальных названий учебных заведений. Составьте топ-5 компаний по количеству университетов. */

WITH uni AS 
(SELECT company_id, e.instituition AS cou 
FROM people as p 
LEFT JOIN education AS e ON p.id = e.person_id) 
 
SELECT c.name, COUNT(DISTINCT uni.cou) 
FROM company as c 
LEFT JOIN uni ON c.id = uni.company_id 
GROUP BY c.name 
ORDER BY COUNT(uni.cou) DESC 
LIMIT 5

/* 13/23

Составьте список с уникальными названиями закрытых компаний, для которых первый раунд финансирования оказался последним. */

WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' )

SELECT DISTINCT c.name
FROM closed_c AS c
LEFT JOIN funding_round AS fr ON fr.company_id = c.id
WHERE  fr.is_first_round + fr.is_last_round = 2

/* 14/23

Составьте список уникальных номеров сотрудников, которые работают в компаниях, отобранных в предыдущем задании. */

WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' ),

query AS (SELECT DISTINCT c.name, c.id 
          FROM closed_c AS c
		  LEFT JOIN funding_round AS fr ON fr.company_id = c.id
          WHERE  fr.is_first_round + fr.is_last_round = 2)
    
SELECT DISTINCT p.id
FROM people AS p 
WHERE p.company_id IN (SELECT id FROM query)

/* 15/23

Составьте таблицу, куда войдут уникальные пары с номерами сотрудников из предыдущей задачи и учебным заведением, которое окончил сотрудник. */

WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' ),

query AS (SELECT DISTINCT c.name, c.id 
          FROM closed_c AS c
          LEFT JOIN funding_round AS fr ON fr.company_id = c.id
		  WHERE  fr.is_first_round + fr.is_last_round = 2),
    
query2 AS (SELECT DISTINCT p.id
    FROM people AS p 
    WHERE p.company_id IN (SELECT id FROM query))
    
SELECT DISTINCT
    query2.id,
    e.instituition 
FROM query2 
JOIN education AS e ON query2.id = e.person_id
	
/* 16/23

Посчитайте количество учебных заведений для каждого сотрудника из предыдущего задания. 
При подсчёте учитывайте, что некоторые сотрудники могли окончить одно и то же заведение дважды. */

WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' ),

query AS (SELECT DISTINCT c.name, c.id 
		  FROM closed_c AS c
		  LEFT JOIN funding_round AS fr ON fr.company_id = c.id
		  WHERE  fr.is_first_round + fr.is_last_round = 2),
    
query2 AS (SELECT DISTINCT p.id
           FROM people AS p 
		   WHERE p.company_id IN (SELECT id FROM query))
    
SELECT 
    query2.id,
    COUNT(e.instituition) 
FROM query2 
JOIN education AS e ON query2.id = e.person_id
GROUP BY query2.id
	
/* 17/23

Дополните предыдущий запрос и выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники разных компаний. 
Нужно вывести только одну запись, группировка здесь не понадобится. */

WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' ),

query AS (SELECT DISTINCT c.name, c.id 
          FROM closed_c AS c
		  LEFT JOIN funding_round AS fr ON fr.company_id = c.id
		  WHERE  fr.is_first_round + fr.is_last_round = 2),
    
query2 AS (SELECT DISTINCT p.id
		   FROM people AS p 
		   WHERE p.company_id IN (SELECT id FROM query))
    
SELECT AVG(count)
FROM (SELECT
          query2.id,
          COUNT(e.instituition) 
      FROM query2 
      JOIN education AS e ON query2.id = e.person_id
      GROUP BY query2.id) as ee
	  
/* 18/23

Напишите похожий запрос: выведите среднее число учебных заведений (всех, не только уникальных), которые окончили сотрудники Facebook. */	  
WITH
closed_c AS (SELECT id, name FROM company WHERE status = 'closed' ),

query AS (SELECT DISTINCT c.name, c.id 
      
    FROM closed_c AS c
    LEFT JOIN funding_round AS fr ON fr.company_id = c.id
    WHERE  fr.is_first_round + fr.is_last_round = 2),
    
query2 AS (SELECT DISTINCT p.id
    FROM people AS p 
    WHERE p.company_id IN (SELECT id FROM query)),

query3 AS (SELECT DISTINCT p.id
    FROM people AS p 
    WHERE p.company_id IN (SELECT id FROM company WHERE name = 'Facebook'))

SELECT AVG(count)
FROM (SELECT
          query3.id,
          COUNT(e.instituition) 
      FROM query3 
      JOIN education AS e ON query3.id = e.person_id
      GROUP BY query3.id) as ee
	  
/* 19/23

Составьте таблицу из полей:
 - name_of_fund — название фонда;
 - name_of_company — название компании;
 - amount — сумма инвестиций, которую привлекла компания в раунде.
В таблицу войдут данные о компаниях, в истории которых было больше шести важных этапов, а раунды финансирования проходили с 2012 по 2013 год включительно. */	

SELECT f.name AS name_of_fund, co.name AS name_of_company, fr.raised_amount AS amount 
FROM investment AS inv 
LEFT JOIN company AS co ON inv.company_id = co.id 
LEFT JOIN fund AS f ON inv.fund_id = f.id 
LEFT JOIN funding_round AS fr ON inv.funding_round_id = fr.id 
 
WHERE co.milestones > 6 
AND CAST(DATE_TRUNC('year', fr.funded_at) AS date) BETWEEN '2012-01-01' AND '2013-12-01'

/* 20/23

Выгрузите таблицу, в которой будут такие поля:
 - название компании-покупателя;
 - сумма сделки;
 - название компании, которую купили;
 - сумма инвестиций, вложенных в купленную компанию;
 - доля, которая отображает, во сколько раз сумма покупки превысила сумму вложенных в компанию инвестиций, округлённая до ближайшего целого числа.
Не учитывайте те сделки, в которых сумма покупки равна нулю. Если сумма инвестиций в компанию равна нулю, исключите такую компанию из таблицы. 
Отсортируйте таблицу по сумме сделки от большей к меньшей, а затем по названию купленной компании в лексикографическом порядке. Ограничьте таблицу первыми десятью записями. */		  

WITH buyers AS (SELECT 
                    a.id AS id2, 
                    c.name AS name_acquiring, 
                    a.price_amount AS total 
                FROM company AS c 
                LEFT JOIN acquisition AS a ON c.id = a.acquiring_company_id), 
 
sellers AS (SELECT 
                a.id AS id2, 
                c.name AS name_acquired,
                c.funding_total AS sale 
            FROM company AS c 
            LEFT JOIN acquisition AS a ON c.id = a.acquired_company_id 
            WHERE status = 'acquired') 
 
SELECT 
    buyers.name_acquiring,
    buyers.total,
    sellers.name_acquired,
    sellers.sale, 
    ROUND(buyers.total/sellers.sale) 
FROM buyers 
LEFT JOIN sellers ON buyers.id2 = sellers.id2 
WHERE buyers.total != 0 AND sellers.sale != 0 
ORDER BY buyers.total DESC, sellers.name_acquired 
LIMIT 10;

/* 21/23

Выгрузите таблицу, в которую войдут названия компаний из категории social, получившие финансирование с 2010 по 2013 год включительно. 
Проверьте, что сумма инвестиций не равна нулю. Выведите также номер месяца, в котором проходил раунд финансирования. */	

WITH 
period AS (SELECT 
           company_id, funded_at, id 
           FROM funding_round 
           WHERE (EXTRACT(YEAR FROM CAST(funded_at AS DATE)) BETWEEN '2010' AND '2013') AND raised_amount <> 0), 

comp_non_zero AS (SELECT *,
                   SUM(funding_total) OVER (PARTITION BY name) AS sum_f 
                  FROM company),

sum AS (SELECT name AS company_name, id AS comp_id, sum_f
         FROM comp_non_zero
         WHERE category_code = 'social'),
             
query AS (SELECT *, sum.sum_f
          FROM period
          JOIN sum ON sum.comp_id = period.company_id
          WHERE company_id IN (SELECT comp_id FROM sum))
 
SELECT 
   --*
    company_name,
    EXTRACT(MONTH FROM funded_at)
FROM query

/* 22/23

Отберите данные по месяцам с 2010 по 2013 год, когда проходили инвестиционные раунды. Сгруппируйте данные по номеру месяца и получите таблицу, в которой будут поля:
 - номер месяца, в котором проходили раунды;
 - количество уникальных названий фондов из США, которые инвестировали в этом месяце;
 - количество компаний, купленных за этот месяц;
 - общая сумма сделок по покупкам в этом месяце. */	
 
 WITH
-- Сначала выделил раунды, чтобы было только 2010-2013 
rounds AS (SELECT
           *
          FROM funding_round
          WHERE funded_at BETWEEN '2010-01-01' AND '2013-12-31'),

-- аналогично выделяю компании, чтобы продажа была только 2010-2013          
a_comps AS (SELECT
           *
           FROM acquisition
           WHERE acquired_at BETWEEN '2010-01-01' AND '2013-12-31'),
           
-- соединяю id раундов и имена фондов (investment и fund) 
fund_count_dis AS (SELECT i.funding_round_id AS f_round_id_i,
                      f.name AS fund_name,
                      i.company_id AS c_name
                   FROM investment AS i
                   LEFT JOIN fund AS f ON f.id = i.fund_id
                   WHERE f.country_code = 'USA'),
                   
-- создаю табл с кол-вом компаний по месяцам и суммой покупок по месяцам                   
purchase AS (SELECT EXTRACT(MONTH FROM a.acquired_at) AS comp_month,
                    COUNT(a.acquired_company_id) AS comp,
                    SUM(a.price_amount) AS total_purchase
             FROM a_comps AS a 
             GROUP BY comp_month),

-- создаю табл с кол-вом фондов (уникальных!) по месяцам 
rounds_and_funds AS (SELECT EXTRACT(MONTH FROM rounds.funded_at) AS month,
                            COUNT(DISTINCT fund_count_dis.fund_name) AS funds
                     FROM rounds 
                     LEFT JOIN fund_count_dis ON fund_count_dis.f_round_id_i = rounds.id
                     GROUP BY month)
                     
-- соединяю предыдущие две таблицы в одну
SELECT rounds_and_funds.month, 
       rounds_and_funds.funds, 
       purchase.comp, 
       purchase.total_purchase
FROM rounds_and_funds
LEFT JOIN purchase ON rounds_and_funds.month = purchase.comp_month

/* 23/23

Составьте сводную таблицу и выведите среднюю сумму инвестиций для стран, в которых есть стартапы, зарегистрированные в 2011, 2012 и 2013 годах. 
Данные за каждый год должны быть в отдельном поле. Отсортируйте таблицу по среднему значению инвестиций за 2011 год от большего к меньшему. */	

WITH
            
y2011 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft
         
          FROM company 
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2011)
          GROUP BY country_code),
          
y2012 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft
         
          FROM company 
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2012)
          GROUP BY country_code),

y2013 AS (SELECT
          country_code,
          AVG(funding_total) AS avg_ft
         
          FROM company 
          WHERE id IN (SELECT id FROM company WHERE EXTRACT(YEAR FROM founded_at) = 2013)
          GROUP BY country_code)
          
SELECT y2011.country_code AS country_code,
       y2011.avg_ft AS value_2011,
       y2012.avg_ft AS value_2012,
       y2013.avg_ft AS value_2013

FROM y2011  
JOIN y2012 ON y2011.country_code  = y2012.country_code
JOIN y2013 ON y2011.country_code  = y2013.country_code

ORDER BY y2011.avg_ft DESC