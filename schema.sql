-- Add your database schema definitions (CREATE TABLE statements) here
-- Tables from steam (category, company,game_company game, game_category, game_genre, game_language, game_tag, genre, language, tag)

-- USERS
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    date_of_birth DATE NULL,
    join_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bio TEXT NULL, 
    profile_image VARCHAR(500) NULL,
    username VARCHAR(50) MPT NULL;
)

-- CONSTRAINTS
ALTER TABLE users
ADD CONSTRAINT pk_users PRIMARY KEY (id),
ADD CONSTRAINT uq_users_email UNIQUE (email),
ADD CONSTRAINT uq_users_username UNIQUE (username);

-- WALLET
CREATE TABLE wallet (
    user_id BIGINT UNSIGNED NOT NULL,
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    currency CHAR(3) NOT NULL DEFAULT 'USD';
)

-- CONSTRAINTS
ALTER TABLE wallet
    ADD CONSTRAINT pk_wallet PRIMARY KEY (user_id),
    ADD CONSTRAINT fk_wallet_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT chk_wallet_balance CHECK (balance >= 0);

-- LIBRARY
CREATE TABLE library (
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL;
)

-- CONSTRAINTS
ALTER TABLE library 
    ADD CONSTRAINTS pk_library PRIMARY KEY(id),
    ADD CONSTRAINTS uq_library_user UNIQUE (user_id),
    ADD CONSTRAINTS fk_library_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- LIBARY GAME
CREATE TABLE library_game (
    library_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    purchase_price DECIMAL(10,2) NOT NULL,
    purchase_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
)

