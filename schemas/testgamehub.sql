-- Test the database
USE gamehub;
SHOW TABLES;

-- Quick queries
SELECT * FROM games;
SELECT * FROM users LIMIT 5;
SELECT * FROM game_details;

-- Practice joins
SELECT u.username, g.title, l.total_playtime
FROM users u
JOIN library l ON u.user_id = l.user_id
JOIN games g ON l.game_id = g.game_id;

-- Aggregation
SELECT genre_id, COUNT(*) as game_count
FROM game_genres
GROUP BY genre_id
ORDER BY game_count DESC;