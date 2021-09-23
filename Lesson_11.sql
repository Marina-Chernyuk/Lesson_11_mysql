/* Практическое задание по теме “Оптимизация запросов”*/

/* Задание 1: Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.*/

---- создаём таблицу logs с необходимыми полями

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время регистрации события.',
  table_name VARCHAR(64) COMMENT 'Таблица, в которой было зарегистрировано событие.',
  primary_key BIGINT UNSIGNED NOT NULL COMMENT 'id поля, добавление которого было зарегистрировано.',
  field_name VARCHAR(255) COMMENT 'Название поля.'
) COMMENT = 'Логирование создания записей' ENGINE=ARCHIVE;

----- создаём триггеры

DROP TRIGGER IF EXISTS log_users;
DROP TRIGGER IF EXISTS log_catalogs;
DROP TRIGGER IF EXISTS log_products;

DELIMITER //

CREATE TRIGGER log_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key, field_name) VALUES ('users', NEW.id, NEW.name);
END//

CREATE TRIGGER log_catalogs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key, field_name) VALUES ('catalogs', NEW.id, NEW.name);
END//

CREATE TRIGGER log_products AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key, field_name) VALUES ('products', NEW.id, NEW.name);
END//

----- добавим для примера в таблицы (users, catalogs, products) по одной записи

INSERT INTO users (name, birthday_at) VALUES ('Roman', '1986-09-15');

INSERT INTO catalogs (name) VALUES ('Sound Cards');

INSERT INTO products (name, desсription, price, catalog_id)
VALUES ('Asus Xonar U7', 'Sound Card Asus Xonar U7', 2500, 8);

--- смотрим на результат

SELECT * FROM logs;


/* Задание 2: (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.*/


DROP PROCEDURE IF EXISTS random_users;
DELIMITER //
CREATE PROCEDURE random_users()
BEGIN
DECLARE count INT DEFAULT 0;
WHILE count < 1000 DO
INSERT INTO users (name, birthday_at) VALUES
(LEFT(UUID(), RAND()*(10-5)+5), DATE(CURRENT_TIMESTAMP - INTERVAL FLOOR(RAND() * 365) DAY));
SET count = count + 1;
END WHILE;
END//

DELIMITER;

--- Выполни сохраненную процедуру
CALL random_users();

--- посмотрим результат в таблице
SELECT * FROM users;


/* Практическое задание по теме “NoSQL”*/


/* Задание 1: В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.*/

---------- ВАРИАНТ 1

--- используем, например, адреса машин в локальной сети
HSET counters '192.85.255.12' 8
HSET counters '10.195.232.48' 12
HSET counters '127.215.38.79' 3

--- смотрим результат
HGETALL counters


--------- ВАРИАНТ 2

--- DNS Yandex 
--- можно создать проверку посещений сразу нескольких IP- адресов одним запросом
MSET 77.88.8.88 0 77.88.8.1 0 77.88.8.7 0

--- посмотрим результат, введя команду 
MGET 77.88.8.88 77.88.8.1 77.88.8.7
--- 1) "0"
--- 2) "0"
--- 3) "0"

--- добавим одно посещение по первому адресу
INCR 77.88.8.88

--- смотрим результат
MGET 77.88.8.88 77.88.8.1 77.88.8.7
-- 1) "1"
-- 2) "0"
-- 3) "0"

--- добавим два посещения по третьему адресу
INCR 77.88.8.7
INCR 77.88.8.7

--- смотрим результат
MGET 77.88.8.88 77.88.8.1 77.88.8.7
-- 1) "1"
-- 2) "0"
-- 3) "2"


/* Задание 2: При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.*/

HSET email 'Marina' 'marina@yandex.ru'
HSET name 'marina@yandex.ru' 'Marina'
HGET email 'Marina'
HGET name 'marina@yandex.ru'

--- запрос на запись с одним ключем без аргумента выдаст ошибку
HSET name_user 'Klava'
--- (error) ERR wrong number of arguments for 'hset' command

--- кавычки могут быть одинарные и двойные
HSET email 'Matrena' "matrena@mail.ru"
HSET name 'matrena@mail.ru' "Matrena"
HGET email 'Matrena'
HGET name 'matrena@mail.ru'

--- имя ключа в запросе может быть любым
HSET aaaa 'Oksana' 'oksana@gmail.ru'
HGET aaaa 'Oksana'
--- результат
'oksana@gmail.ru'

