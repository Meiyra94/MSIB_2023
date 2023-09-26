-- 3. create table students for school database, consist these columns:
    -- id (integer, PK, auto increment)
    -- first_name (varchar, not null)
    -- last_name (varchar, default null)
    -- email (varchar, unique, not null)
    -- age (integer, default value 18)
    -- gender (varchar, check constraint to allow only 'male' or 'female')
    -- date_of_birth (date, not null)
    -- created_at (timestamp with time zone, default value now)

CREATE DATABASE school;

CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) DEFAULT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    age INT DEFAULT 18,
    gender VARCHAR(6) CHECK (gender IN ('male', 'female')),
    date_of_birth DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SHOW tables;
 +------------------+
 | Tables_in_school |
 +------------------+
 | students         |
 +------------------+

DESC students;
+---------------+--------------+------+-----+---------------------+----------------+
| Field         | Type         | Null | Key | Default             | Extra          |
+---------------+--------------+------+-----+---------------------+----------------+
| id            | int(11)      | NO   | PRI | NULL                | auto_increment |
| first_name    | varchar(255) | NO   |     | NULL                |                |
| last_name     | varchar(255) | YES  |     | NULL                |                |
| email         | varchar(255) | NO   | UNI | NULL                |                |
| age           | int(11)      | YES  |     | 18                  |                |
| gender        | varchar(6)   | YES  |     | NULL                |                |
| date_of_birth | date         | NO   |     | NULL                |                |
| created_at    | timestamp    | NO   |     | current_timestamp() |                |
+---------------+--------------+------+-----+---------------------+----------------+
8 rows in set (0.079 sec)

-- 4. Use movie dataset and create stored procedure or function for counting movie based on genre. Use genre as a parameter, and return the count of movie.
         DELIMITER //
         CREATE FUNCTION Movies_Genre(p_genre VARCHAR(255)) RETURNS INT
         BEGIN
         DECLARE genre_count INT;
         
         SELECT COUNT(*) INTO genre_count
         FROM movie
         WHERE FIND_IN_SET(p_genre, genre) > 0;
         RETURN genre_count;
         END //
         DELIMITER ;

         SELECT Movies_Genre('Action');


-- 5. Use movie dataset, write one optimized query (using the tips for revamp query). You are free to create any query.
        SELECT movie.movie_genres, AVG(rating.rating) AS avg_rating
        FROM movie AS m
        JOIN rating AS r ON movie.mov_id = rating.mov_id
        WHERE movie.mov_dt_rel = 2023
        GROUP BY movie.movie_genres
        ORDER BY avg_rating DESC;

        SELECT
    m.mov_title AS movie_title,
    g.gen_title AS genre,
    AVG(r.rating) AS average_rating,
    COUNT(r.rating) AS num_ratings
FROM movie m
JOIN movie_genres mg ON m.mov_id = mg.mov_id
JOIN genres g ON mg.gen_id = g.gen_id
LEFT JOIN ratings r ON m.mov_id = r.mov_id
GROUP BY m.mov_id, m.mov_title, g.gen_title
ORDER BY AVG(r.rating) DESC NULLS LAST;

-- Dipakai
    SELECT
    m.mov_title AS movie_title,
    g.gen_title AS genre
    FROM movie m
    JOIN movie_genres mg ON m.mov_id = mg.mov_id
    JOIN genres g ON mg.gen_id = g.gen_id
    WHERE g.gen_title = 'Adventure';

-- 6. Use the ninja dataset, write a query that return nama and desa, use email as a filter. Create a proper index to satisfy the query, provide the explain result before and after index creation. (do set enable_seqscan = off first)
-- 7. Find the most favorite (highest rating) for each genre (use rank() window function)
WITH RankedMovies AS (
  SELECT
    m.mov_id,
    m.mov_title,
    g.gen_title AS genre,
    rating,
    RANK() OVER(PARTITION BY g.gen_title ORDER BY r.rating DESC) AS ranking
  FROM
    movie m
    JOIN movie_genres mg ON m.mov_id = mg.mov_id
    JOIN genres g ON mg.gen_id = g.gen_id
    JOIN rating r ON m.mov_id = r.mov_id
)

SELECT mov_id, mov_title, genre, rating
FROM RankedMovies
WHERE ranking = 1;


-- Contoh 2
WITH RankedMovies AS (
    SELECT
        mov_id,
        genres,
        rating,
        RANK() OVER (PARTITION BY genres ORDER BY rating DESC) AS ranking
    FROM
        movie
)
SELECT
    mov_id,
    genres,
    rating
FROM
    RankedMovies
WHERE
    ranking = 1;

-- Contoh 3
WITH RankedMovies AS (
    SELECT
        mov_id,
        genres,
        title,
        rating,
        RANK() OVER (PARTITION BY genre ORDER BY rating DESC) AS ranking
    FROM
        movie
)
SELECT
    mov_id,
    genres,
    title,
    rating
FROM
    RankedMovies
WHERE
    ranking = 1;

-- Contoh 4
WITH RankedMovies AS (
    SELECT
        m.mov_id,
        m.mov_title,
        m.gen_id,
        m.rating,
        g.gen_title,
        RANK() OVER (PARTITION BY m.gen_id ORDER BY m.rating DESC) AS ranking
    FROM
        movie AS m
    JOIN
        genres AS g ON m.gen_id = g.id
)
SELECT
    rm.mov_id,
    rm.mov_title,
    rm.gen_title,
    rm.rating
FROM
    RankedMovies AS rm
WHERE
    rm.ranking = 1;



-- -- Run the query with the index and explain the query plan
EXPLAIN ANALYZE
SELECT nama, desa
FROM ninja
WHERE email = 'example@email.com';
-- Create an index on the "email" column
CREATE INDEX idx_email ON ninja (email);