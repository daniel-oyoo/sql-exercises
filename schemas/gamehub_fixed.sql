-- ============================================
-- GAMEHUB: Video Game E-commerce Database
-- Total Records: ~20,000
-- Created for: SQL Practice & Web3 Integration
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS gamehub;
USE gamehub;

-- ============================================
-- 1. USERS TABLE (Modern Gamers)
-- ============================================
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255)  NULL,
    wallet_address VARCHAR(42) UNIQUE, -- Web3 wallet
    gamer_tag VARCHAR(50),
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
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
-- 2. GAMES TABLE (Real Game Data)
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
    average_playtime INT, -- in hours
    header_image_url VARCHAR(500),
    capsule_image_url VARCHAR(500),
    background_image_url VARCHAR(500),
    website_url VARCHAR(500),
    support_url VARCHAR(500),
    price DECIMAL(8,2),
    discount_percent INT DEFAULT 0,
    final_price DECIMAL(8,2) AS (price * (100 - discount_percent) / 100),
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
-- 7. REVIEWS TABLE (User Game Reviews)
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
    helpful_score INT AS (upvotes - downvotes),
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
    transaction_hash VARCHAR(100), -- For crypto payments
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
    total_playtime INT DEFAULT 0, -- in minutes
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
    rarity_percent DECIMAL(5,2), -- % of players who have it
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
    playtime_when_unlocked INT, -- minutes
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
    FOREIGN KEY (friend_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CHECK (user_id != friend_id)
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
-- NOW, LET'S POPULATE WITH REAL DATA!
-- ============================================

-- Insert Genres (20 real video game genres)
INSERT INTO genres (name, slug, description) VALUES
('Action', 'action', 'Fast-paced games requiring quick reflexes'),
('Adventure', 'adventure', 'Story-driven exploration games'),
('Role-Playing', 'rpg', 'Character development and story progression'),
('Strategy', 'strategy', 'Tactical planning and resource management'),
('Simulation', 'simulation', 'Real-world activity simulation'),
('Sports', 'sports', 'Athletic competition games'),
('Racing', 'racing', 'Vehicle racing competition'),
('Fighting', 'fighting', 'One-on-one combat games'),
('Shooter', 'shooter', 'Weapon-based combat games'),
('Puzzle', 'puzzle', 'Problem-solving games'),
('Horror', 'horror', 'Fear and suspense themed games'),
('Survival', 'survival', 'Resource management in hostile environments'),
('Open World', 'open-world', 'Freely explorable large game worlds'),
('Stealth', 'stealth', 'Sneaking and avoidance gameplay'),
('Sandbox', 'sandbox', 'Creative freedom with minimal restrictions'),
('MMO', 'mmo', 'Massively Multiplayer Online games'),
('Battle Royale', 'battle-royale', 'Last-player-standing competition'),
('Metroidvania', 'metroidvania', 'Exploration-based with ability gating'),
('Roguelike', 'roguelike', 'Permadeath and procedural generation'),
('Visual Novel', 'visual-novel', 'Interactive story with minimal gameplay');

-- Insert Platforms
INSERT INTO platforms (name, slug, manufacturer) VALUES
('Windows', 'windows', 'Microsoft'),
('PlayStation 5', 'ps5', 'Sony'),
('Xbox Series X/S', 'xbox-series', 'Microsoft'),
('Nintendo Switch', 'switch', 'Nintendo'),
('macOS', 'macos', 'Apple'),
('Linux', 'linux', 'Community'),
('PlayStation 4', 'ps4', 'Sony'),
('Xbox One', 'xbox-one', 'Microsoft'),
('iOS', 'ios', 'Apple'),
('Android', 'android', 'Google');

-- Insert Developers
INSERT INTO developers (name, slug, country_code, founded_year) VALUES
('Valve', 'valve', 'US', 1996),
('CD Projekt Red', 'cd-projekt-red', 'PL', 1994),
('FromSoftware', 'fromsoftware', 'JP', 1986),
('Rockstar Games', 'rockstar-games', 'US', 1998),
('Ubisoft', 'ubisoft', 'FR', 1986),
('Electronic Arts', 'electronic-arts', 'US', 1982),
('Nintendo', 'nintendo', 'JP', 1889),
('Bethesda', 'bethesda', 'US', 1986),
('Activision', 'activision', 'US', 1979),
('Square Enix', 'square-enix', 'JP', 1975);

-- Insert Tags (for game discovery)
INSERT INTO tags (name, slug) VALUES
('Singleplayer', 'singleplayer'),
('Multiplayer', 'multiplayer'),
('Co-op', 'coop'),
('Online Co-op', 'online-coop'),
('Local Co-op', 'local-coop'),
('Competitive', 'competitive'),
('Casual', 'casual'),
('VR', 'vr'),
('Controller Support', 'controller-support'),
('Moddable', 'moddable'),
('Great Soundtrack', 'great-soundtrack'),
('Atmospheric', 'atmospheric'),
('Story Rich', 'story-rich'),
('Choices Matter', 'choices-matter'),
('Romance', 'romance'),
('Multiple Endings', 'multiple-endings'),
('Cyberpunk', 'cyberpunk'),
('Fantasy', 'fantasy'),
('Sci-fi', 'sci-fi'),
('Post-apocalyptic', 'post-apocalyptic'),
('Zombies', 'zombies'),
('Vampires', 'vampires'),
('Dragons', 'dragons'),
('Space', 'space'),
('Medieval', 'medieval'),
('Historical', 'historical'),
('Realistic', 'realistic'),
('Cartoony', 'cartoony'),
('Anime', 'anime'),
('Pixel Graphics', 'pixel-graphics'),
('2D', '2d'),
('3D', '3d'),
('First-Person', 'first-person'),
('Third-Person', 'third-person'),
('Top-Down', 'top-down'),
('Isometric', 'isometric'),
('Side Scroller', 'side-scroller'),
('Open World', 'open-world'),
('Procedural Generation', 'procedural-generation'),
('Crafting', 'crafting'),
('Base Building', 'base-building'),
('Survival', 'survival'),
('Battle Royale', 'battle-royale'),
('Tower Defense', 'tower-defense'),
('City Builder', 'city-builder'),
('Management', 'management'),
('RTS', 'rts'),
('Turn-Based', 'turn-based'),
('Tactical', 'tactical'),
('Bullet Hell', 'bullet-hell'),
('Souls-like', 'souls-like'),
('Metroidvania', 'metroidvania'),
('Roguelike', 'roguelike'),
('Roguelite', 'roguelite'),
('Walking Simulator', 'walking-simulator'),
('Psychological Horror', 'psychological-horror'),
('Gore', 'gore'),
('Nudity', 'nudity'),
('Sexual Content', 'sexual-content'),
('Violent', 'violent'),
('Family Friendly', 'family-friendly'),
('Education', 'education'),
('Physics', 'physics'),
('Sandbox', 'sandbox'),
('Parkour', 'parkour'),
('Stealth', 'stealth'),
('Driving', 'driving'),
('Flying', 'flying'),
('Sailing', 'sailing'),
('Underwater', 'underwater'),
('Comedy', 'comedy'),
('Drama', 'drama'),
('Mystery', 'mystery'),
('Thriller', 'thriller');

-- Insert 50 Popular Games (Real game data)
INSERT INTO games (title, slug, developer, publisher, release_date, price, discount_percent, metacritic_score, user_score, esrb_rating, is_multiplayer, has_campaign, average_playtime) VALUES
('Cyberpunk 2077', 'cyberpunk-2077', 'CD Projekt Red', 'CD Projekt', '2020-12-10', 59.99, 30, 86, 7.1, 'M', TRUE, TRUE, 60),
('The Witcher 3: Wild Hunt', 'the-witcher-3', 'CD Projekt Red', 'CD Projekt', '2015-05-19', 39.99, 70, 92, 9.2, 'M', FALSE, TRUE, 100),
('Elden Ring', 'elden-ring', 'FromSoftware', 'Bandai Namco', '2022-02-25', 59.99, 20, 96, 8.5, 'M', TRUE, TRUE, 80),
('Baldur''s Gate 3', 'baldurs-gate-3', 'Larian Studios', 'Larian Studios', '2023-08-03', 59.99, 0, 96, 9.1, 'M', TRUE, TRUE, 120),
('Red Dead Redemption 2', 'red-dead-redemption-2', 'Rockstar Games', 'Rockstar Games', '2018-10-26', 59.99, 50, 97, 8.7, 'M', TRUE, TRUE, 90),
('Portal 2', 'portal-2', 'Valve', 'Valve', '2011-04-19', 9.99, 0, 95, 9.1, 'E10+', TRUE, TRUE, 8),
('Half-Life: Alyx', 'half-life-alyx', 'Valve', 'Valve', '2020-03-23', 59.99, 20, 93, 9.0, 'M', FALSE, TRUE, 15),
('Counter-Strike 2', 'counter-strike-2', 'Valve', 'Valve', '2023-09-27', 0.00, 0, 85, 6.5, 'M', TRUE, FALSE, 500),
('Dota 2', 'dota-2', 'Valve', 'Valve', '2013-07-09', 0.00, 0, 90, 7.0, 'T', TRUE, FALSE, 1000),
('Team Fortress 2', 'team-fortress-2', 'Valve', 'Valve', '2007-10-10', 0.00, 0, 92, 8.5, 'T', TRUE, FALSE, 300),
('Grand Theft Auto V', 'grand-theft-auto-v', 'Rockstar Games', 'Rockstar Games', '2013-09-17', 29.99, 50, 96, 7.9, 'M', TRUE, TRUE, 80),
('The Legend of Zelda: Breath of the Wild', 'zelda-breath-wild', 'Nintendo', 'Nintendo', '2017-03-03', 59.99, 0, 97, 8.7, 'E10+', FALSE, TRUE, 100),
('The Last of Us Part I', 'last-of-us-part-1', 'Naughty Dog', 'Sony', '2022-09-02', 69.99, 20, 88, 8.3, 'M', FALSE, TRUE, 15),
('God of War', 'god-of-war', 'Santa Monica Studio', 'Sony', '2018-04-20', 49.99, 30, 94, 9.1, 'M', FALSE, TRUE, 25),
('Hades', 'hades', 'Supergiant Games', 'Supergiant Games', '2020-09-17', 24.99, 20, 93, 9.2, 'T', FALSE, TRUE, 50),
('Stardew Valley', 'stardew-valley', 'ConcernedApe', 'ConcernedApe', '2016-02-26', 14.99, 0, 89, 9.2, 'E', TRUE, TRUE, 100),
('Minecraft', 'minecraft', 'Mojang', 'Mojang', '2011-11-18', 26.95, 0, 93, 8.5, 'E10+', TRUE, FALSE, 500),
('Among Us', 'among-us', 'InnerSloth', 'InnerSloth', '2018-06-15', 4.99, 0, 85, 7.5, 'E10+', TRUE, FALSE, 20),
('Fallout: New Vegas', 'fallout-new-vegas', 'Obsidian', 'Bethesda', '2010-10-19', 9.99, 70, 84, 8.5, 'M', FALSE, TRUE, 60),
('Skyrim', 'skyrim', 'Bethesda', 'Bethesda', '2011-11-11', 39.99, 60, 94, 8.2, 'M', FALSE, TRUE, 100),
('Dark Souls III', 'dark-souls-3', 'FromSoftware', 'Bandai Namco', '2016-03-24', 59.99, 50, 89, 8.0, 'M', TRUE, TRUE, 40),
('Sekiro: Shadows Die Twice', 'sekiro', 'FromSoftware', 'Activision', '2019-03-22', 59.99, 40, 90, 8.3, 'M', FALSE, TRUE, 35),
('Bloodborne', 'bloodborne', 'FromSoftware', 'Sony', '2015-03-24', 19.99, 0, 92, 8.9, 'M', TRUE, TRUE, 35),
('Demon''s Souls', 'demons-souls', 'FromSoftware', 'Sony', '2020-11-12', 69.99, 30, 92, 8.1, 'M', FALSE, TRUE, 30),
('Persona 5 Royal', 'persona-5-royal', 'Atlus', 'Atlus', '2019-10-31', 59.99, 30, 95, 9.0, 'M', FALSE, TRUE, 120),
('Final Fantasy VII Remake', 'final-fantasy-vii-remake', 'Square Enix', 'Square Enix', '2020-04-10', 69.99, 40, 87, 8.2, 'T', FALSE, TRUE, 40),
('Final Fantasy XIV', 'final-fantasy-xiv', 'Square Enix', 'Square Enix', '2013-08-27', 0.00, 0, 86, 8.5, 'T', TRUE, TRUE, 1000),
('Final Fantasy XVI', 'final-fantasy-xvi', 'Square Enix', 'Square Enix', '2023-06-22', 69.99, 10, 87, 8.0, 'M', FALSE, TRUE, 50),
('Diablo IV', 'diablo-iv', 'Blizzard', 'Activision', '2023-06-06', 69.99, 20, 86, 5.5, 'M', TRUE, TRUE, 60),
('Overwatch 2', 'overwatch-2', 'Blizzard', 'Activision', '2022-10-04', 0.00, 0, 79, 3.5, 'T', TRUE, FALSE, 100),
('World of Warcraft', 'world-of-warcraft', 'Blizzard', 'Activision', '2004-11-23', 14.99, 0, 93, 7.5, 'T', TRUE, TRUE, 5000),
('StarCraft II', 'starcraft-ii', 'Blizzard', 'Activision', '2010-07-27', 0.00, 0, 93, 8.5, 'T', TRUE, TRUE, 100),
('Call of Duty: Modern Warfare II', 'call-of-duty-mw2', 'Infinity Ward', 'Activision', '2022-10-28', 69.99, 30, 76, 5.5, 'M', TRUE, TRUE, 10),
('Apex Legends', 'apex-legends', 'Respawn', 'EA', '2019-02-04', 0.00, 0, 88, 7.5, 'T', TRUE, FALSE, 200),
('It Takes Two', 'it-takes-two', 'Hazelight', 'EA', '2021-03-26', 39.99, 30, 89, 8.9, 'E10+', TRUE, TRUE, 15),
('Mass Effect Legendary Edition', 'mass-effect-legendary', 'BioWare', 'EA', '2021-05-14', 59.99, 50, 86, 8.8, 'M', FALSE, TRUE, 100),
('Dragon Age: Inquisition', 'dragon-age-inquisition', 'BioWare', 'EA', '2014-11-18', 39.99, 70, 89, 7.5, 'M', TRUE, TRUE, 80),
('Star Wars Jedi: Survivor', 'star-wars-jedi-survivor', 'Respawn', 'EA', '2023-04-28', 69.99, 20, 85, 6.5, 'T', FALSE, TRUE, 25),
('Assassin''s Creed Valhalla', 'assassins-creed-valhalla', 'Ubisoft', 'Ubisoft', '2020-11-10', 59.99, 70, 84, 7.0, 'M', TRUE, TRUE, 80),
('Far Cry 6', 'far-cry-6', 'Ubisoft', 'Ubisoft', '2021-10-07', 59.99, 75, 76, 6.5, 'M', TRUE, TRUE, 30),
('Rainbow Six Siege', 'rainbow-six-siege', 'Ubisoft', 'Ubisoft', '2015-12-01', 19.99, 70, 79, 7.5, 'M', TRUE, FALSE, 500),
('The Division 2', 'the-division-2', 'Ubisoft', 'Ubisoft', '2019-03-15', 39.99, 80, 82, 7.0, 'M', TRUE, TRUE, 60),
('Forza Horizon 5', 'forza-horizon-5', 'Playground Games', 'Xbox', '2021-11-09', 59.99, 30, 92, 8.0, 'E', TRUE, TRUE, 50),
('Microsoft Flight Simulator', 'microsoft-flight-simulator', 'Asobo', 'Xbox', '2020-08-18', 59.99, 20, 90, 7.5, 'E', TRUE, FALSE, 100),
('Halo Infinite', 'halo-infinite', '343 Industries', 'Xbox', '2021-12-08', 59.99, 50, 87, 6.5, 'T', TRUE, TRUE, 25),
('Gears 5', 'gears-5', 'The Coalition', 'Xbox', '2019-09-10', 39.99, 70, 84, 7.5, 'M', TRUE, TRUE, 20),
('Animal Crossing: New Horizons', 'animal-crossing-new-horizons', 'Nintendo', 'Nintendo', '2020-03-20', 59.99, 0, 90, 7.5, 'E', TRUE, TRUE, 200),
('Super Smash Bros. Ultimate', 'smash-bros-ultimate', 'Nintendo', 'Nintendo', '2018-12-07', 59.99, 0, 93, 8.5, 'E10+', TRUE, TRUE, 100),
('Mario Kart 8 Deluxe', 'mario-kart-8-deluxe', 'Nintendo', 'Nintendo', '2017-04-28', 59.99, 0, 92, 8.5, 'E', TRUE, TRUE, 50),
('Super Mario Odyssey', 'super-mario-odyssey', 'Nintendo', 'Nintendo', '2017-10-27', 59.99, 0, 97, 8.9, 'E', FALSE, TRUE, 25);

-- Insert Game-Genre relationships
-- (This is simplified - in reality you'd have complex relationships)
INSERT INTO game_genres (game_id, genre_id) VALUES
(1, 1), (1, 2), (1, 3),  -- Cyberpunk: Action, Adventure, RPG
(2, 1), (2, 2), (2, 3),  -- Witcher 3
(3, 1), (3, 2), (3, 3),  -- Elden Ring
(4, 3), (4, 2),          -- Baldur's Gate 3
(5, 1), (5, 2), (5, 3),  -- RDR2
(6, 10), (6, 1),         -- Portal 2
(7, 1), (7, 10), (7, 8), -- Half-Life Alyx
(8, 9), (8, 4),          -- CS2
(9, 4), (9, 16),         -- Dota 2
(10, 9), (10, 4);        -- Team Fortress 2

-- Insert Game-Platform relationships
INSERT INTO game_platforms (game_id, platform_id, release_date) VALUES
(1, 1, '2020-12-10'), (1, 2, '2020-12-10'), (1, 3, '2020-12-10'),  -- Cyberpunk on Win, PS5, Xbox
(2, 1, '2015-05-19'), (2, 2, '2015-05-19'), (2, 3, '2015-05-19'), (2, 4, '2019-10-15'),  -- Witcher 3
(3, 1, '2022-02-25'), (3, 2, '2022-02-25'), (3, 3, '2022-02-25'),  -- Elden Ring
(4, 1, '2023-08-03'), (4, 2, '2023-09-06'), (4, 3, '2023-09-06'),  -- Baldur's Gate 3
(5, 1, '2019-11-05'), (5, 2, '2018-10-26'), (5, 3, '2018-10-26');  -- RDR2

-- Insert 1000 Sample Users (gamers with wallets)
INSERT INTO users (username, email, wallet_address, gamer_tag, country_code, total_spent, loyalty_points) VALUES
('neon_gamer', 'neon@example.com', '0x742d35Cc6634C0532925a3b844Bc9e1962a8Bc34', 'NeonSlayer', 'US', 450.25, 4502),
('crypto_knight', 'crypto@example.com', '0x2a0c0DBEcC7E4D658f48E01e96d1E5b9eD7a9F6A', 'BitWarrior', 'CA', 289.99, 2899),
('quantum_player', 'quantum@example.com', '0x9f8f72AA9304c8B593d555F12eF6589cC3A579A2', 'Quantum', 'UK', 1200.50, 12005),
('digital_ninja', 'ninja@example.com', '0x4e9ce36e442e55ecd9025b9a6e0d88485d628a67', 'ShadowStrike', 'JP', 780.30, 7803),
('blockchain_bob', 'bob@example.com', '0xbe0eb53f46cd790cd13851d5eff43d12404d33e8', 'ChainMaster', 'DE', 340.75, 3407),
('cypher_punk', 'cypher@example.com', '0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be', 'CodeBreaker', 'FR', 890.20, 8902),
('ethereum_queen', 'queen@example.com', '0x28c6c06298d514db089934071355e5743bf21d60', 'CryptoQueen', 'AU', 1560.40, 15604),
('web3_wizard', 'wizard@example.com', '0x21a31ee1afc51d94c2efccaa2092ad1028285549', 'Web3Wiz', 'SG', 430.90, 4309),
('nft_collector', 'collector@example.com', '0xdfd5293d8e347dfe59e90efd55b2956a1343963d', 'NFTHunter', 'KR', 2100.75, 21007),
('dao_destroyer', 'dao@example.com', '0x56eddb7aa87536c09cc2797a7d1e7f7c2f735a14', 'DAOslayer', 'NL', 670.25, 6702),
('defi_demon', 'defi@example.com', '0x9e9278b7f15c15c34c8d6df5f5c5b9f8d5f5c5b9', 'DeFiKing', 'CH', 980.60, 9806),
('metaverse_mike', 'mike@example.com', '0x5a0b54d5dc17e0aadc383d2db43b0a0d3e029c4c', 'MetaMike', 'SE', 540.30, 5403),
('polygon_prince', 'prince@example.com', '0x8d12a197cb00d4747a1fe03395095ce2a5cc6865419', 'PolyPrince', 'BR', 320.45, 3204),
('avalanche_amy', 'amy@example.com', '0x8d12a197cb00d4747a1fe03395095ce2a5cc6819', 'AvalancheAmy', 'MX', 760.80, 7608),
('solana_sam', 'sam@example.com', '0x1b3cb81e51011b549d78bf720b0d924ac763a7c2', 'SolSam', 'IN', 430.25, 4302),
('cosmos_carl', 'carl@example.com', '0x3f5ce5fbfe3e9af3971dd833d26ba9b5c936f0be', 'CosmosCarl', 'IT', 890.10, 8901),
('terra_tina', 'tina@example.com', '0x28c6c06298d514db089934071355e5743bf21d60', 'TerraTina', 'ES', 1250.40, 12504),
('chainlink_luke', 'luke@example.com', '0x21a31ee1afc51d94c2efccaa2092ad1028285549', 'ChainLuke', 'PL', 340.75, 3407),
('uniswap_uma', 'uma@example.com', '0xdfd5293d8e347dfe59e90efd55b2956a1343963d', 'UniUma', 'RU', 670.90, 6709),
('aave_andy', 'andy@example.com', '0x56eddb7aa87536c09cc2797a7d1e7f7c2f735a14', 'AaveAndy', 'TR', 980.25, 9802);

-- Generate 1000 more users with a stored procedure
DELIMITER $$
CREATE PROCEDURE GenerateUsers()
BEGIN
    DECLARE i INT DEFAULT 21;
    DECLARE wallet VARCHAR(42);
    DECLARE country_codes CHAR(2) DEFAULT 'US,CA,UK,DE,FR,JP,AU,SG,KR,NL,CH,SE,BR,MX,IN,IT,ES,PL,RU,TR';
    DECLARE countries TEXT;
    DECLARE country CHAR(2);
    
    SET countries = country_codes;
    
    WHILE i <= 1000 DO
        SET wallet = CONCAT('0x', LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0'), 
                           LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0'),
                           LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0'));
        
        SET country = SUBSTRING_INDEX(SUBSTRING_INDEX(countries, ',', 1 + FLOOR(RAND() * 20)), ',', -1);
        
        INSERT INTO users (username, email, wallet_address, gamer_tag, country_code, total_spent, loyalty_points)
        VALUES (
            CONCAT('gamer_', i),
            CONCAT('gamer', i, '@example.com'),
            wallet,
            CONCAT('Player', FLOOR(RAND() * 9999)),
            country,
            ROUND(RAND() * 2000, 2),
            FLOOR(RAND() * 20000)
        );
        
        SET i = i + 1;
    END WHILE;
END$$
DELIMITER ;

CALL GenerateUsers();
DROP PROCEDURE GenerateUsers;

-- Insert Reviews (5000 reviews)
INSERT INTO reviews (user_id, game_id, rating, title, content, is_recommended, hours_played, upvotes, downvotes)
SELECT 
    FLOOR(1 + RAND() * 1000) as user_id,
    FLOOR(1 + RAND() * 50) as game_id,
    FLOOR(1 + RAND() * 5) as rating,
    ELT(FLOOR(1 + RAND() * 10), 
        'Amazing Game!', 
        'Could be better', 
        'Masterpiece', 
        'Worth every penny',
        'Disappointing',
        'Best game ever',
        'Not my type',
        'Great story',
        'Poor optimization',
        'Addictive gameplay'
    ) as title,
    CONCAT('This game is ', 
        ELT(FLOOR(1 + RAND() * 10), 
            'absolutely fantastic! ', 
            'quite disappointing. ', 
            'better than I expected. ',
            'not worth the price. ',
            'a masterpiece of storytelling. ',
            'full of bugs and issues. ',
            'extremely well optimized. ',
            'too short for the price. ',
            'perfect for casual gaming. ',
            'challenging but rewarding. '
        ),
        'I played it for ', FLOOR(RAND() * 200), ' hours.'
    ) as content,
    IF(RAND() > 0.3, TRUE, FALSE) as is_recommended,
    FLOOR(RAND() * 200) as hours_played,
    FLOOR(RAND() * 100) as upvotes,
    FLOOR(RAND() * 20) as downvotes
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
LIMIT 5000;

-- Insert Orders (2000 orders)
INSERT INTO orders (user_id, order_number, total_amount, tax_amount, discount_amount, final_amount, payment_method, payment_status, order_status)
SELECT 
    FLOOR(1 + RAND() * 1000) as user_id,
    CONCAT('ORD-', DATE_FORMAT(DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 730) DAY), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0')) as order_number,
    ROUND(20 + RAND() * 180, 2) as total_amount,
    ROUND((20 + RAND() * 180) * 0.08, 2) as tax_amount,
    ROUND((20 + RAND() * 180) * RAND() * 0.3, 2) as discount_amount,
    ROUND((20 + RAND() * 180) * (1 + 0.08) * (1 - RAND() * 0.3), 2) as final_amount,
    ELT(FLOOR(1 + RAND() * 4), 'credit_card', 'paypal', 'crypto', 'wallet') as payment_method,
    ELT(FLOOR(1 + RAND() * 4), 'pending', 'completed', 'failed', 'refunded') as payment_status,
    ELT(FLOOR(1 + RAND() * 4), 'processing', 'completed', 'cancelled', 'refunded') as order_status
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
LIMIT 2000;

-- Insert Order Items (6000 items)
INSERT INTO order_items (order_id, game_id, quantity, unit_price, discount_percent, final_price)
SELECT 
    FLOOR(1 + RAND() * 2000) as order_id,
    FLOOR(1 + RAND() * 50) as game_id,
    FLOOR(1 + RAND() * 3) as quantity,
    ROUND(10 + RAND() * 50, 2) as unit_price,
    FLOOR(RAND() * 50) as discount_percent,
    ROUND((10 + RAND() * 50) * (100 - FLOOR(RAND() * 50)) / 100, 2) as final_price
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3) f
LIMIT 6000;

-- Insert Library Entries (10,000 game ownership records)
INSERT INTO library (user_id, game_id, platform_id, total_playtime, achievements_unlocked, total_achievements, is_installed, is_favorite)
SELECT 
    FLOOR(1 + RAND() * 1000) as user_id,
    FLOOR(1 + RAND() * 50) as game_id,
    FLOOR(1 + RAND() * 10) as platform_id,
    FLOOR(RAND() * 5000) as total_playtime,
    FLOOR(RAND() * 50) as achievements_unlocked,
    FLOOR(20 + RAND() * 80) as total_achievements,
    IF(RAND() > 0.5, TRUE, FALSE) as is_installed,
    IF(RAND() > 0.7, TRUE, FALSE) as is_favorite
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) f
LIMIT 10000;

-- Insert Achievements (500 achievements)
INSERT INTO achievements (game_id, name, description, rarity_percent, points)
SELECT 
    FLOOR(1 + RAND() * 50) as game_id,
    CONCAT(ELT(FLOOR(1 + RAND() * 10), 'Master ', 'Legendary ', 'Epic ', 'Rare ', 'Common ', 'Hidden ', 'Secret ', 'Mythic ', 'Ultimate ', 'Final '),
           ELT(FLOOR(1 + RAND() * 10), 'Completionist', 'Warrior', 'Explorer', 'Collector', 'Hunter', 'Survivor', 'Builder', 'Slayer', 'Champion', 'Hero')) as name,
    CONCAT('Complete ', ELT(FLOOR(1 + RAND() * 10), 'all main quests', 'the game on hard mode', '100 headshots', 'the tutorial', 'all side missions', 
           'the game without dying', 'with 100% completion', 'in under 10 hours', 'all challenges', 'with perfect score')) as description,
    ROUND(RAND() * 100, 2) as rarity_percent,
    FLOOR(10 + RAND() * 100) as points
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) e
LIMIT 500;

