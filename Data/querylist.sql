-- 1. Thêm một trận đấu mới

INSERT INTO match(match_id, season_id, round, date_of_match, stadium, referee)
VALUES ('6119','LIGUE12324','38','09/01/2024','Stade Bollaert-Delelis', 'Myrtle Riccardini');


-- 2. Cập nhật só liệu thống kê thu được trong các trận đấu sau mỗi trận đấu

-- trigger để tự động cập nhật mã trận đấu vào bảng con
CREATE OR REPLACE FUNCTION UPDATE_match_id()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO home(match_id) VALUES (NEW.match_id);
    NSERT INTO away(match_id) VALUES (NEW.match_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_UPDATE_match_id
AFTER INSERT ON match
FOR EACH ROW
EXECUTE FUNCTION UPDATE_match_id();

-- trigger để tính tỷ lể kiểm soát bóng
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



-- 3. Cập nhật tỷ sô cho trận đấu

--trigger để cập nhật số bàn thắng vào bảng home và away khi có cầu thủ ghi bàn
CREATE OR REPLACE FUNCTION calculate_num_of_goals()
RETURNS TRIGGER AS $$
DECLARE
    var_club_id VARCHAR(3);
BEGIN
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

-- view để theo dõi tỷ số trận đấu 
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



-- 4. Cập nhật bxh sau mỗi trận đấu
UPDATE participation SET num_of_matches = count_match_played(club_id, season_id);
UPDATE participation SET point = calculate_point(club_id, season_id);
UPDATE participation SET goal_diff = calculate_goal_diff(club_id, season_id);




-- 5	Xóa trận đấu bị hủy
DELETE FROM match WHERE match_id = '6119';
DELETE FROM match WHERE date_of_match  = '09/01/2024' AND stadium = 'Stade Bollaert-Delelis';
	

-- 6. Cập nhật thông tin chuyển nhượng cầu thủ
UPDATE player_role
SET club_id = 'RMA' AND season_id = 'LALIGA2425'
WHERE player_id = (SELECT player_id FROM player_profile WHERE player_name = 'Killian Mbappe');


-- 7. Thống kê tỷ lệ thắng, hòa, thua của clb

-- toi uu
SELECT 
    club.club_name,
    SUM(CASE 
        WHEN match_result.home_team = club.club_id AND match_result.home_score > match_result.away_score THEN 1
        WHEN match_result.away_team = club.club_id AND match_result.away_score > match_result.home_score THEN 1
        ELSE 0
    END) as win,
    SUM(CASE 
        WHEN match_result.home_team = club.club_id AND match_result.home_score = match_result.away_score THEN 1
        WHEN match_result.away_team = club.club_id AND match_result.away_score = match_result.home_score THEN 1
        ELSE 0
    END) as draw,
    SUM(CASE 
        WHEN match_result.home_team = club.club_id AND match_result.home_score < match_result.away_score THEN 1
        WHEN match_result.away_team = club.club_id AND match_result.away_score < match_result.home_score THEN 1
        ELSE 0
    END) as lose
FROM match_result
INNER JOIN match ON match_result.match_id = match.match_id
INNER JOIN club ON club.club_id = match_result.home_team OR club.club_id = match_result.away_team
WHERE club.club_name = '...'
GROUP BY club.club_name;

-- chua toi uu
WITH MatchResults AS (
    SELECT
        hm.club_id AS club_id,
        m.match_id,
        CASE 
            WHEN hm.num_of_goals > am.num_of_goals THEN 'Win'
            WHEN hm.num_of_goals < am.num_of_goals THEN 'Loss'
            ELSE 'Draw'
        END AS result
    FROM
        match m
        JOIN home hm ON m.match_id = hm.match_id
        JOIN away am ON m.match_id = am.match_id
    UNION ALL
    SELECT
        am.club_id AS club_id,
        m.match_id,
        CASE 
            WHEN am.num_of_goals > hm.num_of_goals THEN 'Win'
            WHEN am.num_of_goals < hm.num_of_goals THEN 'Loss'
            ELSE 'Draw'
        END AS result
    FROM
        match m
        JOIN home hm ON m.match_id = hm.match_id
        JOIN away am ON m.match_id = am.match_id
)
SELECT
    club.club_name,
    COUNT(CASE WHEN mr.result = 'Win' THEN 1 END) AS Wins,
    COUNT(CASE WHEN mr.result = 'Draw' THEN 1 END) AS Draws,
    COUNT(CASE WHEN mr.result = 'Loss' THEN 1 END) AS Losses
FROM
    MatchResults mr
    JOIN club ON mr.club_id = club.club_id
    WHERE club.club_name = '...'
GROUP BY
    club.club_name
ORDER BY
    club.club_name;



-- 8. Thống kê tổng số bàn thắng, kiến tạo của cầu thủ sau từng trận đấu

-- tinh tong so ban thang
alter table player_role add column total_scores int;

create or replace function UPDATE_total_goals(var_playerid varchar(6), var_seasonid varchar(20))
returns int as $$
declare total int;
begin
	select count(*) into total
	from player_score
    where player_score.player_goal = var_playerid
    and (select season_id from match where match.match_id = player_score.match_id) = var_seasonid;
	RETURN total;
end;
$$ language plpgsql;

UPDATE player_role SET total_goals = UPDATE_total_goals(player_id, season_id);

-- tinh tong so kien tao
alter table player_role add column total_assists int;

create or replace function UPDATE_total_assists(var_playerid varchar(6), var_seasonid varchar(20))
returns int as $$
declare total int;
begin
	select count(*) into total
	from player_score
    where player_score.player_assist = var_playerid
    and (select season_id from match where match.match_id = player_score.match_id) = var_seasonid;
	RETURN total;
end;
$$ language plpgsql;

UPDATE player_role SET total_assists = UPDATE_total_assists(player_id, season_id);




-- 9. Thống kê số phút thi đấu trung bình của cầu thủ trong mùa giải S?

select player_profile.player_name, 
       round(avg(match_squad.time_out - match_squad.time_in ),2) as avg_time
from match_squad
inner join player_profile on match_squad.player_id = player_profile.player_id
inner join match on match_squad.match_id = match.match_id
where match.season_id = '...'
group by player_profile.player_name
order by avg_time desc;


-- 10. Tìm cầu thủ xuất sắc nhất trong trận đấu (MOTM)

SELECT player_profile.player_name, match_squad.rating AS max_rating
FROM match_squad
INNER JOIN player_profile ON match_squad.player_id = player_profile.player_id
WHERE match_squad.match_id = '...' 
AND match_squad.rating = 
(
    SELECT MAX(rating) 
    FROM match_squad 
    WHERE match_id = '...'
);

-- 11. Trả về nhà vô địch của các giải đấu
WITH ranked_clubs AS (
    SELECT club_id, season_id, 
           RANK() OVER (PARTITION BY season_id ORDER BY point DESC, goal_diff DESC) AS rank
    FROM participation
	WHERE season_id = '...'
)
UPDATE participation
SET state= 'Champion'
WHERE (club_id, season_id) IN (
    SELECT club_id, season_id
    FROM ranked_clubs
    WHERE rank = 1 
);

-- 12. Trả về danh sách các clb tham dự giải đấu UEFA Champion League mùa sau
WITH ranked_clubs AS (
    SELECT club_id, season_id, 
           RANK() OVER (PARTITION BY season_id ORDER BY point DESC, goal_diff DESC) AS rank
    FROM participation
	WHERE season_id = '...'
)
UPDATE participation
SET state= 'C1'
WHERE (club_id, season_id) IN (
    SELECT club_id, season_id
    FROM ranked_clubs
    WHERE rank IN (2, 3 ,4) 
);

-- 13. Trả về danh sách các clb tham dự giải đấu UEFA Europa League mùa sau
WITH ranked_clubs AS (
    SELECT club_id, season_id, 
           RANK() OVER (PARTITION BY season_id ORDER BY point DESC, goal_diff DESC) AS rank
    FROM participation
	WHERE season_id = 'EPL2324'
)
UPDATE participation
SET state= 'C2'
WHERE (club_id, season_id) IN (
    SELECT club_id, season_id
    FROM ranked_clubs
    WHERE rank IN (5, 6) 
	UNION
	SELECT match.season_id, match_result.match_winner
	FROM match
	INNER JOIN match_result ON match.match_id = match_result.match_id
	INNER JOIN club ON match_result.match_winner = club.club_id
	INNER JOIN league_organ ON match.season_id = league_organ.season_id
	INNER JOIN league ON league_organ.league_id = league.league_id
WHERE match.round = 'Chung kết' and league.league_id like '%0002'
);

-- 14. Tỉ lệ thắng thua của đội bóng A trong giải đấu B
SELECT
	'LIV' AS team_a,
	'MCI' AS versus,
    COUNT(*) AS total_matches,
    COUNT(CASE WHEN match_winner = 'LIV' THEN 1 END) AS wins,
    COUNT(CASE WHEN match_winner = 'MCI' THEN 1 END) AS losses,
    COUNT(CASE WHEN match_winner = 'Draw' THEN 1 END) AS draws,
    ROUND(COUNT(CASE WHEN match_winner = 'LIV' THEN 1 END) * 100.0 / COUNT(*), 2) AS win_percentage,
    ROUND(COUNT(CASE WHEN match_winner = 'MCI' THEN 1 END) * 100.0 / COUNT(*), 2) AS loss_percentage
FROM
    match_result mr
WHERE
	(mr.home_team = 'LIV' AND mr.away_team = 'MCI')
    OR (mr.home_team = 'MCI' AND mr.away_team = 'LIV');



-- 15. Trả về Tỉ lệ thắng thua của đội bóng A trong giải đấu B

SELECT
    COUNT(*) AS total_matches,
    COUNT(CASE WHEN match_winner = 'LIV' THEN 1 END) AS wins,
    COUNT(CASE WHEN match_winner != 'LIV' THEN 1 END) AS losses,
    COUNT(CASE WHEN match_winner = 'Draw' THEN 1 END) AS draws,
    ROUND(COUNT(CASE WHEN match_winner = 'LIV' THEN 1 END) * 100.0 / COUNT(*), 2) AS win_percentage,
    ROUND(COUNT(CASE WHEN match_winner != 'LIV' THEN 1 END) * 100.0 / COUNT(*), 2) AS loss_percentage
FROM
    match_result mr
	INNER JOIN match on mr.match_id = match.match_id
WHERE
	match.season_id = 'EPL2324' AND
	(home_team = 'LIV' OR away_team = 'LIV');



-- 16. Trả về vua phá luới của giải đấu trong mùa giải

SELECT 
    player_profile.player_name,
    player_role.total_goals as total_goals
FROM player_role
INNER JOIN player_profile ON player_role.player_id = player_profile.player_id
WHERE player_role.season_id = '...'
AND player_role.total_goals = 
(
    SELECT MAX(total_goals)
    FROM player_role
    WHERE season_id = '...'
);



-- 17. Kiểm tra điều kiện thi đấu của cầu thủ

-- thêm cột total_cards vào bảng player_role
ALTER TABLE player_role ADD column total_cards INT;

CREATE FUNCTION UPDATE_total_cards()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE plater_role
    SET total_cards = total_cards + NEW.yellow_card
    WHERE player_role.player_id = NEW.player_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_UPDATE_total_card
AFTER INSERT OR UPDATE ON match_squad
FOR EACH ROW
EXECUTE FUNCTION UPDATE_total_cards();

-- kiểm tra số thẻ vàng là bội của 5 
CREATE OR REPLACE FUNCTION check_cond_player()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT total_cards FROM plater_role WHERE player_id = NEW.player_id) % 5 = 0 THEN
        RAISE EXCEPTION 'Player % is banned in this match', NEW.player_id ;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_check_cond_player
