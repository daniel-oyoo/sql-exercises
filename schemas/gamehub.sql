-- ============================================
-- GAMEHUB: Video Game E-commerce Database
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS gamehub;
USE gamehub;

-- Disable strict mode for import
SET SESSION sql_mode = 'NO_ENGINE_SUBSTITUTION';

-- ============================================
-- 1. USERS TABLE (Modern Gamers) - FIXED
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) DEFAULT NULL,
    wallet_address VARCHAR(42) UNIQUE,
    gamer_tag VARCHAR(50),
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    total_spent DECIMAL(10,2) DEFAULT 0.00,
    loyalty_points INT DEFAULT 0,
    profile_image_url VARCHAR(255),
    country_code CHAR(2),
    is_verified BOOLEAN DEFAULT FALSE,
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    INDEX idx_email (email),
    INDEX idx_wallet (wallet_address)
);

-- ============================================
-- 2. GAMES TABLE (Real Game Data) - FIXED
-- ============================================
CREATE TABLE games (
    game_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) UNIQUE NOT NULL,
    developer VARCHAR(100),
    publisher VARCHAR(100),
    release_date DATE,
    description TEXT,
    short_description VARCHAR(500),
    metacritic_score INT,
    user_score DECIMAL(3,1),
    esrb_rating ENUM('E', 'E10+', 'T', 'M', 'A', 'RP') DEFAULT 'RP',
    is_multiplayer BOOLEAN DEFAULT FALSE,
    has_campaign BOOLEAN DEFAULT TRUE,
    average_playtime INT,
    header_image_url VARCHAR(500),
    capsule_image_url VARCHAR(500),
    background_image_url VARCHAR(500),
    website_url VARCHAR(500),
    support_url VARCHAR(500),
    price DECIMAL(8,2),
    discount_percent INT DEFAULT 0,
    final_price DECIMAL(8,2) GENERATED ALWAYS AS (price * (100 - discount_percent) / 100) STORED,
    is_early_access BOOLEAN DEFAULT FALSE,
    is_free BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_title (title),
    INDEX idx_developer (developer),
    INDEX idx_price (final_price),
    INDEX idx_release (release_date),
    FULLTEXT idx_search (title, description, short_description)
);

-- ============================================
-- 3. GENRES TABLE
-- ============================================
CREATE TABLE genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    icon_url VARCHAR(255)
);

-- ============================================
-- 4. PLATFORMS TABLE
-- ============================================
CREATE TABLE platforms (
    platform_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    icon_url VARCHAR(255),
    manufacturer VARCHAR(50)
);

-- ============================================
-- 5. GAME_GENRES (Many-to-Many)
-- ============================================
CREATE TABLE game_genres (
    game_id INT,
    genre_id INT,
    PRIMARY KEY (game_id, genre_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE CASCADE
);

-- ============================================
-- 6. GAME_PLATFORMS (Many-to-Many)
-- ============================================
CREATE TABLE game_platforms (
    game_id INT,
    platform_id INT,
    release_date DATE,
    platform_specific_price DECIMAL(8,2),
    PRIMARY KEY (game_id, platform_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id) ON DELETE CASCADE
);

-- ============================================
-- 7. REVIEWS TABLE (User Game Reviews) - FIXED
-- ============================================
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    rating TINYINT CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200),
    content TEXT,
    is_recommended BOOLEAN,
    hours_played INT,
    upvotes INT DEFAULT 0,
    downvotes INT DEFAULT 0,
    helpful_score INT GENERATED ALWAYS AS (upvotes - downvotes) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_edited BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_game (user_id, game_id),
    INDEX idx_game_rating (game_id, rating),
    INDEX idx_user_reviews (user_id, created_at)
);

-- ============================================
-- 8. ORDERS TABLE (Purchases)
-- ============================================
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    tax_amount DECIMAL(10,2) DEFAULT 0.00,
    discount_amount DECIMAL(10,2) DEFAULT 0.00,
    final_amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) DEFAULT 'USD',
    payment_method ENUM('credit_card', 'paypal', 'crypto', 'wallet') DEFAULT 'credit_card',
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_hash VARCHAR(100),
    shipping_address TEXT,
    billing_address TEXT,
    order_status ENUM('processing', 'completed', 'cancelled', 'refunded') DEFAULT 'processing',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user_orders (user_id, created_at),
    INDEX idx_order_status (order_status),
    INDEX idx_order_date (created_at)
);