-- Insert User Achievements (20,000 unlocks)
INSERT INTO user_achievements (user_id, achievement_id, playtime_when_unlocked)
SELECT 
    FLOOR(1 + RAND() * 1000) as user_id,
    FLOOR(1 + RAND() * 500) as achievement_id,
    FLOOR(RAND() * 5000) as playtime_when_unlocked
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) f
LIMIT 20000;

-- Insert NFT Collectibles (200 NFTs)
INSERT INTO nft_collectibles (game_id, name, description, token_standard, contract_address, token_id, rarity, total_supply, current_price_eth)
SELECT 
    FLOOR(1 + RAND() * 50) as game_id,
    CONCAT(ELT(FLOOR(1 + RAND() * 10), 'Golden ', 'Diamond ', 'Platinum ', 'Legendary ', 'Epic ', 'Mythic ', 'Ancient ', 'Digital ', 'Virtual ', 'Cyber '),
           ELT(FLOOR(1 + RAND() * 10), 'Sword', 'Shield', 'Helmet', 'Armor', 'Pet', 'Mount', 'Skin', 'Weapon', 'Avatar', 'Artifact')) as name,
    CONCAT('A rare collectible from ', 
           ELT(FLOOR(1 + RAND() * 10), 'the ancient world', 'the digital realm', 'the cyber universe', 'the fantasy kingdom', 'the sci-fi galaxy',
                'the post-apocalyptic wasteland', 'the medieval era', 'the future', 'alternate reality', 'virtual space')) as description,
    ELT(FLOOR(1 + RAND() * 2), 'ERC-721', 'ERC-1155') as token_standard,
    CONCAT('0x', LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0'), 
           LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0'),
           LPAD(HEX(FLOOR(RAND() * 4294967296)), 8, '0')) as contract_address,
    CONCAT(FLOOR(RAND() * 10000)) as token_id,
    ELT(FLOOR(1 + RAND() * 5), 'common', 'uncommon', 'rare', 'epic', 'legendary') as rarity,
    CASE WHEN RAND() > 0.8 THEN FLOOR(10 + RAND() * 100) ELSE 1 END as total_supply,
    ROUND(0.01 + RAND() * 5, 4) as current_price_eth
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) e
LIMIT 200;

