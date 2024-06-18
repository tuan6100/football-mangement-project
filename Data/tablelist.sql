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
    ball_possession INT L,
    num_of_goals INT ,
    total_shots INT ,
    shots_on_target INT ,
    corner_kicks INT ,
    offsides INT ,
    fouls INT ,
    penalties INT,
    PRIMARY KEY (match_id)
);
-- create index on home (club_id)
CREATE INDEX home_club_idx ON home (match_id, club_id);

CREATE TABLE away 
(
    match_id INT REFERENCES match(match_id) ON DELETE CASCADE,
    club_id VARCHAR(3) REFERENCES club(club_id) ,
    ball_possession INT ,
    num_of_goals INT,
    total_shots INT ,
    shots_on_target INT L,
    corner_kicks INT ,
    offsides INT ,
    fouls INT ,
    penalties INT,
    PRIMARY KEY (match_id)
);
-- create index on away (club_id)
CREATE INDEX away_club_idx ON away (match_id, club_id);


-- create trigger to auto insert match_id into home and away table when inserting new match
CREATE OR REPLACE FUNCTION update_match_id()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO home(match_id) VALUES (NEW.match_id);
    NSERT INTO away(match_id) VALUES (NEW.match_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_match_id
AFTER INSERT ON match
FOR EACH ROW
EXECUTE FUNCTION update_match_id();

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

CREATE INDEX player_name_idx ON player_profile USING hash (player_name);   

CREATE TABLE player_role
(
    season_id VARCHAR(10) REFERENCES league_organ(season_id),
    player_id VARCHAR(6) REFERENCES player_profile(player_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    shirt_number INT NOT NULL,
    position VARCHAR(3) NOT NULL,
    contract_duration DATE,
    total_goals INT,
    total_assists INT,
    PRIMARY KEY (player_id, club_id, season_id)
);

CREATE OR REPLACE FUNCTION calculate_total_goals()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE player_role
    SET total_score = total_score + 1
    WHERE player_role.player_id = NEW.player_goal
    AND player_role.season_id = (SELECT season_id FROM match WHERE match.match_id = NEW.match_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_calculate_total_goals
AFTER INSERT ON player_score
FOR EACH ROW
EXECUTE FUNCTION calculate_total_goals();

CREATE TABLE match_squad
(  
    match_id INT REFERENCES match(match_id) ON DELETE CASCADE,
    player_id	VARCHAR(6) REFERENCES player_profile(player_id),
    time_in INT CHECK (time_in >= 0 AND time_in <= 90),	
    time_out  INT CHECK (time_out >= 0 AND time_out <= 90),
    yellow_card	INT CHECK (yellow_card IN (0, 1)),
    red_card INT CHECK (red_card IN (0, 1)),
    rating INT CHECK (rating >= 0 AND rating <= 10),
    PRIMARY KEY (match_id, player_id)
);

CREATE TABLE player_score
(
    match_id INT REFERENCES match(match_id) ON DELETE CASCADE,
    player_goal VARCHAR(6) REFERENCES player_profile(player_id),
    player_assist VARCHAR(6) REFERENCES player_profile(player_id),
    time_goal INT CHECK (time_goal >= 0 AND time_goal <= 90),
    PRIMARY KEY (match_id, time_goal)
);

-- last updated on  16/6/2024 create trigger to update the number of goals for the home and away team
CREATE OR REPLACE FUNCTION calculate_num_of_goals()
RETURNS TRIGGER AS $$
DECLARE
    var_club_id VARCHAR(3);
BEGIN
    -- Check if the club_id is in the home or away team
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        SELECT club_id
        INTO var_club_id
        FROM player_role
        INNER JOIN match ON player_role.season_id = match.season_id
        WHERE player_role.player_id = NEW.player_goal AND match.match_id = NEW.match_id;

        IF EXISTS (SELECT 1 FROM home WHERE home.match_id = NEW.match_id AND home.club_id = var_club_id) THEN
            UPDATE home 
            SET num_of_goals = num_of_goals + 1 
            WHERE home.match_id = NEW.match_id;
         ELSIF EXISTS (SELECT 1 FROM away WHERE away.match_id = NEW.match_id AND away.club_id = var_club_id) THEN
            UPDATE away 
            SET num_of_goals = num_of_goals + 1 
            WHERE away.match_id = NEW.match_id;
        END IF;
    
    ELSIF TG_OP = 'DELETE' THEN
        SELECT club_id
        INTO var_club_id
        FROM player_role
        INNER JOIN match ON player_role.season_id = match.season_id
        WHERE player_role.player_id = OLD.player_goal AND match.match_id = OLD.match_id;

        IF EXISTS (SELECT 1 FROM home WHERE home.match_id = OLD.match_id AND home.club_id = var_club_id) THEN
            UPDATE home 
            SET num_of_goals = num_of_goals - 1 
            WHERE home.match_id = OLD.match_id;
         ELSIF EXISTS (SELECT 1 FROM away WHERE away.match_id = OLD.match_id AND away.club_id = var_club_id) THEN
            UPDATE away 
            SET num_of_goals = num_of_goals - 1 
            WHERE away.match_id = OLD.match_id;
        END IF;
    END IF;
    REFRESH MATERIALIZED VIEW match_result;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_calculate_num_of_goals
AFTER INSERT OR DELETE OR UPDATE ON player_score
FOR EACH ROW
EXECUTE FUNCTION calculate_num_of_goals();


CREATE TABLE manager
(
    manager_id VARCHAR(20) PRIMARY KEY,
    manager_name VARCHAR(255) NOT NULL,
    date_of_birth VARCHAR NOT NULL
);

CREATE TABLE management
(
    club_id VARCHAR(3) REFERENCES club(club_id),
    manager_id VARCHAR(20) REFERENCES manager(manager_id),
    season_id VARCHAR(20) REFERENCES league_organ(season_id),
    PRIMARY KEY (club_id, manager_id, season_id)
);


CREATE TABLE participation
(
    club_id VARCHAR(3) REFERENCES club(club_id),
    season_id VARCHAR(20) REFERENCES league_organ(season_id),
    num_of_matches INT,
    point INT,
    goal_diff INT,
    state TEXT,
    PRIMARY KEY (club_id, season_id)
);


-- last updated on 11/6/2024: create function to calculate point and goal difference
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

CREATE OR REPLACE FUNCTION count_match_played(var_club_id VARCHAR(3), var_season_id VARCHAR(20))
RETURNS INT AS $$
DECLARE num INT;
BEGIN
    SELECT 
        COUNT(match_result.match_id)
    INTO num
    FROM match_result
    INNER JOIN match on match_result.match_id = match.match_id
    WHERE match.season_id = var_season_id
    AND match_result.home_team = var_club_id OR  match_result.away_team = var_club_id ;
    RETURN num;
END;
$$ LANGUAGE plpgsql;


-- CREATE VIEWS --
-- last updated on 27/4/2024 

-- VIEW FOR SEEN MATCH RESULT

-- last updated on 11/6/2024: create view to seen match result
CREATE MATERIALIZED VIEW match_result AS
SELECT
    m.match_id,
    hm.club_id AS home_team,
    hm.num_of_goals AS home_score,
    am.club_id AS away_team,
    am.num_of_goals AS away_score,
    CASE
        WHEN hm.num_of_goals > am.num_of_goals THEN hm.club_id
        WHEN hm.num_of_goals < am.num_of_goals THEN am.club_id
        ELSE 'Draw'
    END AS match_winner
FROM
    match m
    JOIN home hm ON m.match_id = hm.match_id
    JOIN away am ON m.match_id = am.match_id; 

create index match_result_idx1 on match_result (match_id );
create index match_result_idx2 on match_result (home_team);
create index match_result_idx3 on match_result (away_team);              -- for OR operator
create index match_result_idx4 on match_result (home_team, away_team);   -- for AND operator




-- -- CREATE RABLE TO MANAGE PERMISSION FOR ADMINS AND GUESTS
-- -- last updated on 8/6/2024
-- CREATE ROLE admin;
-- -- all permissions2
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

-- CREATE ROLE guest;
-- -- read-only permissions
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO guest;

-- CREATE TABLE admins 
-- (
--     admin_id SERIAL PRIMARY KEY,
--     fullnames VARCHAR(50) NOT NULL,
--     username VARCHAR(50) NOT NULL,
--     phone_number VARCHAR(15) NOT NULL,
--     email VARCHAR(50) NOT NULL,
--     password VARCHAR(255) NOT NULL
-- );
-- CREATE INDEX admins_idx ON admins (username);

-- CREATE TABLE guests 
-- (
--     guest_id SERIAL PRIMARY KEY,
--     fullnames VARCHAR(50),
--     username VARCHAR(50) NOT NULL,
--     email VARCHAR(50) NOT NULL,
--     password VARCHAR(255) NOT NULL
-- );
-- CREATE INDEX guests_idx ON guests (username);

-- -- trigger to grant permissions 
-- CREATE OR REPLACE FUNCTION grant_permissions()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF TG_TABLE_NAME = 'admins' THEN
--         GRANT admin TO NEW.username;
--     ELSIF TG_TABLE_NAME = 'guests' THEN
--         GRANT guest TO NEW.username;
--     END IF;
-- END;

-- CREATE OR REPLACE FUNCTION grant_permissions()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF TG_TABLE_NAME = 'admins' THEN
--         EXECUTE 'GRANT admin TO "' || NEW.username || '";';
--     ELSIF TG_TABLE_NAME = 'guests' THEN
--         EXECUTE 'GRANT guest TO "' || NEW.username || '";';
--     END IF;
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- -- trigger to hash password
-- CREATE OR REPLACE FUNCTION hash_password()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.password = crypt(NEW.password, gen_salt('sha256'));
--     RETURN NEW;
-- END;

-- CREATE OR REPLACE TRIGGER trigger_hash_password_for_admins
-- BEFORE INSERT OR UPDATE ON admins
-- FOR EACH ROW
-- EXECUTE FUNCTION hash_password();

-- CREATE OR REPLACE TRIGGER trigger_hash_password_for_guests
-- BEFORE INSERT OR UPDATE ON guests
-- FOR EACH ROW
-- EXECUTE FUNCTION hash_password();

-- --trigger for checking if username already exists
-- CREATE OR REPLACE FUNCTION check_username()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     IF (SELECT COUNT(*) FROM admins WHERE admins.username = NEW.username) > 0
--     THEN
--         RAISE EXCEPTION 'Username already exists';
--     END IF;
--     RETURN NEW;
-- END;

-- CREATE OR REPLACE TRIGGER trigger_check_username_for_admins
-- BEFORE INSERT OR UPDATE ON admins
-- FOR EACH ROW
-- EXECUTE FUNCTION check_username();

