-- Расширенный скрипт для geometrybeatdb под схему с login как PK
DROP DATABASE IF EXISTS geometrybeatdb;
CREATE DATABASE IF NOT EXISTS geometrybeatdb
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
USE geometrybeatdb;

-- Справочник статусов пользователей
CREATE TABLE user_statuses (
    id   INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(128) NOT NULL
);

-- Таблица пользователей: PK = login
CREATE TABLE users (
    login      VARCHAR(128)   NOT NULL PRIMARY KEY,
    password   CHAR(64)       NOT NULL,
    f_name     CHAR(24)       NOT NULL,
    s_name     CHAR(24)       NOT NULL,
    t_name     CHAR(24)       NULL,
    status     INT UNSIGNED   NOT NULL DEFAULT 1,
    created_at DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (status) REFERENCES user_statuses(id)
);

-- Записи уровней: связываются по login
CREATE TABLE user_level_records (
    record_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_login  VARCHAR(128)    NOT NULL,
    level_id    INT             NOT NULL,
    points      INT UNSIGNED    NOT NULL DEFAULT 0,
    collected   INT UNSIGNED    NOT NULL DEFAULT 0,
    hits		INT UNSIGNED    NOT NULL DEFAULT 0,
    record_date DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX (user_login),
    FOREIGN KEY (user_login)
    REFERENCES users(login)
    ON DELETE CASCADE
);

-- Таблица заявок на удаление: по login
CREATE TABLE user_delete_requests (
    request_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_login   VARCHAR(128)    NOT NULL UNIQUE,
    request_date DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX (user_login),
    FOREIGN KEY (user_login)
    REFERENCES users(login)
    ON DELETE CASCADE
);

-- Процедура: создать заявку на удаление данных пользователя (по login)
DELIMITER $
CREATE PROCEDURE create_delete_request(
    IN in_user_login VARCHAR(128)
)
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM user_delete_requests WHERE user_login = in_user_login
    ) THEN
        INSERT INTO user_delete_requests(user_login)
        VALUES(in_user_login);
    END IF;
END$
DELIMITER ;

-- Процедура: отменить заявку (удаляет запись) по login
DELIMITER $
CREATE PROCEDURE cancel_delete_request(
    IN in_user_login VARCHAR(128)
)
BEGIN
    DELETE FROM user_delete_requests
     WHERE user_login = in_user_login;
END$
DELIMITER ;

-- Процедура: выполнить заявку (удаляет данные и запись заявки) по login
DELIMITER $
CREATE PROCEDURE execute_delete_request(
    IN in_user_login VARCHAR(128)
)
BEGIN     -- удаляем записи уровней
    DELETE FROM user_level_records WHERE user_login = in_user_login;     -- удаляем пользователя
    DELETE FROM users             WHERE login = in_user_login;     -- удаляем заявку
    DELETE FROM user_delete_requests WHERE user_login = in_user_login;
END$
DELIMITER ;

/*-- Функция: получение общей суммы очков по login
DELIMITER $
CREATE FUNCTION get_user_points(u_login VARCHAR(128))
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE total_points INT DEFAULT 0;
    SELECT COALESCE(SUM(points),0)
      INTO total_points
      FROM user_level_records
     WHERE user_login = u_login;
    RETURN JSON_OBJECT('total_points', total_points);
END$
DELIMITER ;*/