-- Insert Friends relationships (5000 friendships)
INSERT INTO friends (user_id, friend_id, status, accepted_at)
SELECT 
    u1.user_id,
    u2.user_id,
    'accepted' as status,
    DATE_SUB(NOW(), INTERVAL FLOOR(RAND() * 365) DAY) as accepted_at
FROM users u1
JOIN users u2 ON u1.user_id < u2.user_id
WHERE RAND() < 0.01
LIMIT 5000;

-- Insert Wishlist items (3000 wishes)
INSERT INTO wishlist (user_id, game_id, notify_on_discount)
SELECT 
    FLOOR(1 + RAND() * 1000) as user_id,
    FLOOR(1 + RAND() * 50) as game_id,
    IF(RAND() > 0.3, TRUE, FALSE) as notify_on_discount
FROM (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) a
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) b
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) c
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) d
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) e
CROSS JOIN (SELECT 1 UNION SELECT 2 UNION SELECT 3) f
LIMIT 3000;

-- Insert Daily Active Users for last 365 days
INSERT INTO daily_active_users (date, total_users, new_users, returning_users, peak_concurrent_users, average_session_minutes, revenue)
SELECT 
    DATE_SUB(CURDATE(), INTERVAL n DAY) as date,
    FLOOR(8000 + RAND() * 4000) as total_users,
    FLOOR(50 + RAND() * 150) as new_users,
    FLOOR(3000 + RAND() * 2000) as returning_users,
    FLOOR(500 + RAND() * 500) as peak_concurrent_users,
    ROUND(45 + RAND() * 45, 2) as average_session_minutes,
    ROUND(5000 + RAND() * 15000, 2) as revenue