-- ============================================
-- 9. ORDER_ITEMS TABLE
-- ============================================
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    game_id INT,
    quantity INT DEFAULT 1,
    unit_price DECIMAL(8,2) NOT NULL,
    discount_percent INT DEFAULT 0,
    final_price DECIMAL(8,2) NOT NULL,
    platform_id INT,
    gift_to_user_id INT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id),
    FOREIGN KEY (gift_to_user_id) REFERENCES users(user_id),
    INDEX idx_order_items (order_id, game_id)
);

-- ============================================
-- 10. LIBRARY TABLE (User's Game Collection)
-- ============================================
CREATE TABLE library (
    library_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    platform_id INT,
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_played TIMESTAMP NULL,
    total_playtime INT DEFAULT 0,
    achievements_unlocked INT DEFAULT 0,
    total_achievements INT DEFAULT 0,
    is_installed BOOLEAN DEFAULT FALSE,
    is_favorite BOOLEAN DEFAULT FALSE,
    play_status ENUM('not_started', 'playing', 'completed', 'abandoned') DEFAULT 'not_started',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id),
    UNIQUE KEY unique_user_game_platform (user_id, game_id, platform_id),
    INDEX idx_user_library (user_id, purchase_date),
    INDEX idx_game_popularity (game_id)
);

-- ============================================
-- 11. ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE achievements (
    achievement_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(255),
    rarity_percent DECIMAL(5,2),
    points INT DEFAULT 0,
    secret BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    INDEX idx_game_achievements (game_id)
);