BEFORE INSERT ON match_squad
FOR EACH ROW
EXECUTE FUNCTION check_cond_player();


-- 18. Liệt kê danh sách cầu thủ thuộc biên chế CLB C? trong mùa giải L?

SELECT 
	pr.club_id, pp.player_name, pp.date_of_birth, pp.nation_id, pp.height, pr.position, pp.freferred_foot
FROM 
	player_role pr
	JOIN player_profile pp ON pr.player_id = pp.player_id
WHERE
 	pr.club_id = 'C?' AND pr.season_id = 'L?';


-- 19. Liệt kê danh sách cầu thủ có quốc tịch N? và đang thi đấu ở giải đấu L?

-- chua toi uu
SELECT player_profile.player_name
FROM player_profile
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN nation ON player_profile.nation_id = nation.nation_id
INNER JOIN league_organ ON player_role.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE nation.nation_name = 'N?'
AND league.league_name = 'L?'
AND CURRENT_DATE >= league_organ.date_start;

--toi uu
CREATE INDEX idx_nation_name on nation (nation_name);
CREATE INDEX idx_league_name on league (league_name);

-- 20. Liệt kê danh sách cầu thủ dưới ... tuổi đang thi đấu ở giải đấu L?

--chua toi uu
SELECT player_profile.player_name,
       AGE(now(), player_profile.date_of_birth) as age