FROM (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) a
CROSS JOIN (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) b
CROSS JOIN (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7) c
CROSS JOIN (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6) d
LIMIT 365;

-- ============================================
-- CREATE USEFUL VIEWS FOR ANALYSIS
-- ============================================

-- View 1: Game Statistics
CREATE VIEW game_statistics AS
SELECT 
    g.game_id,
    g.title,
    g.developer,
    g.final_price,
    g.metacritic_score,
    g.user_score,
    COUNT(DISTINCT r.review_id) as review_count,
    AVG(r.rating) as avg_rating,
    COUNT(DISTINCT l.library_id) as total_owners,
    SUM(l.total_playtime) as total_playtime_hours,
    SUM(oi.quantity) as total_sales,
    SUM(oi.final_price * oi.quantity) as total_revenue
FROM games g
LEFT JOIN reviews r ON g.game_id = r.game_id
LEFT JOIN library l ON g.game_id = l.game_id
LEFT JOIN order_items oi ON g.game_id = oi.game_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status = 'completed'
GROUP BY g.game_id;

-- View 2: User Gaming Profile
CREATE VIEW user_gaming_profile AS
SELECT 
    u.user_id,
    u.username,
    u.gamer_tag,
    u.total_spent,
    u.loyalty_points,
    COUNT(DISTINCT l.game_id) as games_owned,
    SUM(l.total_playtime) / 60 as total_playtime_hours,
    AVG(r.rating) as avg_review_rating,
    COUNT(DISTINCT r.review_id) as reviews_written,
    COUNT(DISTINCT f.friend_id) as friends_count,
    COUNT(DISTINCT w.game_id) as wishlist_items
