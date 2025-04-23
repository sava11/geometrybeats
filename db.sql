-- DATABASE: GeometryBeatDB
DROP DATABASE IF EXISTS geometrybeatdb;
CREATE DATABASE IF NOT EXISTS geometrybeatdb;

USE geometrybeatdb;

CREATE TABLE users (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(128) NOT NULL,
    password CHAR(64) NOT NULL
);

CREATE TABLE user_level_records (
    record_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED NOT NULL,
    points INT UNSIGNED NOT NULL DEFAULT 0,
    collected INT UNSIGNED NOT NULL DEFAULT 0,
    no_hit TINYINT(1) NOT NULL DEFAULT 0,
    record_date DATETIME NOT NULL,
    level_id INT NOT NULL,
    FOREIGN KEY (user_id) 
    REFERENCES users(id)
    ON DELETE CASCADE,
    INDEX (user_id)
);

DELIMITER //

CREATE FUNCTION get_user_points(uid INT)
RETURNS JSON
DETERMINISTIC
BEGIN
    DECLARE total_points INT DEFAULT 0;
    
    SELECT SUM(points) INTO total_points
    FROM user_level_records
    WHERE user_id = uid;

    RETURN JSON_OBJECT(
        'total_points', total_points
    );
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE get_user_level_attempts(
    IN in_user_id    INT,
    IN in_level_id   INT,
    IN in_sort_cols  VARCHAR(255)  -- сюда передаём имя(ена) столбцов с опциональным направлением: "points DESC, record_date ASC"
)
BEGIN
    -- Проверка, что sort_cols не пустой
    IF TRIM(in_sort_cols) = '' THEN
        SET in_sort_cols = 'record_date DESC';
    END IF;

    -- Формируем динамический SQL
    SET @sql = CONCAT(
        'SELECT',
        '   points,',
        '   collected,',
        '   no_hit,',
        '   record_date',
        ' FROM user_level_records',
        ' WHERE user_id = ',      in_user_id,
        '   AND level_id = ',     in_level_id,
        ' ORDER BY ',             in_sort_cols,
        ';'
    );

    -- Подготовка и выполнение запроса
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END;
//

DELIMITER ;


INSERT INTO users (login, password) VALUES 
("saver", SHA1('ssss')),
("saver1", SHA1('ssss'));

SELECT * FROM users;

INSERT INTO user_level_records(user_id, record_date, level_id, points, collected, no_hit) VALUES
(1, "2025-01-01", 1, 2, 0, 0),
(2, "2025-01-01", 1, 2, 0, 0),
(1, "2025-02-01", 1, 10, 0, 1),
(1, now(), 1, 2, 0, 0);

SELECT 
    level_id, 
    points, 
    collected,
    no_hit,
    record_date
FROM user_level_records 
WHERE user_id = 1
ORDER BY record_date DESC;

SELECT
    MAX(points)   AS max_points,
    MAX(collected) AS max_collected
FROM user_level_records
WHERE user_id = 1       -- подставьте нужный ID пользователя
GROUP BY level_id
ORDER BY level_id;

CALL get_user_level_attempts(1, 1, 'points DESC, record_date ASC');


