::#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Пары пользователей, оценивших один и тот же фильм (без дубликатов и самих себя). Первые 100 записей."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT DISTINCT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id LIMIT 100;"
echo ""

echo "2. 10 самых свежих оценок от разных пользователей (название фильма, имя, оценка, дата ГГГГ-ММ-ДД)."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, strftime('%Y-%m-%d', datetime(r.timestamp, 'unixepoch')) AS date FROM ratings r JOIN users u ON r.user_id = u.id JOIN movies m ON r.movie_id = m.id ORDER BY r.timestamp DESC LIMIT 10;"
echo ""

echo "3. Фильмы с максимальным и минимальным средним рейтингом (колонка 'Рекомендуем': Да/Нет)."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH movie_avg AS (SELECT m.title, m.year, AVG(r.rating) AS avg_rat FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year) SELECT title, year, ROUND(avg_rat, 2) AS avg_rating, CASE WHEN avg_rat = (SELECT MAX(avg_rat) FROM movie_avg) OR avg_rat = (SELECT MIN(avg_rat) FROM movie_avg) THEN 'Да' ELSE 'Нет' END AS Рекомендуем FROM movie_avg WHERE avg_rat = (SELECT MAX(avg_rat) FROM movie_avg) OR avg_rat = (SELECT MIN(avg_rat) FROM movie_avg) ORDER BY year, title;"
echo ""

echo "4. Количество оценок и средняя оценка, поставленная женщинами с 2010 по 2012 год."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.rating) AS total_ratings, ROUND(AVG(r.rating), 2) AS avg_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'F' AND strftime('%Y', datetime(r.timestamp, 'unixepoch')) BETWEEN '2010' AND '2012';"
echo ""

echo "5. Список фильмов со средним рейтингом и местом в рейтинге по средней оценке. Первые 20 записей."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, ROUND(AVG(r.rating), 2) AS avg_rating, DENSE_RANK() OVER (ORDER BY AVG(r.rating) DESC) AS rank FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ORDER BY avg_rating DESC, m.year, m.title LIMIT 20;"
echo ""

echo "6. 10 последних зарегистрированных пользователей (в формате 'Фамилия Имя|Дата регистрации')."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT SUBSTR(name, INSTR(name, ' ') + 1) || ' ' || SUBSTR(name, 1, INSTR(name, ' ') - 1) || '|' || register_date AS user_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo ""

echo "7. Таблица умножения от 1 до 10 с помощью рекурсивного CTE (один столбец)."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE mult(i, j) AS (SELECT 1, 1 UNION ALL SELECT CASE WHEN j < 10 THEN i ELSE i + 1 END, CASE WHEN j < 10 THEN j + 1 ELSE 1 END FROM mult WHERE i < 10 OR j < 10) SELECT i || 'x' || j || '=' || (i * j) AS table_row FROM mult;"
echo ""

echo "8. Выделить все жанры фильмов в отдельные строки с помощью рекурсивного CTE."
echo ---------------------------------------------------------------------------------------------------------------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split(id, title, genre, rest) AS (SELECT id, title, '', genres || '|' FROM movies UNION ALL SELECT id, title, SUBSTR(rest, 1, INSTR(rest, '|') - 1), SUBSTR(rest, INSTR(rest, '|') + 1) FROM split WHERE rest != '') SELECT DISTINCT genre FROM split WHERE genre != '' ORDER BY genre;"
echo ""