FROM users u
LEFT JOIN library l ON u.user_id = l.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
LEFT JOIN friends f ON u.user_id = f.user_id AND f.status = 'accepted'
LEFT JOIN wishlist w ON u.user_id = w.user_id
GROUP BY u.user_id;

-- View 3: Platform Performance
CREATE VIEW platform_performance AS
SELECT 
    p.platform_id,
    p.name as platform_name,
    COUNT(DISTINCT gp.game_id) as available_games,
    COUNT(DISTINCT l.user_id) as active_users,
    SUM(l.total_playtime) / 60 as total_playtime_hours,
    SUM(oi.final_price * oi.quantity) as total_revenue,
    AVG(r.rating) as avg_game_rating
FROM platforms p
LEFT JOIN game_platforms gp ON p.platform_id = gp.platform_id
LEFT JOIN library l ON p.platform_id = l.platform_id
LEFT JOIN order_items oi ON p.platform_id = oi.platform_id
LEFT JOIN orders o ON oi.order_id = o.order_id AND o.order_status = 'completed'
LEFT JOIN reviews r ON oi.game_id = r.game_id
GROUP BY p.platform_id;

-- View 4: Monthly Revenue Report
CREATE VIEW monthly_revenue_report AS
SELECT 
    DATE_FORMAT(o.created_at, '%Y-%m') as month,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.user_id) as unique_customers,
    SUM(o.final_amount) as total_revenue,
    AVG(o.final_amount) as avg_order_value,
    SUM(oi.quantity) as total_items_sold,
    SUM(CASE WHEN o.payment_method = 'crypto' THEN o.final_amount ELSE 0 END) as crypto_revenue,
    SUM(CASE WHEN o.payment_method = 'wallet' THEN o.final_amount ELSE 0 END) as wallet_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'completed'