FROM player_profile
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN league_organ ON player_role.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE EXTRACT(YEAR FROM AGE(player_profile.date_of_birth)) < 23;

--toi uu
ALTER TABLE player_profile ADD COLUMN age INT;

CREATE OR REPLACE FUNCTION dob_to_age(var_dob DATE)
RETURNS INT AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(var_dob));
END;
$$ LANGUAGE plpgsql;

create index idx_player_age on player_profile (age) ;

SELECT player_profile.player_name,
       AGE(CURRENT_DATE, player_profile.date_of_birth) as age
FROM player_profile
INNER JOIN player_role ON player_role.player_id = player_profile.player_id
INNER JOIN league_organ ON player_role.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE player_profile.age < 23;



-- 21. Tìm cầu thủ có chiều cao lớn nhất và thi đấu ở vị trí ?

-- chua toi uu
SELECT player_profile.player_name, player_profile.height
FROM player_profile
WHERE player_profile.height = 
(
    SELECT MAX(height)
    FROM player_profile
	INNER JOIN player_role ON player_profile.player_id = player_role.player_id
	WHERE player_role.position = 'ST'
);

-- toi uu
CREATE INDEX idx_player_height on player_profile (height);
CREATE INDEX idx_player_position on player_role using hash (position);



-- 22. Liệt kê danh sách cầu thủ được chuyển nhượng sau mùa giải S?

