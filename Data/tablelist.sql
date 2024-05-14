-- CREATE DATABASE --

drop database if exists footballdb;
create database footballdb;
\c footballdb  
SET datestyle = 'dmy';
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
 --updated on 24/4/2024


-- CREATE TABLES --

CREATE TABLE nation
(
    nation_id VARCHAR(6) PRIMARY KEY,
    nation_name VARCHAR(255) NOT NULL,
    continent VARCHAR(255) NOT NULL,
    organization VARCHAR             --updated on 7/5/2024
);

CREATE TABLE league         
(
    league_id VARCHAR(6) PRIMARY KEY,
    league_name VARCHAR(255) NOT NULL,
    formula VARCHAR(255) NOT NULL,
    website VARCHAR(255) NOT NULL,
    nation_id VARCHAR(6) REFERENCES nation(nation_id)
);

CREATE TABLE league_organ  --updated on 14/5/2024
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

CREATE TABLE participation  --updated on 14/5/2024
(
    season_id VARCHAR(10) REFERENCES season_id(season_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    state TEXT,
    PRIMARY KEY (season_id, club_id)
);

CREATE TABLE match     --updated on 14/5/2024
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

CREATE TABLE away 
(
    match_id VARCHAR(20) REFERENCES match(match_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
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

CREATE OR REPLACE FUNCTION calculate_ball_possession()
RETURNS TRIGGER AS $$
BEGIN
    NEW.ball_possession = 100 - (SELECT ball_possession FROM home WHERE home.match_id = NEW.match_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_calculate_ball_possession
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
    transfer_id VARCHAR(6) PRIMARY KEY,
    player_id VARCHAR(6) REFERENCES player_profile(player_id),
    club_id VARCHAR(3) REFERENCES club(club_id),
    shirt_number INT NOT NULL,
    position VARCHAR(3) NOT NULL,
    transfer_date DATE,
    contract_duration INT,
    salary INT
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



-- CREATE VIEW --
-- updated on 27/4/2024

CREATE OR REPLACE VIEW premierleague AS 
(
    SELECT 
        club.club_id, club.club_name,
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END) AS point,
        (SUM(home.num_of_goals) - SUM(away.num_of_goals)) AS goal_diff,
        SUM(home.num_of_goals) AS total_goals
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = 'EL0001' AND league_organ.season = '2023-2024'
    GROUP BY club.club_id
    ORDER BY point DESC, goal_diff DESC, total_goals DESC
);


CREATE OR REPLACE VIEW premierleague_ranking AS
(
    SELECT club_id, RANK() OVER (ORDER BY point DESC, goal_diff DESC, total_goals DESC) AS ranking 
    FROM premierleague
);

CREATE OR REPLACE VIEW laliga AS 
(
    SELECT 
        club.club_id, club.club_name,
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END) AS point,
        (SUM(home.num_of_goals) - SUM(away.num_of_goals)) AS goal_diff,
        SUM(home.num_of_goals) AS total_goals
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = 'SL0001' AND league_organ.season = '2023-2024'
    GROUP BY club.club_id
    ORDER BY point DESC, goal_diff DESC, total_goals DESC
);

CREATE OR REPLACE VIEW laliga_ranking AS
(
    SELECT club_id, RANK() OVER (ORDER BY point DESC, goal_diff DESC, total_goals DESC) AS ranking 
    FROM laliga
);

CREATE OR REPLACE VIEW seria AS 
(
    SELECT 
        club.club_id, club.club_name,
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END) AS point,
        (SUM(home.num_of_goals) - SUM(away.num_of_goals)) AS goal_diff,
        SUM(home.num_of_goals) AS total_goals
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = 'IL0001' AND league_organ.season = '2023-2024'
    GROUP BY club.club_id
    ORDER BY point DESC, goal_diff DESC, total_goals DESC
);

CREATE OR REPLACE VIEW seria_ranking AS
(
    SELECT club_id, RANK() OVER (ORDER BY point DESC, goal_diff DESC, total_goals DESC) AS ranking 
    FROM seria
);

CREATE OR REPLACE VIEW bundesliga AS 
(
    SELECT 
        club.club_id, club.club_name,
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END) AS point,
        (SUM(home.num_of_goals) - SUM(away.num_of_goals)) AS goal_diff,
        SUM(home.num_of_goals) AS total_goals
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.league_id = 'GL0001' AND league_organ.season = '2023-2024'
    GROUP BY club.club_id
    ORDER BY point DESC, goal_diff DESC, total_goals DESC
);

CREATE OR REPLACE VIEW bundesliga_ranking AS
(
    SELECT club_id, RANK() OVER (ORDER BY point DESC, goal_diff DESC, total_goals DESC) AS ranking 
    FROM bundesliga
);
