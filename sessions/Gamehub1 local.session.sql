-- 1. See all games with prices
SELECT title, developer, price, metacritic_score 
FROM games 
ORDER BY price DESC;