-- Процедура: получение попыток конкретного уровня по login
DELIMITER $
CREATE PROCEDURE get_user_level_attempts(
    IN in_user_login VARCHAR(128),
    IN in_level_id  INT,
    IN in_sort_cols VARCHAR(255)
)
BEGIN
    IF in_sort_cols IS NULL OR TRIM(in_sort_cols) = '' THEN
        SET in_sort_cols = 'record_date DESC';
    END IF;
    SET @sql = CONCAT(
        'SELECT points, collected, hits, record_date',
        ' FROM user_level_records',
        ' WHERE user_login = ', QUOTE(in_user_login),
        '   AND level_id = ', in_level_id,
        ' ORDER BY ', in_sort_cols
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$
DELIMITER ;

-- Процедура: получение всех попыток по login
DELIMITER $
CREATE PROCEDURE get_user_all_attempts(
    IN in_user_login VARCHAR(128),
    IN in_sort_cols   VARCHAR(255)
)
BEGIN
    IF in_sort_cols IS NULL OR TRIM(in_sort_cols) = '' THEN
        SET in_sort_cols = 'record_date DESC';
    END IF;
    SET @sql = CONCAT(
        'SELECT points, collected, hits, record_date',
        ' FROM user_level_records',
        ' WHERE user_login = ', QUOTE(in_user_login),
        ' ORDER BY ', in_sort_cols
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$
DELIMITER ;

-- Данные для тестирования

INSERT INTO user_statuses (name) VALUES
  ('пациент'),
  ('мед. персонал');

INSERT INTO users (login, password, f_name, s_name, t_name, status) VALUES
  ('dctr-1', SHA2('d2cs',256), 'имя1', 'фамилия1', 'отчество1', 2),
  ('user-1', SHA2('12qa',256), 'Иван',     'Иванов',    'Иванович', 1),
  ('user-2', SHA2('13qa',256), 'Мария',    'Петрова',   'Сергеевна',1),
  ('user-3', SHA2('14qa',256), 'Алексей',  'Сидоров',   'Викторович',1),
  ('user-4', SHA2('15qa',256), 'Екатерина','Кузнецова', 'Андреевна',1),
  ('user-5', SHA2('16qa',256), 'Дмитрий',  'Морозов',   NULL,        1),
  ('user-6', SHA2('17qa',256), 'Ольга',    'Попова',    'Николаевна',1),
  ('user-7', SHA2('18qa',256), 'Сергей',   'Волков',    NULL,        1),
  ('user-8', SHA2('19qa',256), 'Анна',     'Лебедева',  'Павловна', 1),
  ('user-9', SHA2('10qa',256), 'Никита',   'Крылов',    'Егорович', 1),
  ('user-10', SHA2('20qa',256), 'Владимир', 'Николаев',    'Дмитриевич', 1),
  ('user-11', SHA2('21qa',256), 'Кристина', 'Орлова',       'Васильевна', 1),
  ('user-12', SHA2('22qa',256), 'Павел',     'Зайцев',       NULL,         1),
  ('user-13', SHA2('23qa',256), 'Людмила',   'Семенова',     'Игоревна',   1),
  ('user-14', SHA2('24qa',256), 'Григорий',  'Ершов',        'Максимович', 1),
  ('user-15', SHA2('25qa',256), 'Татьяна',   'Крылова',      NULL,         1),
  ('user-16', SHA2('26qa',256), 'Михаил',    'Белов',        'Никитич',    1),
  ('user-17', SHA2('27qa',256), 'Оксана',    'Щербакова',    'Алексеевна', 1),
  ('user-18', SHA2('28qa',256), 'Евгений',   'Фомин',        NULL,         1),
  ('user-19', SHA2('29qa',256), 'Надежда',   'Горбачева',    'Петровна',   1);

INSERT INTO user_level_records (user_login, level_id, record_date, points, collected, hits) VALUES
  -- Существующие записи
  ('user-1', 1, '2025-01-01 00:00:00',  2, 0, 2),
  ('user-2', 1, '2025-01-01 00:00:00',  2, 0, 3),
  ('user-2', 1, '2025-01-01 01:00:00',  3, 0, 4),
  ('user-2', 1, '2025-01-01 02:00:00',  4, 0, 5),
  ('user-2', 1, '2025-01-01 03:00:00',  5, 0, 2),
  ('user-2', 1, '2025-01-01 04:00:00',  6, 0, 1),
  ('user-2', 1, '2025-01-01 05:00:00',  7, 0, 0),
  ('user-2', 1, '2025-01-01 06:00:00',  8, 0, 3),
  ('user-1', 1, '2025-02-01 00:00:00',  5, 0, 4),
  ('user-1', 1, '2025-02-01 01:00:00',  6, 2, 1),
  ('user-1', 1, '2025-02-01 02:00:00',  4, 1, 5),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 3),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 2),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 3),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 2),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 3),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 4),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 2),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 3),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 4),
  ('user-1', 1, '2025-02-01 03:00:00', 10, 0, 5),
  ('user-1', 1, NOW(),                  2, 0, 2),

  -- Новые 30 строк для теста
  ('user-1', 2, '2025-03-01 10:00:00',  7, 3, 0),
  ('user-1', 2, '2025-03-02 11:30:00',  8, 1, 1),
  ('user-1', 2, '2025-03-03 09:15:00',  5, 5, 0),
  ('user-1', 3, '2025-03-05 14:20:00', 12, 2, 1),
  ('user-1', 3, '2025-03-06 16:45:00', 15, 4, 1),
  ('user-1', 4, '2025-03-08 08:00:00',  9, 0, 0),

  ('user-2', 2, '2025-03-01 12:00:00',  3, 0, 0),
  ('user-2', 2, '2025-03-02 13:15:00',  4, 1, 0),
  ('user-2', 3, '2025-03-04 17:00:00', 10, 2, 1),
  ('user-2', 3, '2025-03-05 18:30:00', 11, 3, 1),
  ('user-2', 4, '2025-03-07 07:45:00',  6, 0, 0),
  ('user-2', 5, '2025-03-09 20:10:00', 14, 5, 1),

  ('user-3', 1, '2025-02-10 10:10:00',  5, 1, 0),
  ('user-3', 2, '2025-02-12 11:25:00',  6, 2, 1),
  ('user-3', 2, '2025-02-13 12:40:00',  7, 3, 0),
  ('user-3', 3, '2025-02-15 13:55:00', 13, 4, 1),
  ('user-3', 4, '2025-02-17 15:05:00',  9, 1, 0),
  ('user-3', 5, '2025-02-19 16:20:00', 10, 0, 1),

  ('user-4', 1, '2025-01-20 09:00:00',  4, 0, 0),
  ('user-4', 2, '2025-01-22 10:15:00',  5, 1, 0),
  ('user-4', 3, '2025-01-24 11:30:00',  8, 2, 1),
  ('user-4', 4, '2025-01-26 12:45:00', 12, 4, 1),
  ('user-4', 5, '2025-01-28 14:00:00',  7, 0, 0),
  ('user-4', 6, '2025-01-30 15:15:00', 16, 6, 1),

  ('user-5', 1, '2025-02-05 08:30:00',  3, 0, 0),
  ('user-5', 2, '2025-02-07 09:45:00',  4, 1, 0),
  ('user-5', 3, '2025-02-09 11:00:00', 10, 3, 1),
  ('user-5', 4, '2025-02-11 12:15:00', 13, 5, 1),
  ('user-5', 5, '2025-02-13 13:30:00',  8, 2, 0),
  ('user-5', 6, '2025-02-15 14:45:00', 17, 7, 1);


-- Примеры выборок

-- Все пользователи
-- SELECT * FROM users;

-- Записи по пользователю 1, по дате
-- SELECT level_id, points, collected, hits, record_date
--   FROM user_level_records
--  WHERE user_login = 'user-1'
--  ORDER BY record_date DESC;

-- Максимумы по уровням пользователя 1
-- SELECT level_id,
--        MAX(points)    AS max_points,
--        MAX(collected) AS max_collected
--   FROM user_level_records
--  WHERE user_login = 'user-1'
--  GROUP BY level_id
--  ORDER BY level_id;

-- Вызов хранимой процедуры (динамическая сортировка)
-- CALL get_user_level_attempts('user-1', 1, 'points DESC, record_date ASC');

-- Примеры вызова процедур
-- CALL create_delete_request('user-3');
-- CALL cancel_delete_request('user-3');
-- CALL execute_delete_request('user-3');
-- SELECT get_user_points('user-1');
-- CALL get_user_level_attempts('user-1',1,'points DESC');
-- CALL get_user_all_attempts('user-1','record_date');