-- ============================================
-- 12. USER_ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE user_achievements (
    user_id INT,
    achievement_id INT,
    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    playtime_when_unlocked INT,
    PRIMARY KEY (user_id, achievement_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (achievement_id) REFERENCES achievements(achievement_id) ON DELETE CASCADE
);

-- ============================================
-- 13. NFT_COLLECTIBLES (Web3 Integration)
-- ============================================
CREATE TABLE nft_collectibles (
    nft_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    animation_url VARCHAR(500),
    token_standard ENUM('ERC-721', 'ERC-1155') DEFAULT 'ERC-721',
    contract_address VARCHAR(42),
    token_id VARCHAR(100),
    rarity ENUM('common', 'uncommon', 'rare', 'epic', 'legendary') DEFAULT 'common',
    total_supply INT DEFAULT 1,
    current_owner_wallet VARCHAR(42),
    current_price_eth DECIMAL(10,4),
    last_sale_price_eth DECIMAL(10,4),
    last_sale_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    INDEX idx_nft_game (game_id),
    INDEX idx_nft_owner (current_owner_wallet),
    INDEX idx_nft_rarity (rarity)
);

-- ============================================
-- 14. FRIENDS TABLE (Social Features)
-- ============================================
CREATE TABLE friends (
    user_id INT,
    friend_id INT,
    status ENUM('pending', 'accepted', 'blocked') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    accepted_at TIMESTAMP NULL,
    PRIMARY KEY (user_id, friend_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================
-- 15. WISHLIST TABLE
-- ============================================
CREATE TABLE wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    game_id INT,
    added_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    desired_price DECIMAL(8,2) NULL,
    notify_on_discount BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_wishlist (user_id, game_id),
    INDEX idx_user_wishlist (user_id, added_date)
);

-- ============================================
-- 16. TAGS TABLE (For Game Discovery)
-- ============================================
CREATE TABLE tags (
    tag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) UNIQUE NOT NULL,
    slug VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    usage_count INT DEFAULT 0
);

-- ============================================
-- 17. GAME_TAGS (Many-to-Many)
-- ============================================
CREATE TABLE game_tags (
    game_id INT,
    tag_id INT,
    PRIMARY KEY (game_id, tag_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- ============================================
-- 18. DEVELOPERS TABLE
-- ============================================
CREATE TABLE developers (
    developer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    logo_url VARCHAR(500),
    website_url VARCHAR(500),
    founded_year INT,
    country_code CHAR(2),
    employee_count_range VARCHAR(50)
);

-- ============================================
-- 19. GAME_DEVELOPERS (Many-to-Many)
-- ============================================
CREATE TABLE game_developers (
    game_id INT,
    developer_id INT,
    role ENUM('primary', 'support', 'publisher') DEFAULT 'primary',
    PRIMARY KEY (game_id, developer_id),
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (developer_id) REFERENCES developers(developer_id) ON DELETE CASCADE
);

-- ============================================
-- 20. SYSTEM_REQUIREMENTS
-- ============================================
CREATE TABLE system_requirements (
    requirement_id INT PRIMARY KEY AUTO_INCREMENT,
    game_id INT,
    platform_id INT,
    requirement_type ENUM('minimum', 'recommended') NOT NULL,
    os VARCHAR(100),
    processor VARCHAR(200),
    memory VARCHAR(50),
    graphics VARCHAR(200),
    storage VARCHAR(50),
    directx_version VARCHAR(20),
    network VARCHAR(100),
    additional_notes TEXT,
    FOREIGN KEY (game_id) REFERENCES games(game_id) ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES platforms(platform_id) ON DELETE CASCADE,
    UNIQUE KEY unique_game_platform_type (game_id, platform_id, requirement_type)
);

-- ============================================
-- 21. DAILY_ACTIVE_USERS (Analytics)
-- ============================================
CREATE TABLE daily_active_users (
    date DATE PRIMARY KEY,
    total_users INT DEFAULT 0,
    new_users INT DEFAULT 0,
    returning_users INT DEFAULT 0,
    peak_concurrent_users INT DEFAULT 0,
    average_session_minutes DECIMAL(5,2) DEFAULT 0.00,
    revenue DECIMAL(10,2) DEFAULT 0.00
);

-- ============================================
-- INSERT DATA
-- ============================================

-- Insert Genres (reduced to avoid errors)
INSERT INTO genres (name, slug) VALUES
('Action', 'action'),
('Adventure', 'adventure'),
('RPG', 'rpg'),
('Strategy', 'strategy'),
('Shooter', 'shooter'),
('Sports', 'sports'),
('Racing', 'racing'),
('Puzzle', 'puzzle'),
('Horror', 'horror'),
('Simulation', 'simulation');

-- Insert Platforms
INSERT INTO platforms (name, slug) VALUES
('Windows', 'windows'),
('PlayStation 5', 'ps5'),
('Xbox Series X', 'xbox-series'),
('Nintendo Switch', 'switch'),
('macOS', 'macos');

-- Insert Developers
INSERT INTO developers (name, slug) VALUES
('Valve', 'valve'),
('CD Projekt Red', 'cd-projekt-red'),
('FromSoftware', 'fromsoftware'),
('Rockstar Games', 'rockstar-games'),
('Ubisoft', 'ubisoft');

-- Insert 10 Games (simplified)
INSERT INTO games (title, slug, developer, price, metacritic_score, esrb_rating) VALUES
('Cyberpunk 2077', 'cyberpunk-2077', 'CD Projekt Red', 59.99, 86, 'M'),
('The Witcher 3', 'the-witcher-3', 'CD Projekt Red', 39.99, 92, 'M'),
('Elden Ring', 'elden-ring', 'FromSoftware', 59.99, 96, 'M'),
('Red Dead Redemption 2', 'red-dead-2', 'Rockstar Games', 59.99, 97, 'M'),
('Portal 2', 'portal-2', 'Valve', 9.99, 95, 'E10+'),
('Assassin''s Creed Valhalla', 'ac-valhalla', 'Ubisoft', 59.99, 84, 'M'),
('Dark Souls III', 'dark-souls-3', 'FromSoftware', 59.99, 89, 'M'),
('Grand Theft Auto V', 'gta-v', 'Rockstar Games', 29.99, 96, 'M'),
('Half-Life: Alyx', 'half-life-alyx', 'Valve', 59.99, 93, 'M'),
('Hades', 'hades', 'Supergiant Games', 24.99, 93, 'T');

-- Insert 20 Users (with unique wallet addresses)
INSERT INTO users (username, email, wallet_address, gamer_tag, country_code) VALUES
('player1', 'p1@test.com', '0x1111111111111111111111111111111111111111', 'Gamer1', 'US'),
('player2', 'p2@test.com', '0x2222222222222222222222222222222222222222', 'Gamer2', 'UK'),
('player3', 'p3@test.com', '0x3333333333333333333333333333333333333333', 'Gamer3', 'CA'),
('player4', 'p4@test.com', '0x4444444444444444444444444444444444444444', 'Gamer4', 'AU'),
('player5', 'p5@test.com', '0x5555555555555555555555555555555555555555', 'Gamer5', 'DE'),
('player6', 'p6@test.com', '0x6666666666666666666666666666666666666666', 'Gamer6', 'FR'),
('player7', 'p7@test.com', '0x7777777777777777777777777777777777777777', 'Gamer7', 'JP'),
('player8', 'p8@test.com', '0x8888888888888888888888888888888888888888', 'Gamer8', 'KR'),
('player9', 'p9@test.com', '0x9999999999999999999999999999999999999999', 'Gamer9', 'BR'),
('player10', 'p10@test.com', '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'Gamer10', 'MX');

-- Insert Game-Genre relationships
INSERT INTO game_genres (game_id, genre_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 3),
(4, 1), (4, 2),
(5, 8), (5, 2);

-- Insert Game-Platform relationships
INSERT INTO game_platforms (game_id, platform_id) VALUES
(1, 1), (1, 2), (1, 3),
(2, 1), (2, 2), (2, 3),
(3, 1), (3, 2), (3, 3);

-- Insert Reviews
INSERT INTO reviews (user_id, game_id, rating, content) VALUES
(1, 1, 5, 'Amazing game!'),
(2, 1, 4, 'Great but buggy at launch'),
(3, 2, 5, 'Masterpiece'),
(4, 3, 5, 'Best RPG ever'),
(5, 4, 5, 'Incredible story'),
(6, 5, 5, 'Perfect puzzle game'),
(1, 3, 4, 'Very challenging but rewarding'),
(2, 4, 5, 'Wild West masterpiece');

-- Insert Orders
INSERT INTO orders (user_id, order_number, total_amount, final_amount, payment_method, payment_status, order_status) VALUES
(1, 'ORD-20240115-0001', 59.99, 59.99, 'credit_card', 'completed', 'completed'),
(2, 'ORD-20240116-0002', 39.99, 39.99, 'paypal', 'completed', 'completed'),
(3, 'ORD-20240117-0003', 59.99, 59.99, 'crypto', 'completed', 'completed');

-- Insert Order Items
INSERT INTO order_items (order_id, game_id, unit_price, final_price) VALUES
(1, 1, 59.99, 59.99),
(2, 2, 39.99, 39.99),
(3, 3, 59.99, 59.99);

-- Insert Library entries
INSERT INTO library (user_id, game_id, platform_id, total_playtime) VALUES
(1, 1, 1, 1500),
(1, 3, 1, 2500),
(2, 2, 1, 3200),
(3, 3, 1, 1800);

-- Insert Achievements
INSERT INTO achievements (game_id, name, description, rarity_percent) VALUES
(1, 'Night City Legend', 'Complete all main quests', 25.5),
(1, 'Cyber Warrior', 'Defeat 100 enemies', 45.2),
(2, 'Master Witcher', 'Complete the game on Death March', 15.8),
(3, 'Elden Lord', 'Defeat the final boss', 30.1);

-- Insert User Achievements
INSERT INTO user_achievements (user_id, achievement_id) VALUES
(1, 1),
(1, 2),
(3, 4);

-- ============================================
-- SIMPLE VIEWS (No complex aggregations)
-- ============================================

-- View 1: Game Details
CREATE VIEW game_details AS
SELECT g.game_id, g.title, g.developer, g.final_price, g.metacritic_score,
       GROUP_CONCAT(DISTINCT gen.name) as genres
FROM games g
LEFT JOIN game_genres gg ON g.game_id = gg.game_id
LEFT JOIN genres gen ON gg.genre_id = gen.genre_id
GROUP BY g.game_id;

-- View 2: User Library Summary
CREATE VIEW user_library_summary AS
SELECT u.username, COUNT(l.game_id) as games_owned, 
       SUM(l.total_playtime) as total_playtime_minutes
FROM users u
LEFT JOIN library l ON u.user_id = l.user_id
GROUP BY u.user_id;

-- ============================================
-- FINAL MESSAGE
-- ============================================
SELECT '✅ GameHub Database Created Successfully!' as message;
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM games) as total_games,
    (SELECT COUNT(*) FROM genres) as total_genres,
    (SELECT COUNT(*) FROM reviews) as total_reviews;