-- Схемы данных и оконные функции

-- 5 - Определение окна

/* 1/2
Напишите запрос, который выведет все поля таблицы tools_shop.orders
и отдельным полем суммарную стоимость всех заказов.
*/
SELECT *,
        SUM(total_amt) OVER ()
FROM tools_shop.orders 

/* 2/2
Напишите запрос, который выведет все поля таблицы tools_shop.users 
и отдельным полем количество пользователей в этой таблице.
*/
SELECT *,
        COUNT(user_id) OVER ()
FROM tools_shop.users 

-- 6 - Операторы окна: PARTITION BY

/* 1/2
Напишите запрос, который выведет все поля таблицы tools_shop.orders 
и отдельным полем суммарную стоимость заказов для каждого пользователя.
*/
SELECT *,
        SUM(total_amt) OVER (PARTITION BY user_id)
FROM tools_shop.orders 

/* 2/2

Напишите запрос, который выведет все поля таблицы tools_shop.orders 
и отдельным полем суммарную стоимость заказов за каждый месяц.
*/
SELECT *,
        SUM(total_amt) OVER (PARTITION BY DATE_TRUNC('month', paid_at))
FROM tools_shop.orders 

-- 7 - Функции ранжирования: ROW_NUMBER()

/* 1/2
Выведите все поля таблицы tools_shop.items, добавив поле с рангом записи.
*/
SELECT *,
          ROW_NUMBER() OVER ()
FROM tools_shop.items 

/* 2/2
Выведите все поля таблицы tools_shop.orders, добавив поле с рангом записи.
*/
SELECT *,
          ROW_NUMBER() OVER ()
FROM tools_shop.orders 

-- 8 - Операторы окна: ORDER BY

/* 1/2
Проранжируйте записи в таблице tools_shop.users по дате регистрации — от меньшей к большей. 
Напишите запрос, который выведет идентификатор пользователя с рангом 2021.
*/
WITH
temp AS (SELECT *,
          ROW_NUMBER() OVER (ORDER BY created_at) as cr_rank
         FROM tools_shop.users )
         
SELECT user_id 
FROM temp
WHERE cr_rank = 2021

/* 2/2
Проранжируйте записи в таблице tools_shop.orders по дате оплаты заказа — от большей к меньшей. 
Напишите запрос, который выведет стоимость заказа с рангом 50.
*/
WITH
temp AS (SELECT *,
          ROW_NUMBER() OVER (ORDER BY paid_at DESC) as cr_rank
         FROM tools_shop.orders  )
         
SELECT total_amt 
FROM temp
WHERE cr_rank = 50

-- 9 - Функции ранжирования: RANK() и DENSE_RANK()

/* 1/2
Проранжируйте записи в таблице tools_shop.order_x_item в зависимости от значения item_id — от меньшего к большему. 
Записи с одинаковым item_id должны получить один ранг. 
Ранги можно указать непоследовательно.
*/
SELECT *,
    RANK() OVER (ORDER BY item_id) as cr_rank
FROM tools_shop.order_x_item  

/* 2/2
Проранжируйте записи в таблице tools_shop.users в зависимости от значения в поле created_at — от большего к меньшему. 
Записи с одинаковым значением created_at должны получить один ранг. 
Ранги должны быть указаны последовательно.
*/
SELECT *,
    DENSE_RANK() OVER (ORDER BY created_at DESC) as cr_rank
FROM tools_shop.users

-- 10 - Функция ранжирования NTILE()

/* 1/1
Разбейте заказы из таблицы tools_shop.orders на десять групп, 
отсортировав их по значению суммы заказа по возрастанию.
Выведите поля:
 - идентификатор заказа;
 - сумма заказа;
 - ранг группы. 
 */
SELECT order_id, total_amt,
    NTILE(10) OVER (ORDER BY total_amt ASC) as cr_rank
FROM tools_shop.orders

/* 2/2
Разбейте пользователей в таблице tools_shop.users на пять групп так, 
чтобы в первую группу попали пользователи, которые недавно зарегистрировались. 
Выгрузите поля: 
 - идентификатор пользователя;
 - дата регистрации;
 - ранг группы.
 */
SELECT user_id, created_at,
    NTILE(5) OVER (ORDER BY created_at DESC) as cr_rank
FROM tools_shop.users  

-- 11 - Операторы окна: продолжение

/* 1/2
Выведите все поля таблицы tools_shop.orders и проранжируйте заказы для каждого клиента 
в зависимости от даты оплаты заказа — от меньшей к большей.
*/
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY paid_at ASC) AS rn
FROM tools_shop.orders

/* 2/2
Выведите все поля таблицы tools_shop.events и проранжируйте события 
для каждого клиента в зависимости от его даты — от большей к меньшей.
*/
SELECT *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC) AS rn
FROM tools_shop.events 

