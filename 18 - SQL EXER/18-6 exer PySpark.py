# 3 - Spark и RDD
# Инициализируйте объект SparkContext. Укажите параметр appName равный 'appName'. 
# Создайте переменную weather_entry (англ. «запись о погоде»), в которой сохраните RDD с такими элементами:
#  - дата заказа — 2009-01-01;
#  - самая низкая температура воздуха в этот день (°C) — 15.1;
#  - самая высокая температура воздуха в этот день (°C) — 26.1.
# Напечатайте на экране содержимое RDD. Для этого вызовите функцию take() (англ. «взять»). 
# Посмотрите в документации, как она работает.

from pyspark import SparkContext

sc = SparkContext(appName="appName")
weather_entry =  sc.parallelize(['2009-01-01', 15.1, 26.1]) 
print(weather_entry.take(3))

# 5 - Создание датафреймов

# 1/3
# Загрузите датафрейм из файла /datasets/pickups_terminal_5.csv. 
# Посмотрите в документации, как работает функция show(). 
# Напечайте на экране пять строк из датафрейма.

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')
taxi.show(5)

# 2/3
# Методом show() размер датасета не получить. 
# Найдите в документации функцию, которая посчитает количество строк. 
# Напечайте результат на экране.

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')
print(taxi.count())

# 3/3
# Выберите из датафрейма только столбцы с датами, часами и минутами в указанном порядке. 
# Выбор подмножества столбцов выполняется так же, как в Pandas. 
# Напечатайте на экране пять строк получившейся таблицы.

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')

print(taxi[['date', 'hour', 'minute']].show(5)) #, 'hour', 'minute'].show(5))

# 6 - Обработка пропущенных значений

# 1/2
# Удалите из датафрейма пропущенные значения. 
# Затем напечатайте на экране количество строк в датафрейме.

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')

taxi = taxi.dropna(subset = 'pickups')

print(taxi.count())

# 2/2
# Заполните пропущенные значения в датафрейме нулями. 
# Функцией describe() выведите на экран результаты, чтобы убедиться в корректности заполнения значений.

import numpy as np
import pandas as pd
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')

taxi = taxi.fillna(0, subset = 'pickups')
print(taxi.describe().show()) 

# 7 - SQL-запросы в датафреймах

# 1/2
# Изучите статистические выбросы. 
# Напечатайте на экране пять строк с датами, на которые пришлось максимальное количество заказов такси у терминала №5. 
# Выведите все поля таблицы.

from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')

taxi = taxi.fillna(0)

taxi.registerTempTable("taxi")

print(spark.sql("SELECT * FROM taxi ORDER BY pickups DESC").show(5)) 

# 2/2
# Найдите все даты, на которые пришлось более 200 заказов такси за любой период в 30 минут в этот день. 
# Напечатайте на экране количество таких дней.
from pyspark.sql import SparkSession

APP_NAME = "DataFrames"
SPARK_URL = "local[*]"

spark = SparkSession.builder.appName(APP_NAME) \
        .config('spark.ui.showConsoleProgress', 'false') \
        .getOrCreate()

taxi = spark.read.load('/datasets/pickups_terminal_5.csv', 
                       format='csv', header='true', inferSchema='true')

taxi = taxi.fillna(0)

taxi.registerTempTable("taxi")

print(spark.sql('SELECT COUNT(DISTINCT date) FROM taxi WHERE pickups>200').show(5)) 

