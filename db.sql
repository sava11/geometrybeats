-- Удаляем и заново создаём базу
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

-- Таблица пользователей
CREATE TABLE users (
    id         INT UNSIGNED   NOT NULL AUTO_INCREMENT PRIMARY KEY,
    login      VARCHAR(128)   NOT NULL,
    password   CHAR(40)       NOT NULL,                  -- SHA1 = 40 hex chars
    f_name     CHAR(24)       NOT NULL,
    s_name     CHAR(24)       NOT NULL,
    t_name     CHAR(24)       NULL,
    status     INT UNSIGNED   NOT NULL DEFAULT 1,       -- по умолчанию «пациент» (id=1)
    created_at DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (status) REFERENCES user_statuses(id)
);

-- Таблица записей уровней пользователей
CREATE TABLE user_level_records (
    record_id   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED    NOT NULL,
    level_id    INT             NOT NULL,
    points      INT UNSIGNED    NOT NULL DEFAULT 0,
    collected   INT UNSIGNED    NOT NULL DEFAULT 0,
    no_hit      TINYINT(1)      NOT NULL DEFAULT 0,
    record_date DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX (user_id),
    FOREIGN KEY (user_id)
      REFERENCES users(id)
      ON DELETE CASCADE
);

-- Функция: получение общей суммы очков пользователя
DELIMITER $$
CREATE FUNCTION get_user_points(uid INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE total_points INT DEFAULT 0;
    SELECT COALESCE(SUM(points),0)
      INTO total_points
      FROM user_level_records
     WHERE user_id = uid;
    RETURN JSON_OBJECT('total_points', total_points);
END$$
DELIMITER ;

-- Процедура: получение попыток пользователя для конкретного уровня
DELIMITER $$
CREATE PROCEDURE get_user_level_attempts(
    IN in_user_id   INT,
    IN in_level_id  INT,
    IN in_sort_cols VARCHAR(255)
)
BEGIN
    IF in_sort_cols IS NULL OR TRIM(in_sort_cols) = '' THEN
        SET in_sort_cols = 'record_date DESC';
    END IF;

    SET @sql = CONCAT(
        'SELECT points, collected, no_hit, record_date ',
        'FROM user_level_records ',
        'WHERE user_id = ',    in_user_id,
        '  AND level_id = ',   in_level_id,
        ' ORDER BY ',          in_sort_cols
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE get_user_all_attempts(
    IN in_user_id   INT,
    IN in_sort_cols VARCHAR(255)
)
BEGIN
    IF in_sort_cols IS NULL OR TRIM(in_sort_cols) = '' THEN
        SET in_sort_cols = 'record_date DESC';
    END IF;

    SET @sql = CONCAT(
        'SELECT points, collected, no_hit, record_date ',
        'FROM user_level_records ',
        'WHERE user_id = ',    in_user_id,
        ' ORDER BY ',          in_sort_cols
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END$$
DELIMITER ;

-- Данные для тестирования

INSERT INTO user_statuses (name) VALUES
  ('пациент'),
  ('мед. персонал');

INSERT INTO users (login, password, f_name, s_name, t_name, status) VALUES
  ('dctr-1', SHA1('d2cs'), 'имя1', 'фамилия1', 'отчество1', 2),
  ('user-1', SHA1('12qa'), 'Иван',     'Иванов',    'Иванович', 1),
  ('user-2', SHA1('13qa'), 'Мария',    'Петрова',   'Сергеевна',1),
  ('user-3', SHA1('14qa'), 'Алексей',  'Сидоров',   'Викторович',1),
  ('user-4', SHA1('15qa'), 'Екатерина','Кузнецова', 'Андреевна',1),
  ('user-5', SHA1('16qa'), 'Дмитрий',  'Морозов',   NULL,        1),
  ('user-6', SHA1('17qa'), 'Ольга',    'Попова',    'Николаевна',1),
  ('user-7', SHA1('18qa'), 'Сергей',   'Волков',    NULL,        1),
  ('user-8', SHA1('19qa'), 'Анна',     'Лебедева',  'Павловна', 1),
  ('user-9', SHA1('10qa'), 'Никита',   'Крылов',    'Егорович', 1),
  ('user-10', SHA1('20qa'), 'Владимир', 'Николаев',    'Дмитриевич', 1),
  ('user-11', SHA1('21qa'), 'Кристина', 'Орлова',       'Васильевна', 1),
  ('user-12', SHA1('22qa'), 'Павел',     'Зайцев',       NULL,         1),
  ('user-13', SHA1('23qa'), 'Людмила',   'Семенова',     'Игоревна',   1),
  ('user-14', SHA1('24qa'), 'Григорий',  'Ершов',        'Максимович', 1),
  ('user-15', SHA1('25qa'), 'Татьяна',   'Крылова',      NULL,         1),
  ('user-16', SHA1('26qa'), 'Михаил',    'Белов',        'Никитич',    1),
  ('user-17', SHA1('27qa'), 'Оксана',    'Щербакова',    'Алексеевна', 1),
  ('user-18', SHA1('28qa'), 'Евгений',   'Фомин',        NULL,         1),
  ('user-19', SHA1('29qa'), 'Надежда',   'Горбачева',    'Петровна',   1);

INSERT INTO user_level_records (user_id, level_id, record_date, points, collected, no_hit) VALUES
  (1, 1, '2025-01-01 00:00:00',  2, 0, 0),
  (2, 1, '2025-01-01 00:00:00',  2, 0, 0),
  (1, 1, '2025-02-01 00:00:00', 10, 0, 1),
  (1, 1, NOW(),                 2, 0, 0);

-- Примеры выборок

-- Все пользователи
SELECT * FROM users;

-- Записи по пользователю 1, по дате
SELECT level_id, points, collected, no_hit, record_date
  FROM user_level_records
 WHERE user_id = 1
 ORDER BY record_date DESC;

-- Максимумы по уровням пользователя 1
SELECT level_id,
       MAX(points)    AS max_points,
       MAX(collected) AS max_collected
  FROM user_level_records
 WHERE user_id = 1
 GROUP BY level_id
 ORDER BY level_id;

-- Вызов хранимой процедуры (динамическая сортировка)
CALL get_user_level_attempts(1, 1, 'points DESC, record_date ASC');

SELECT login, f_name, s_name, t_name, created_at FROM users where status = 1 and login like '%-1%' ORDER BY created_at DESC;
