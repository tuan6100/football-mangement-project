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

CREATE TABLE participation  -- last updated on 14/5/2024
(
    season_id VARCHAR(10) REFERENCES season_id(season_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    state TEXT,
    PRIMARY KEY (season_id, club_id)
);

CREATE TABLE match     -- last updated on 14/5/2024
(
    match_id VARCHAR(20) PRIMARY KEY,
    season_id VARCHAR(10) REFERENCES league_organ(season_id),  
    round VARCHAR(255),
    date_of_match DATE NOT NULL,
    stadium VARCHAR(255) NOT NULL,
    referee VARCHAR(255) NOT NULL
);

CREATE TABLE home 
(
    match_id VARCHAR(20) REFERENCES match(match_id),
    club_id VARCHAR(3) REFERENCES participation(club_id),
    ball_possession INT NOT NULL,
    num_of_goals INT NOT NULL,
    total_shots INT NOT NULL,
    shots_on_target INT NOT NULL,
    corner_kicks INT NOT NULL,
    offsides INT NOT NULL,
    fouls INT NOT NULL,
    penalties INT,
    PRIMARY KEY (match_id, club_id)
);
-- create index on home (club_id), home (match_id)

CREATE TABLE away 
(
    match_id VARCHAR(20) REFERENCES match(match_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    ball_possession INT NOT NULL,
    num_of_goals INT,
    total_shots INT NOT NULL,
    shots_on_target INT NOT NULL,
    corner_kicks INT NOT NULL,
    offsides INT NOT NULL,
    fouls INT NOT NULL,
    penalties INT,
    PRIMARY KEY (match_id, club_id)
);
-- create index on home (club_id), home (match_id)

-- last updated on 7/6/2024: CREATE OR REPLACE TRIGGER to check that home table needs to be updated before away table
CREATE OR REPLACE FUNCTION check_match()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF (SELECT COUNT(*) FROM home WHERE home.match_id = NEW.match_id) = 0 THEN
            RAISE EXCEPTION 'Home table needs to be inserted first'
            USING HINT = 'Please insert data into home table first';
        END IF;
    ELSIF TG_OP = 'DELETE' THEN
        IF (SELECT COUNT(*) FROM home WHERE home.match_id = OLD.match_id) = 1 THEN
            RAISE EXCEPTION 'Home table needs to be deleted first'
            USING HINT = 'Please delete data from home table first';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER trigger_check_match
BEFORE INSERT OR DELETE ON away 
FOR EACH ROW
EXECUTE FUNCTION check_match();

--last updated on 1/5/2024: CREATE OR REPLACE TRIGGER to calculate ball possession
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

CREATE TABLE player_statistic
(
    player_id VARCHAR(20) REFERENCES player_profile(player_id),
    match_id VARCHAR(20) REFERENCES match(match_id),
    rating FLOAT check (rating <= 10),
    score INT,
    assist INT,
    yellow_cards INT CHECK (yellow_cards <= 1),
    red_cards INT CHECK (red_cards <= 1),
    PRIMARY KEY (player_id, match_id)
);

-- last updated on 14/5/2024: add trigger to update number of goals in each match

CREATE OR REPLACE FUNCTION calculate_goal()
RETURNS TRIGGER AS $$
BEGIN
        IF (SELECT home.club_id FROM home
            INNER JOIN player_statistic ON player_statistic.match_id = home.match_id  AND player_statistic.club_id = home.club_id
            WHERE home.club_id = NEW.club_id) IS NOT NULL
        THEN
            UPDATE home
            SET num_of_goals = SUM(player_statistic.score)
            WHERE home.match_id = NEW.match_id;
        ELSE
            UPDATE away
            SET num_of_goals = SUM(player_statistic.score)
            WHERE match_id = NEW.match_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_goals_trigger
AFTER INSERT OR UPDATE ON player_statistic
FOR EACH ROW
EXECUTE FUNCTION calculate_goal();


CREATE TABLE player_honours
(
    player_id VARCHAR(20) REFERENCES player_profile(player_id),
    league_id VARCHAR(6)  REFERENCES league(league_id),
    year INT NOT NULL,
    honours TEXT,
    PRIMARY KEY (player_id, league_id)
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

CREATE TABLE Coaching
(
    match_id VARCHAR(20) REFERENCES match(match_id),
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

-- last updated on 11/6/2024: create trigger to refresh match_result
CREATE OR REPLACE FUNCTION refresh_match_result()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW match_result;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_refresh_match_result
AFTER INSERT OR UPDATE OR DELETE ON away
FOR EACH ROW
EXECUTE FUNCTION refresh_match_result();



-- VIEW FOR SEEN LEAGUE TABLE

-- last updated on 2/6/2024: create function for statistic some datad
CREATE OR REPLACE FUNCTION calculate_point(var_club_id VARCHAR(3), var_league_id VARCHAR(6), var_season VARCHAR(10))
RETURNS INT AS $$
DECLARE var_point INT;
BEGIN
    SELECT 
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END)
    INTO var_point
    FROM match_result
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = var_league_id AND league_organ.season = var_season AND club.club_id = var_club_id;
    RETURN var_point;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_goal_diff(var_club_id VARCHAR(3), var_league_id VARCHAR(6), var_season VARCHAR(10))
RETURNS INT AS $$
DECLARE var_goal_diff INT;
BEGIN
    SELECT 
        (SUM(home.num_of_goals) - SUM(away.num_of_goals))
    INTO var_goal_diff
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = var_league_id AND league_organ.season = var_season AND club.club_id = var_club_id;
    RETURN var_goal_diff;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION calculate_total_goals(var_club_id VARCHAR(3), var_league_id VARCHAR(6), var_season VARCHAR(10))
RETURNS INT AS $$
DECLARE var_total_goals INT;
BEGIN
    SELECT 
        SUM(home.num_of_goals)
    INTO var_total_goals
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = var_league_id AND league_organ.season = var_season AND club.club_id = var_club_id;
    RETURN var_total_goals;
END;
$$ LANGUAGE plpgsql;

-- last updated on 11/6/2024: create view for seen league table
CREATE MATERIALIZED VIEW table_stats AS 
(
    SELECT 
        league_organ.league_id,
        club.club_id,
        calculate_point(club.club_id, league_organ.league_id, league_organ.season) AS point,  
        calculate_goal_diff(club.club_id, league_organ.league_id, league_organ.season) AS goal_diff,
        calculate_total_goals(club.club_id, league_organ.league_id, league_organ.season) AS total_goals 
    FROM league_organ
    INNER JOIN participation ON league_organ.season_id = participation.season_id
    INNER JOIN club ON participation.club_id = club.club_id  
    ORDER BY point DESC, goal_diff DESC, total_goals DESC     
);



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