-- 12 - Агрегирующие оконные функции

/* 1/2
Рассчитайте общее количество заказов в таблице tools_shop.orders по дням. 
Выведите все поля таблицы и новое поле с количеством заказов.
*/
SELECT *,
       COUNT(order_id) OVER (PARTITION BY DATE_TRUNC('day',created_at)) AS orders_cnt
FROM tools_shop.orders 

/* 2/2
Рассчитайте общую выручку в таблице tools_shop.orders по месяцам. 
Выведите все поля таблицы и новое поле с суммой выручки.
*/
SELECT *,
       SUM(total_amt) OVER (PARTITION BY DATE_TRUNC('month',created_at)) AS orders_cnt
FROM tools_shop.orders 

-- 13 - Расчёт кумулятивных значений

/* 1/3
Напишите запрос к таблице tools_shop.orders, который выведет:
 - дату и время заказа created_at;
 - сумму заказа total_amt;
 - сумму заказа с накоплением, отсортированную по возрастанию даты и времени заказа.
 */
SELECT created_at, total_amt,
       SUM(total_amt) OVER (ORDER BY created_at)
FROM tools_shop.orders

/* 2/3
Напишите запрос к таблице tools_shop.orders, который выведет:
 - идентификатор пользователя user_id;
 - дату и время заказа created_at;
 - сумму заказа total_amt;
 - сумму заказа с накоплением для каждого пользователя, отсортированную по возрастанию даты и времени заказа.
 */
SELECT user_id, created_at, total_amt,
       SUM(total_amt) OVER (PARTITION BY user_id ORDER BY created_at)
FROM tools_shop.orders

/* 3/3

Напишите запрос к таблице tools_shop.orders, который выведет:
 - месяц заказа в формате '2016-02-01', приведённый к типу date;
 - сумму заказа total_amt;
 - сумму заказа с накоплением, отсортированную по возрастанию месяца оформления заказа 
   (здесь дата — дата и время, усечённые до месяца) 
*/
SELECT CAST(DATE_TRUNC('month', created_at) AS date), total_amt,
       SUM(total_amt) OVER (ORDER BY DATE_TRUNC('month', created_at))
FROM tools_shop.orders

-- 14 - Функции смещения: LEAD(), LAG()

/* 1/3
Из таблицы tools_shop.orders выведите поля order_id, user_id, paid_at 
и к ним добавьте поле paid_at с датой предыдущего заказа для каждого пользователя. 
Если предыдущего заказа нет, выведите дату 1 января 1980 года.
*/
SELECT order_id, user_id, paid_at,
    LAG(paid_at, 1, '1980-01-01') OVER (PARTITION BY user_id ORDER BY paid_at)

FROM tools_shop.orders

/* 2/3
Выведите поля event_id, event_time, user_id из таблицы tools_shop.events 
и к ним добавьте поле с датой и временем следующего события для каждого пользователя. 
Если события нет, оставьте значение NULL.
*/
SELECT event_id, event_time, user_id,
    LEAD(event_time) OVER (PARTITION BY user_id ORDER BY event_time)

FROM tools_shop.events 

/* 3/3
Исправьте предыдущий запрос: замените дату следующего события на интервал между текущим и следующим событием. 
Значение интервала должно быть положительным. 
Если события нет, оставьте значение NULL.
*/
SELECT event_id, event_time, user_id,
    LEAD(event_time) OVER (PARTITION BY user_id ORDER BY event_time) - event_time

FROM tools_shop.events 

-- Оконные функции: практика

/* 1/10
Напишите запрос, который проранжирует расходы на привлечение пользователей за каждый день по убыванию. 
Выгрузите три поля: 
 - дата, которую нужно привести к типу date;
 - расходы на привлечение;
 - ранг строки.
*/
SELECT CAST(created_at AS date),
    costs,
    ROW_NUMBER() OVER (ORDER BY costs DESC)
    
FROM tools_shop.costs

/* 2/10

Измените предыдущий запрос: 
- записям с одинаковыми значениями расходов назначьте одинаковый ранг. 
Ранги не должны прерываться.
*/
SELECT CAST(created_at AS date),
    costs,
    DENSE_RANK() OVER (ORDER BY costs DESC)
    
FROM tools_shop.costs

/* 3/10
Используя оконную функцию, выведите список уникальных user_id пользователей, 
которые совершили три заказа и более.
*/
WITH 
temp AS (SELECT user_id,
            COUNT(order_id) OVER (PARTITION BY user_id) AS order_count
         FROM tools_shop.orders)

SELECT DISTINCT user_id
FROM temp
WHERE order_count >= 3


/* 4/10
Используя оконную функцию, выведите количество заказов, 
в которых было четыре товара и более.
*/
SELECT
    COUNT(*)
FROM tools_shop.orders
WHERE items_cnt >= 4

