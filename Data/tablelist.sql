-- CREATE DATABASE --

drop database if exists footballdb;
create database footballdb;
\c footballdb  
SET datestyle = 'dmy';
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
 -- last updated on 24/4/2024


-- CREATE TABLES --

CREATE TABLE nation
(
    nation_id VARCHAR(6) PRIMARY KEY,
    nation_name VARCHAR(255) NOT NULL,
    continent VARCHAR(255) NOT NULL,
    organization VARCHAR             -- last updated on 7/5/2024
);

CREATE TABLE league         
(
    league_id VARCHAR(6) PRIMARY KEY,
    league_name VARCHAR(255) NOT NULL,
    formula VARCHAR(255) NOT NULL,
    website VARCHAR(255) NOT NULL,
    nation_id VARCHAR(6) REFERENCES nation(nation_id)
);

CREATE TABLE league_organ  -- last updated on 14/5/2024
(
    season_id VARCHAR(10) PRIMARY KEY,
    league_id VARCHAR(6)  REFERENCES league(league_id) NOT NULL,
    season VARCHAR(10) NOT NULL,  
    date_start DATE,
    date_end DATE
    --  (EPL2324, EL0001, 2023-2024, 11/8/2023, 19/5/2024)
    --  (LALIGA2324, SL0001, 2023-2024, 11/8/2023, 26/5/2023)
    --  (SERIA2324, IL0001, 2023-2024, 19/8/2023, 26/5/2024)
    --  (BUNDES2324, GL0001, 2023-2024, 18/8/2023, 18/5/2024)
);

CREATE TABLE club
(
    club_id VARCHAR(3) PRIMARY KEY,
    club_name VARCHAR(255) NOT NULL,
    home_kit VARCHAR(255) NOT NULL,
    away_kit VARCHAR(255) NOT NULL,
    website VARCHAR(255) NOT NULL
);
CREATE INDEX club_name_idx ON club USING hash (club_name);   -- last updated on 1/6/2024


CREATE TABLE match     -- last updated on 14/5/2024
(
    match_id INT SERIAL PRIMARY KEY,
    season_id VARCHAR(10) REFERENCES league_organ(season_id),  
    round VARCHAR(255),
    date_of_match DATE NOT NULL,
    stadium VARCHAR(255) NOT NULL,
    referee VARCHAR(255) NOT NULL
);

CREATE TABLE home 
(
    match_id INT  REFERENCES match(match_id) ON DELETE CASCADE,
    club_id VARCHAR(3) REFERENCES club(club_id) ,
    ball_possession INT NOT NULL,
    num_of_goals INT NOT NULL,
    total_shots INT NOT NULL,
    shots_on_target INT NOT NULL,
    corner_kicks INT NOT NULL,
    offsides INT NOT NULL,
    fouls INT NOT NULL,
    penalties INT,
    PRIMARY KEY (match_id)
);
-- create index on home (club_id), home (match_id)

CREATE TABLE away 
(
    match_id INT REFERENCES match(match_id) ON DELETE CASCADE,
    club_id VARCHAR(3) REFERENCES club(club_id) ,
    ball_possession INT NOT NULL,
    num_of_goals INT,
    total_shots INT NOT NULL,
    shots_on_target INT NOT NULL,
    corner_kicks INT NOT NULL,
    offsides INT NOT NULL,
    fouls INT NOT NULL,
    penalties INT,
    PRIMARY KEY (match_id)
);
-- create index on home (club_id), home (match_id)

-- last updated on 7/6/2024: create trigger to check that home table needs to be updated before away table
CREATE OR REPLACE FUNCTION check_match()
RETURNS TRIGGER AS $$
BEGIN
        IF NOT EXISTS (SELECT match_id FROM home WHERE home.match_id = NEW.match_id) THEN
            RAISE EXCEPTION 'Home table needs to be inserted first'
            USING HINT = 'Please insert data into home table first';
        END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_check_match
BEFORE INSERT ON away 
FOR EACH ROW
EXECUTE FUNCTION check_match();