-- CONSTRAINTS
ALTER TABLE library_game
    ADD CONSTRAINT pk_library_game PRIMARY KEY (library_id, game_id),
    ADD CONSTRAINT fk_library_game_library FOREIGN KEY (library_id)
        REFERENCES library(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_library_game_game FOREIGN KEY (game_id)
        REFERENCES game(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT chk_library_game_purchase_price CHECK (purchase_price >= 0),
    ADD INDEX idx_library_game_pruchase_date (library_id, purchase_date);

-- WISHLIST
CREATE TABLE wishlist (
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
)
-- CONSTRAINTS
ALTER TABLE wishlist 
    ADD CONSTRAINT pk_wishlist PRIMARY KEY (id),
    ADD CONSTRAINT uq_wishlist_user UNIQUE (user_id),
    ADD CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- WISHLIST_GAME
CREATE TABLE wishlist_game (
    wishlist_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    position INT UNSIGNED NOT NULL,
    date_added DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
)
-- CONSTRAINTS
ALTER TABLE wishlist_game 
    ADD CONSTRAINT pk_wishlist_game PRIMARY KEY (wishlist_id, game_id),
    ADD CONSTRAINT uq_wishlist_game_user_position UNIQUE (wishlist_id, position),
    ADD CONSTRAINT fk_wishlist_game_wishlist FOREIGN KEY (wishlist_id)
        REFERENCES wishlist(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_wishlist_game_game FOREIGN KEY (game_id)
        REFERENCES game(id) ON DELETE CASCADE ON UPDATE CASCADE;
    ADD CONSTRAINT chk_wishlist_game_position CHECK (position > 0);

-- SESSION
CREATE TABLE 'session' 
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    start_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time DATETIME NULL;

-- CONSTRAINTS
ALTER TABLE 'session'
    ADD CONSTRAINT pk_session PRIMARY KEY (id),
    ADD CONSTRAINT fk_session_user FOREIGN KEY (user_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_session_game FOREIGN KEY (game_id)
        REFERENCES game(id) ON DELETE RESTRICT ON UPDATE CASCADE, 
    ADD CONSTRAINT chk_session_times CHECK (end_time IS NULL OR end_time >= start_time);
    ADD INDEX idx_session_user_game (user_id, game_id)
    ADD INDEX idx_session_user_start (user_id, start_time);

-- REVIEWS
CREATE TABLE reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    reccomended BOOLEAN NOT NULL,
    comment TEXT NULL,
    date_created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
)

-- CONSTRAINTS
ALTER TABLE reviews (
    ADD CONSTRAINT pk_reviews PRIMARY KEY (id),
    ADD CONSTRAINT uq_reviews_user_game UNIQUE (user_id, game_id),
    ADD CONSTRAINT fk_reviews_user FOREIGN KEY (user_id),
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE, 
    ADD CONSTRAINT fk_reviews_game FOREIGN KEY (game_id)
        REFERENCES game(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD INDEX idx_reviews_game_date (game_id, date_created);
)

-- REVIEW VOTE
CREATE TABLE review_vote (
    review_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    vote ENUM('helpful', 'unhelpful') NOT NULL;
)
-- CONSTRAINTS
ALTER TABLE review_vote
    ADD CONSTRAINT pk_review_vote PRIMARY KEY (review_id, user_id),
    ADD CONSTRAINT fk_review_vote_review FOREIGN KEY (review_id)
        REFERENCES reviews(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_review_vote_user FOREIGN KEY (user_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE;

-- REVIEW COMMENT
CREATE TABLE review_comment
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    review_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    comment_text TEXT NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- CONSTRAINTS
ALTER TABKE review_comment
    ADD CONSTRAINT pk_review_comment PRIMARY KEY (id),
    ADD CONSTRAINT fk_review_comment_review FOREIGN KEY (review_id)
        REFERENCES reviews(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_review_comment_user FOREIGN KEY (user_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE, 
    ADD INDEX idx_review_commemt_revoew_created (review_id, created_at);

-- FRIEND_REQUEST
CREATE TABLE friend_request (
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    sender_id BIGINT UNSIGNED NOT NULL,
    reciever_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM ('pending', 'accepted', 'declined') NOT NULL DEFAULT 'pending',
    sent_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    response_date DATETIME NULL;
)

-- CONSTRAINTS
alter TABLE friend_request 
    ADD CONSTRAINT pk_friend_request PRIMARY KEY (id),
    ADD CONSTRAINT fk_friend_request_sender FOREIGN KEY (sender_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_friend_request_reciever FOREIGN KEY (reciever_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT uq_friend_request_pair UNIQUE (sender_id, reciever_id),
    ADD CONSTRAINT chk_friend_request_not_self CHECK (sender_id <> reciever_id),
    ADD CONSTRAINT chk_friend_request_response CHECK (
        (status = 'pending' AND response_date IS NULL) OR (status IN ('accepted', 'declined') AND response_date IS NOT NULL)),
    ADD INDEX idx_friend_request_receiver_status (reciever_id, status);

-- FRIENDS
CREATE TABLE friends (
    id BIGINT UNSIGNED AUTO_INCREMENT NOT NULL,
    user_id_1 BIGINT UNSIGNED NOT NULL,
    user_id_2 BIGINT UNSIGNED NOT NULL,
    friends_since DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
)

-- CONSTRAINTS
ALTER TABLE friends 
    ADD CONSTRAINT pk_friends PRIMARY KRY (id),
    ADD CONSTRAINT uq_friends_pair UNIQUE (user_id_1, user_id_2),
    ADD CONSTRAINT fk_friends_users_1 FOREIGN KEY (user_id_1)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_friends_user_2 FOREIGN KEY (user_id_2)
        REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT chk_friends_distinct_users CHECK (user_id_1 < user_id_2);

-- USER GAME TAG
CREATE TABLE user_game_tag (
    user_id BIGINT UNSIGNED NOT NULL,
    game_id BIGINT UNSIGNED NOT NULL,
    tag_id INT UNSIGNED NOT NULL;
)

-- CONSTRAINTS

ALTER TABLE user_game_tag 
    ADD CONSTRAINT pk_user_game_tag PRIMARY KEY (user_id, game_id, tag_id),
    ADD CONSTRAINT fk_user_game_tag_user FOREIGN KEY (user_id)
        REFERENCES user(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_user_game_tag_game FOREIGN KEY (game_id)
        REFERENCES game(id) ON DELETE CASCADE ON UPDATE CASCADE,
    ADD CONSTRAINT fk_user_game_tag_tag FOREIGN KEY (tag_id)
        REFERENCES tag(id) ON DELETE CASCADE ON UPDATE CASCADE;
    
-- Add any necessary indexes, constraints, or relationships between tables

-- Add your roles, an example user for each role, and their permissions


-- You are NOT required to add the schema for the tables provided to you in the
-- starting database.