/* 5/10
Рассчитайте количество зарегистрированных пользователей по месяцам с накоплением.
Выгрузите два поля:
 - месяц регистрации, приведённый к типу date;
 - общее количество зарегистрированных пользователей на текущий месяц.
*/
SELECT DISTINCT CAST(DATE_TRUNC('month', created_at) AS date),
       COUNT(user_id) OVER (ORDER BY CAST(DATE_TRUNC('month', created_at) AS date))
FROM tools_shop.users

/* 6/10
Рассчитайте сумму трат на привлечение пользователей с накоплением по месяцам c 2017 по 2018 год включительно.
Выгрузите два поля:
 - месяц, приведённый к типу date;
 - сумма трат на текущий месяц с накоплением.
*/
SELECT DISTINCT CAST(DATE_TRUNC('month', created_at) AS date),
       SUM(costs) OVER (ORDER BY CAST(DATE_TRUNC('month', created_at) AS date))
FROM tools_shop.costs
WHERE CAST(DATE_TRUNC('month', created_at) AS date) BETWEEN '2017-01-01' AND '2018-12-01'

/* 7/10
Посчитайте события с названием view_item по месяцам с накоплением. Рассчитайте количество событий только для тех пользователей, которые совершили хотя бы одну покупку.
Выгрузите поля: 
 - месяц события, приведённый к типу date;
 - количество событий за текущий месяц;
 - количество событий за текущий месяц с накоплением.
*/
WITH
ev_temp AS (SELECT *
           FROM tools_shop.events 
           WHERE user_id IN (SELECT user_id FROM tools_shop.orders)),
           
sum_event AS (SELECT 
              CAST(DATE_TRUNC('month', event_time) AS date) as month,
              COUNT(event_id) AS event_count
             FROM ev_temp
             WHERE event_name = 'view_item'
             GROUP BY month),

sum_event_stacked AS (SELECT DISTINCT CAST(DATE_TRUNC('month', event_time) AS date) as month2,
                           COUNT(event_id) OVER (ORDER BY CAST(DATE_TRUNC('month', event_time) AS date)) AS event_count_stacked
                       FROM ev_temp
                       WHERE event_name = 'view_item')
                       
SELECT month, event_count, sum_event_stacked.event_count_stacked
FROM sum_event
LEFT JOIN sum_event_stacked ON sum_event_stacked.month2 = sum_event.month

/* 8/10
Используя конструкцию WINDOW, рассчитайте суммарную стоимость и количество заказов с накоплением от месяца к месяцу.
Выгрузите поля:
 - идентификатор заказа;
 - месяц оформления заказа, приведённый к типу date;
 - сумма заказа;
 - количество заказов с накоплением;
 - суммарная стоимость заказов с накоплением.
*/
SELECT 
    order_id,
    CAST(DATE_TRUNC('month', created_at) AS date) as month,
    total_amt,
    COUNT(order_id) OVER month_as_date, 
    SUM(total_amt) OVER month_as_date 
FROM tools_shop.orders
           
WINDOW month_as_date AS (ORDER BY CAST(DATE_TRUNC('month', created_at) AS date));

/* 9/10
Напишите запрос, который выведет сумму трат на привлечение пользователей по месяцам, 
а также разницу в тратах между текущим и предыдущим месяцами. 
Разница должна показывать, на сколько траты текущего месяца отличаются от предыдущего. 
В случае, если данных по предыдущему месяцу нет, укажите ноль.
Выгрузите поля:
 - месяц, приведённый к типу date;
 - траты на привлечение пользователей в текущем месяце;
 - разница в тратах между текущим и предыдущим месяцами.
*/
WITH 
costs_gr AS (SELECT 
             CAST(DATE_TRUNC('month', created_at) AS date) as month,
             SUM(costs) AS sum_costs
             FROM tools_shop.costs
             GROUP BY month
             ORDER BY month)

SELECT 
    month,
    sum_costs,
    sum_costs - LAG(sum_costs,1,sum_costs) OVER (ORDER BY month)
    
FROM costs_gr

/* 10/10
Напишите запрос, который выведет сумму выручки по годам и разницу выручки между текущим и следующим годом. 
Разница должна показывать, на сколько выручка следующего года отличается от текущего. 
В случае, если данных по следующему году нет, укажите ноль.
Выгрузите поля:
 - год, приведённый к типу date;
 - выручка за текущий год;
 - разница в выручке между текущим и следующим годом.
*/
WITH 
orders_by_year AS (SELECT
                       CAST(DATE_TRUNC('year', paid_at) AS date) as year,
                       SUM(total_amt) AS sum_total
                   FROM tools_shop.orders
                   GROUP BY year
                   ORDER BY year)

SELECT 
    year,
    sum_total,
    LEAD(sum_total,1,sum_total) OVER (ORDER BY year) - sum_total AS diff
    
FROM orders_by_year