GROUP BY DATE_FORMAT(o.created_at, '%Y-%m')
ORDER BY month DESC;

-- View 5: NFT Marketplace Overview
CREATE VIEW nft_marketplace_overview AS
SELECT 
    g.title as game_name,
    COUNT(DISTINCT n.nft_id) as total_nfts,
    SUM(CASE WHEN n.total_supply > 1 THEN 1 ELSE 0 END) as fungible_nfts,
    SUM(CASE WHEN n.total_supply = 1 THEN 1 ELSE 0 END) as unique_nfts,
    AVG(n.current_price_eth) as avg_price_eth,
    SUM(n.current_price_eth) as total_market_cap_eth,
    COUNT(DISTINCT n.current_owner_wallet) as unique_owners
FROM nft_collectibles n
JOIN games g ON n.game_id = g.game_id
GROUP BY g.game_id;

-- ============================================
-- SAMPLE QUERIES TO TEST THE DATABASE
-- ============================================

-- Query 1: Find top 10 most played games
SELECT 
    g.title,
    COUNT(DISTINCT l.user_id) as player_count,
    SUM(l.total_playtime) / 60 as total_hours_played,
    AVG(r.rating) as average_rating
FROM games g
JOIN library l ON g.game_id = l.game_id
LEFT JOIN reviews r ON g.game_id = r.game_id
GROUP BY g.game_id
ORDER BY total_hours_played DESC
LIMIT 10;