--last updated on 1/5/2024: create trigger to calculate ball possession
CREATE OR REPLACE FUNCTION calculate_ball_possession()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ball_possession = 100 - (SELECT ball_possession FROM home WHERE home.match_id = NEW.match_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_calculate_ball_possession
BEFORE INSERT ON away
FOR EACH ROW
EXECUTE FUNCTION calculate_ball_possession();



CREATE TABLE player_profile
(
    player_id VARCHAR(6) PRIMARY KEY,
    player_name VARCHAR(255) NOT NULL,
    date_of_birth DATE NOT NULL,
    nation_id VARCHAR(6) REFERENCES nation(nation_id),
    height INT NOT NULL,
    freferred_foot CHAR NOT NULL CHECK (freferred_foot IN ('L', 'R'))
);

CREATE TABLE player_role
(
    season_id VARCHAR(10) REFERENCES league_organ(season_id),
    player_id VARCHAR(6) REFERENCES player_profile(player_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    shirt_number INT NOT NULL,
    position VARCHAR(3) NOT NULL,
    contract_duration DATE,
    PRIMARY KEY (player_id, club_id, season_id)
);

CREATE TABLE squad
(  
    match_id INT REFERENCES match(match_id),
    player_id	VARCHAR(6) REFERENCES player_profile(player_id),
    time_in INT CHECK (time_in >= 0 AND time_in <= 90),	
    time_out  INT CHECK (time_out >= 0 AND time_out <= 90),
    yellow card	CHECK (yellow_card IN (0, 1)),
    red card INT CHECK (red_card IN (0, 1)),
    rating INT CHECK (rating >= 0 AND rating <= 10)

);


CREATE TABLE manager
(
    manager_id VARCHAR(20) PRIMARY KEY,
    manager_name VARCHAR(255) NOT NULL,
    age INT NOT NULL
);

CREATE TABLE management
(
    club_id VARCHAR(3) REFERENCES club(club_id),
    manager_id VARCHAR(20) REFERENCES manager(manager_id),
    year INT NOT NULL,
    PRIMARY KEY (club_id, manager_id)
);

CREATE TABLE coaching
(
    match_id INT REFERENCES match(match_id),
    manager_id VARCHAR(20) REFERENCES manager(manager_id),
    yellow_cards INT,
    red_card INT,
    PRIMARY KEY (match_id, manager_id)
);



-- CREATE VIEWS --
-- last updated on 27/4/2024 

-- VIEW FOR SEEN MATCH RESULT

-- last updated on 11/6/2024: create view to seen match result
CREATE MATERIALIZED VIEW match_result AS
SELECT 
    match.match_id,
    home.club_id AS home_team,  
    home.num_of_goals AS home_score,
    away.club_id AS away_team,
    away.num_of_goals AS away_score
FROM match
INNER JOIN home ON match.match_id = home.match_id
INNER JOIN away ON match.match_id = away.match_id;

CREATE INDEX match_result_idx ON match_result(match_id, home_team, away_team);


-- VIEW FOR SEEN TABLE STATS

-- last updated on 2/6/2024: create function for statistic some datad
CREATE OR REPLACE FUNCTION calculate_point(var_club_id VARCHAR(3), var_season_id VARCHAR(20))
RETURNS INT AS $$
DECLARE point INT;
BEGIN
    SELECT 
        SUM(CASE 
            WHEN match_result.home_score > match_result.away_score THEN 3
            WHEN match_result.home_score = match_result.away_score THEN 1
            ELSE 0
        END)
    INTO point
    FROM match_result
    INNER JOIN match on match_result.match_id = match.match_id
    WHERE match.season_id = var_season_id 
    AND match_result.home_team = var_club_id OR  match_result.away_team = var_club_id ;
    RETURN point;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_goal_diff(var_club_id VARCHAR(3), var_season_id VARCHAR(20))
RETURNS INT AS $$
DECLARE goal_diff INT;
BEGIN
    SELECT 
        (SUM(match_result.home_score) - SUM(match_result.away_score))
    INTO goal_diff
    FROM match_result
    INNER JOIN match on match_result.match_id = match.match_id
    WHERE match.season_id = var_season_id 
    AND match_result.home_team = var_club_id OR  match_result.away_team = var_club_id ;
    RETURN goal_diff;
END;
$$ LANGUAGE plpgsql;

CREATE MATERIALIZED VIEW table_stat AS
SELECT 
    calculate_goal_diff



-- CREATE RABLE TO MANAGE PERMISSION FOR ADMINS AND GUESTS
-- last updated on 8/6/2024
CREATE ROLE admin;
-- all permissions2
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

CREATE ROLE guest;
-- read-only permissions
GRANT SELECT ON ALL TABLES IN SCHEMA public TO guest;

CREATE TABLE admins 
(
    admin_id SERIAL PRIMARY KEY,
    fullnames VARCHAR(50) NOT NULL,
    username VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL
);
CREATE INDEX admins_idx ON admins (username);

CREATE TABLE guests 
(
    guest_id SERIAL PRIMARY KEY,
    fullnames VARCHAR(50),
    username VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL
);
CREATE INDEX guests_idx ON guests (username);

-- trigger to grant permissions 
CREATE OR REPLACE FUNCTION grant_permissions()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'admins' THEN
        GRANT admin TO NEW.username;
    ELSIF TG_TABLE_NAME = 'guests' THEN
        GRANT guest TO NEW.username;
    END IF;
END;

CREATE OR REPLACE FUNCTION grant_permissions()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_TABLE_NAME = 'admins' THEN
        EXECUTE 'GRANT admin TO "' || NEW.username || '";';
    ELSIF TG_TABLE_NAME = 'guests' THEN
        EXECUTE 'GRANT guest TO "' || NEW.username || '";';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger to hash password
CREATE OR REPLACE FUNCTION hash_password()
RETURNS TRIGGER AS $$
BEGIN
    NEW.password = crypt(NEW.password, gen_salt('sha256'));
    RETURN NEW;
END;

CREATE OR REPLACE TRIGGER trigger_hash_password_for_admins
BEFORE INSERT OR UPDATE ON admins
FOR EACH ROW
EXECUTE FUNCTION hash_password();

CREATE OR REPLACE TRIGGER trigger_hash_password_for_guests
BEFORE INSERT OR UPDATE ON guests
FOR EACH ROW
EXECUTE FUNCTION hash_password();

--trigger for checking if username already exists
CREATE OR REPLACE FUNCTION check_username()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM admins WHERE admins.username = NEW.username) > 0
    THEN
        RAISE EXCEPTION 'Username already exists';
    END IF;
    RETURN NEW;
END;

CREATE OR REPLACE TRIGGER trigger_check_username_for_admins
BEFORE INSERT OR UPDATE ON admins
FOR EACH ROW
EXECUTE FUNCTION check_username();