-- ham tim mua giai tiep theo
CREATE OR REPLACE FUNCTION next_season(var_season VARCHAR(10))
RETURNS VARCHAR(10) AS $$
DECLARE
    year1 INT;
    year2 INT;
BEGIN
    year1 := CAST(SPLIT_PART(var_season, '-', 1) AS INT);
    year2 := CAST(SPLIT_PART(var_season, '-', 2) AS INT);
    RETURN TO_CHAR(year1 + 1, 'FM0000') || '-' || TO_CHAR(year2 + 1, 'FM0000');
END;
$$ LANGUAGE plpgsql;

-- tim cau thu co 2 ma clb khac nhau
CREATE OR REPLACE FUNCTION transferred_players(var_season VARCHAR(20))
RETURNS TABLE (
    player_name VARCHAR(50),
    old_club_id VARCHAR(50),
    new_club_id VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY 
    WITH old_club AS (
        SELECT pr.player_id, pr.club_id
        FROM player_role pr
        INNER JOIN league_organ lo ON pr.season_id = lo.season_id
        WHERE lo.season = var_season
    ),
    new_club AS (
        SELECT pr.player_id, pr.club_id
        FROM player_role pr
        INNER JOIN league_organ lo ON pr.season_id = lo.season_id
        WHERE lo.season = next_season(var_season)
    )
    SELECT 
        pp.player_name,
        old.club_name AS old_club_name,
        new.club_name AS new_club_name
    FROM player_profile pp
    INNER JOIN old_club oc ON pp.player_id = oc.player_id
    INNER JOIN new_club nc ON pp.player_id = nc.player_id
    INNER JOIN club old ON oc.club_id = old.club_id
    INNER JOIN club new ON nc.club_id = new.club_id
    WHERE oc.club_id != nc.club_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM transferred_players('2022-2023');



--23. (Hoan) liệt kê danh sách cầu thủ còn hợp đồng  ... năm
SELECT pp.player_name, pr.club_id, pr.contract_duration
FROM player_profile pp 
	JOIN player_role pr ON pp.player_id = pr.player_id
WHERE season_id LIKE '%2324' AND pr.contract_duration = ...



-- 24. Liệt kê top 10 cầu thủ thi đấu nhiều trận nhất ở giải đấu L? trong mùa giải S?

SELECT player_profile.player_name, COUNT(match_squad.player_id) as num_of_matches
FROM match_squad
INNER JOIN player_profile ON match_squad.player_id = player_profile.player_id
INNER JOIN match ON match_squad.match_id = match.match_id
INNER JOIN league_organ ON match.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE league.league_name = 'L?'
AND league_organ.season = 'S?'
GROUP BY player_profile.player_id
ORDER BY num_of_matches DESC LIMIT 10;


--35. (Hoan) Top tỉ lệ cầm bóng cao nhất của giải đấu A

SELECT
    c.club_name,
    c.club_id,
    ROUND(AVG(ball_possession),2) AS average_ball_possession
FROM (
    SELECT
        hm.club_id,
        hm.ball_possession
    FROM home hm
    JOIN match m ON hm.match_id = m.match_id
    WHERE m.season_id = 'BUNDES2324'
    UNION ALL
    SELECT
        am.club_id,
        am.ball_possession
    FROM away am
    JOIN match m ON am.match_id = m.match_id
    WHERE m.season_id = 'BUNDES2324'
) AS cm
JOIN club c ON c.club_id = cm.club_id
GROUP BY
    c.club_id, 
    c.club_name
ORDER BY average_ball_possession DESC
LIMIT 10;

	

-- 26. Liệt kê danh sách cầu thủ ghi được hattrick trong 1 trận đấu trong mùa giải S?

SELECT player_profile.player_name
FROM player_profile
INNER JOIN player_score ON player_profile.player_id = player_score.player_goal
INNER JOIN match ON player_score.match_id = match.match_id
INNER JOIN league_organ ON match.season_id = league_organ.season_id
WHERE league_organ.season = '2023-2024'
GROUP BY player_profile.player_name, match.match_id
HAVING COUNT(player_score.player_goal) >= 3;  


-- 27. Liệt kê tỉ số của các trận đấu diễn ra trong ngày D?

-- chua toi uu
SELECT match_result.*
FROM match_result
INNER JOIN match ON match_result.match_id = match.match_id
WHERE match.date_of_match = 'D?';

-- toi uu
CREATE INDEX idx_date on match (date_of_match);

--28. Lịch sử đối đầu của 2 đội bóng 
SELECT
    m.season_id,
    m.round,
    m.stadium,
    m.referee,
    mr.home_team AS home_club,
    mr.away_team AS away_club,
    mr.home_score AS home_goals,
    mr.away_score AS away_goals,
    CASE
        WHEN mr.home_score > mr.away_score THEN mr.home_team
        WHEN mr.home_score < mr.away_score THEN mr.away_team
        ELSE 'Draw'
    END AS match_winner
FROM
    match m
    JOIN match_result mr ON m.match_id = mr.match_id
WHERE
    (mr.home_team = 'LIV' AND mr.away_team = 'MCI')
    OR (mr.home_team = 'MCI' AND mr.away_team = 'LIV')
ORDER BY
	m.season_id,
	m.round; 


-- 29. Liệt kê danh sách những CLB vô địch từ mùa giải S? đến nay ở giải đấu L?

-- chua toi uu
SELECT club.club_name
FROM club
INNER JOIN participation ON club.club_id = participation.club_id
INNER JOIN league_organ ON participation.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE league_organ.date_end >= 'S?' 
AND league.league_name = 'L?'
AND participation.state = 'Champion';

-- toi uu
CREATE INDEX idx_state on participation (state);



-- 30. Liệt kê danh sách các CLB mà HLV M? đã chỉ đạo từ năm ? Đến nay

-- chua toi uu
SELECT DISTINCT manager.manager_name, club.club_name
FROM manager
INNER JOIN management ON manager.manager_id = management.manager_id
INNER JOIN club ON management.club_id = club.club_id
INNER JOIN league_organ ON management.season_id = league_organ.season_id
WHERE manager.manager_name = '...' AND league_organ.date_start >= '...' AND league_organ.date_end <= CURRENT_DATE;

-- toi uu
CREATE INDEX idx_manager_name on manager (manager_name);





--31. Chiều cao trung bình của đội bóng A trong giải B
SELECT 
	pr.club_id, AVG(pp.height) AS average_height
FROM 
	player_role pr 
	JOIN player_profile pp ON pr.player_id = pp.player_id
WHERE
	pr.club_id = 'LIV' AND pr.season_id = 'EPL2324'
GROUP BY pr.club_id;


--32. Trả lịch thi đấu từ ... đến ... của giải ...
SELECT * 
FROM 
	match m
WHERE 
	m.date_of_match BETWEEN '12/08/2023' AND '1/1/2024' AND season_id = 'EPL2324';