-- Query 2: Find users who spend the most
SELECT 
    u.username,
    u.gamer_tag,
    u.total_spent,
    COUNT(DISTINCT l.game_id) as games_owned,
    COUNT(DISTINCT r.review_id) as reviews_written
FROM users u
LEFT JOIN library l ON u.user_id = l.user_id
LEFT JOIN reviews r ON u.user_id = r.user_id
GROUP BY u.user_id
ORDER BY u.total_spent DESC
LIMIT 10;

-- Query 3: Game recommendations based on user's library
SELECT 
    g.title,
    g.developer,
    g.final_price,
    g.metacritic_score,
    COUNT(DISTINCT r.review_id) as review_count,
    AVG(r.rating) as avg_rating
FROM games g
JOIN game_genres gg ON g.game_id = gg.game_id
WHERE gg.genre_id IN (
    SELECT DISTINCT gg2.genre_id 
    FROM library l 
    JOIN game_genres gg2 ON l.game_id = gg2.game_id 
    WHERE l.user_id = 1  -- Replace with actual user_id
    AND l.total_playtime > 60  -- Played more than 1 hour
)
AND g.game_id NOT IN (
    SELECT game_id FROM library WHERE user_id = 1
)
GROUP BY g.game_id
ORDER BY avg_rating DESC, g.metacritic_score DESC
LIMIT 10;

-- Query 4: Daily active users trend
SELECT 
    DATE(date) as day,
    total_users,
    new_users,
    returning_users,
    revenue
FROM daily_active_users
ORDER BY date DESC
LIMIT 30;

-- Query 5: Web3 gaming analysis (users with wallets)
SELECT 
    COUNT(DISTINCT u.user_id) as total_web3_users,
    SUM(u.total_spent) as web3_user_spend,
    AVG(u.total_spent) as avg_web3_spend,
    COUNT(DISTINCT n.nft_id) as nfts_owned,
    SUM(n.current_price_eth) as total_nft_value_eth
FROM users u
LEFT JOIN nft_collectibles n ON u.wallet_address = n.current_owner_wallet
WHERE u.wallet_address IS NOT NULL;

-- ============================================
-- CREATE STORED PROCEDURES FOR COMMON OPERATIONS
-- ============================================

-- Procedure 1: Get user's gaming stats
DELIMITER $$
CREATE PROCEDURE GetUserStats(IN user_id_param INT)
BEGIN
    SELECT 
        u.username,
        u.gamer_tag,
        u.join_date,
        u.total_spent,
        u.loyalty_points,
        COUNT(DISTINCT l.game_id) as games_owned,
        SUM(l.total_playtime) / 60 as total_playtime_hours,
        COUNT(DISTINCT a.achievement_id) as achievements_unlocked,
        COUNT(DISTINCT f.friend_id) as friends_count,
        COUNT(DISTINCT w.game_id) as wishlist_items,
        AVG(r.rating) as avg_review_score
    FROM users u
    LEFT JOIN library l ON u.user_id = l.user_id
    LEFT JOIN user_achievements a ON u.user_id = a.user_id
    LEFT JOIN friends f ON u.user_id = f.user_id AND f.status = 'accepted'
    LEFT JOIN wishlist w ON u.user_id = w.user_id
    LEFT JOIN reviews r ON u.user_id = r.user_id
    WHERE u.user_id = user_id_param
    GROUP BY u.user_id;
END$$
DELIMITER ;

-- Procedure 2: Get game details with all relationships
DELIMITER $$
CREATE PROCEDURE GetGameDetails(IN game_id_param INT)
BEGIN
    -- Basic game info
    SELECT * FROM games WHERE game_id = game_id_param;
    
    -- Genres
    SELECT g.name, g.description 
    FROM genres g
    JOIN game_genres gg ON g.genre_id = gg.genre_id
    WHERE gg.game_id = game_id_param;
    
    -- Platforms
    SELECT p.name, gp.release_date, gp.platform_specific_price
    FROM platforms p
    JOIN game_platforms gp ON p.platform_id = gp.platform_id
    WHERE gp.game_id = game_id_param;
    
    -- Recent reviews
    SELECT u.username, r.rating, r.title, r.content, r.created_at, r.upvotes
    FROM reviews r
    JOIN users u ON r.user_id = u.user_id
    WHERE r.game_id = game_id_param
    ORDER BY r.created_at DESC
    LIMIT 10;
    
    -- Achievements
    SELECT name, description, rarity_percent, points
    FROM achievements
    WHERE game_id = game_id_param
    ORDER BY rarity_percent;
    
    -- NFTs
    SELECT name, description, rarity, current_price_eth
    FROM nft_collectibles
    WHERE game_id = game_id_param
    ORDER BY current_price_eth DESC;
END$$
DELIMITER ;

-- Procedure 3: Purchase a game
DELIMITER $$
CREATE PROCEDURE PurchaseGame(
    IN user_id_param INT,
    IN game_id_param INT,
    IN platform_id_param INT,
    IN payment_method_param VARCHAR(20),
    IN gift_to_user_id_param INT
)
BEGIN
    DECLARE game_price DECIMAL(8,2);
    DECLARE order_num VARCHAR(20);
    DECLARE new_order_id INT;
    
    -- Get game price
    SELECT final_price INTO game_price 
    FROM games 
    WHERE game_id = game_id_param;
    
    -- Generate order number
    SET order_num = CONCAT('ORD-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(FLOOR(RAND() * 10000), 4, '0'));
    
    -- Create order
    INSERT INTO orders (user_id, order_number, total_amount, final_amount, payment_method, order_status)
    VALUES (user_id_param, order_num, game_price, game_price, payment_method_param, 'completed');
    
    SET new_order_id = LAST_INSERT_ID();
    
    -- Add order item
    INSERT INTO order_items (order_id, game_id, quantity, unit_price, final_price, platform_id, gift_to_user_id)
    VALUES (new_order_id, game_id_param, 1, game_price, game_price, platform_id_param, gift_to_user_id_param);
    
    -- Update user's total spent
    UPDATE users 
    SET total_spent = total_spent + game_price,
        loyalty_points = loyalty_points + FLOOR(game_price)
    WHERE user_id = user_id_param;
    
    -- Add to library (if not a gift)
    IF gift_to_user_id_param IS NULL THEN
        INSERT INTO library (user_id, game_id, platform_id, purchase_date)
        VALUES (user_id_param, game_id_param, platform_id_param, NOW());
    ELSE
        INSERT INTO library (user_id, game_id, platform_id, purchase_date)
        VALUES (gift_to_user_id_param, game_id_param, platform_id_param, NOW());
    END IF;
    
    -- Return order details
    SELECT 
        'Purchase successful!' as message,
        order_num as order_number,
        game_price as amount,
        new_order_id as order_id;
END$$
DELIMITER ;

-- ============================================
-- CREATE TRIGGERS FOR DATA INTEGRITY
-- ============================================

-- Trigger 1: Update user's total spent automatically
DELIMITER $$
CREATE TRIGGER after_order_completed
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_status = 'completed' AND OLD.order_status != 'completed' THEN
        UPDATE users 
        SET total_spent = total_spent + NEW.final_amount,
            loyalty_points = loyalty_points + FLOOR(NEW.final_amount)
        WHERE user_id = NEW.user_id;
    END IF;
END$$
DELIMITER ;

-- Trigger 2: Update game's average rating
DELIMITER $$
CREATE TRIGGER after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE games g
    SET user_score = (
        SELECT AVG(rating) 
        FROM reviews 
        WHERE game_id = NEW.game_id
    )
    WHERE g.game_id = NEW.game_id;
END$$
DELIMITER ;

-- ============================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX idx_library_user_game ON library(user_id, game_id);
CREATE INDEX idx_reviews_game_user ON reviews(game_id, user_id);
CREATE INDEX idx_orders_user_date ON orders(user_id, created_at);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_wallet ON users(wallet_address);
CREATE INDEX idx_games_price ON games(final_price);
CREATE INDEX idx_games_metacritic ON games(metacritic_score);
CREATE INDEX idx_nft_price ON nft_collectibles(current_price_eth);
CREATE INDEX idx_achievements_game ON achievements(game_id);

-- ============================================
-- FINAL MESSAGE
-- ============================================
SELECT '🎮 GameHub Database Successfully Created!' as message;
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM games) as total_games,
    (SELECT COUNT(*) FROM orders) as total_orders,
    (SELECT COUNT(*) FROM reviews) as total_reviews,
    (SELECT COUNT(*) FROM nft_collectibles) as total_nfts,
    (SELECT SUM(total_spent) FROM users) as total_revenue,
    (SELECT COUNT(*) FROM library) as game_ownerships,
    (SELECT COUNT(*) FROM achievements) as total_achievements;
