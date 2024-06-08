
--1. Liệt kê danh sách cầu thủ có quốc tịch ... và thi đấu ở clb ...
SELECT player_profile.player_name 
FROM player_profile
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club ON club.club_id = player_role.player_id
INNER JOIN natiON ON player_profile.natiON_id = natiON.natiON_id
WHERE club.club_name = '...' and  natiON.natiON_name= '...';

--2. Liệt kê số bàn thắng và kiến tạo mà cầu thủ ... có được từ năm ... đến nay.
SELECT
    player_profile.player_name,
    SUM(CASE WHEN p.score >= 0 THEN p.score ELSE 0 END) AS total_goals,
    SUM(p.assist) AS total_assists
FROM
    player_statistic as p
INNER JOIN player_profile ON p.player_id = player_profile.player_id
INNER JOIN match m ON p.match_id = m.match_id
WHERE
    player_profile.player_name SIMILAR TO '(...|...)%'
    AND m.date_of_match >= '1/2/2023'
    AND m.date_of_match <= CURRENT_DATE
GROUP BY player_profile.player_id;

--3. In ra số trận đấu mà cầu thủ ... thi đấu cho clb ... từ năm ... đến nay.
SELECT 
    player_profile.player_name, 
    club.club_name,
    COUNT(match.match_id) AS "num_of_matches"
FROM  player_statistic
INNER JOIN player_profile ON player_statistic.player_id = player_profile.player_id 
INNER JOIN player_role ON player_statistic.player_id = player_role.player_id
INNER JOIN match ON player_statistic.match_id = match.match_id
INNER JOIN club ON player_role.club_id = club.club_id
WHERE club.club_name = '...'  
      AND player_profile.player_name = '...'  
      AND EXTRACT(YEAR FROM match.date_of_match) >= ...
GROUP BY player_profile.player_name, club.club_id;

--4. Liệt kê tổng số bàn thắng/kiến tạo cầu thủ ghi được trong mùa giải ...
SELECT 
     player_profile.player_name, 
     SUM(player_statistic.score + player_statistic.assist) as total_score_assist
FROM player_profile
INNER JOIN player_statistic ON player_statistic.player_id = player_profile.player_id
INNER JOIN match ON player_statistic.match_id = match.match_id
where player_profile.player_name = "..." 
      AND EXTRACT(YEAR FROM match.date_of_match) in (2023, 2024)
GROUP BY player_profile.player_name;

--5. Liệt kê các clb đã vô địch ở các giải đấu trong mua giai ...
SELECT 
    league.league_name,
    club.club_name
FROM league
INNER JOIN participation ON league.league_id = participation.league_id
INNER JOIN match ON participation.match_id = match.match_id
WHERE participation.state = "Vo dich" AND participation.season = "";

--6. Liệt kê tỉ số của các trận diễn ra trong vòng đấu ... của giải đấu ... trong mùa giải ...
SELECT 
    match.date_of_match,
    home_club.club_name AS home_team,  
    (CAST(home.num_of_goals AS CHAR) || '-' || CAST(away.num_of_goals AS CHAR)) AS match_score,
    away_club.club_name AS away_team
FROM match
INNER JOIN home ON match.match_id = home.match_id
INNER JOIN away ON match.match_id = away.match_id
INNER JOIN club AS home_club ON home.club_id = home_club.club_id
INNER JOIN club AS away_club ON away.club_id = away_club.club_id
INNER JOIN league_organ ON match.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE 
     league.league_name = '...'
     AND match.round = '...'
     AND league_organ.season = '...';

--7. In ra lịch sử đối đấu giữa 2 đội bóng ... và ... từ năm ... đến năm ...
--   Thông tin in ra bao gồm mùa giải, tên giải đấu, vòng đấu, tỉ số trận đấu.
SELECT
    league.league_name,
    EXTRACT(YEAR FROM match.date_of_match) AS season,
    match.round,
    match.date_of_match,
    home_club.club_name AS home_team,  
    (CAST(home.num_of_goals AS CHAR) || '-' || CAST(away.num_of_goals AS CHAR)) AS match_score,
    away_club.club_name AS away_team
FROM match
INNER JOIN home ON match.match_id = home.match_id
INNER JOIN away ON match.match_id = away.match_id
INNER JOIN league ON match.league_id = league.league_id
INNER JOIN club AS home_club ON home.club_id = home_club.club_id
INNER JOIN club AS away_club ON away.club_id = away_club.club_id
WHERE
    (home.club_id = '...' AND away.club_id = '...')
    OR (home.club_id = '...' AND away.club_id = '...');

--8. In ra số trận thắng, hòa, thua và tính điểm số mà clb ... nhận được trong mùa giải ... ở giải đấu ...
--   Biết rằng điểm số được tính theo công thức = số trận thắng * 3 + số trận hòa.
    SELECT 
        club.club_name,
        SUM(CASE 
            WHEN home.num_of_goals > away.num_of_goals THEN 3
            WHEN home.num_of_goals = away.num_of_goals THEN 1
            ELSE 0
        END) AS point,
        COUNT(CASE WHEN home.num_of_goals > away.num_of_goals THEN 1 END) as win,
        COUNT(CASE WHEN home.num_of_goals = away.num_of_goals THEN 1 END) as draw,
        COUNT(CASE WHEN home.num_of_goals < away.num_of_goals THEN 1 END) as lose
    FROM match
    INNER JOIN home ON match.match_id = home.match_id
    INNER JOIN away ON match.match_id = away.match_id
    INNER JOIN club ON club.club_id = home.club_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.season_id = '...' 
    GROUP BY club.club_id;

--9. In ra bảng xếp hạng của giải đấu ... trong mùa giải ... 
--   Biết rằng các đội bóng được xếp hạng theo thứ tự ưu tiên điểm số -> hiệu số bàn thắng-thua -> số bàn thắng
SELECT 
    club_name, 
    point, 
    goal_diff, 
    total_goals,
    RANK() OVER (ORDER BY point DESC, goal_diff DESC, total_goals DESC) AS ranking 
FROM 
    (SELECT 
        club.club_name, 
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
    WHERE league_organ.season_id = '...'
    GROUP BY club.club_id
) AS subquery
ORDER BY point DESC, goal_diff DESC, total_goals DESC;


--10. In ra danh sách tên các clb ... đã thi đấu trong ngày ...
SELECT
    home_club.club_name AS home,
    (CAST(home.num_of_goals AS CHAR) || '-' || CAST(away.num_of_goals AS CHAR)) AS score,
    away_club.club_name AS away
FROM match
INNER JOIN home ON match.match_id = home.match_id
INNER JOIN away ON match.match_id = away.match_id
INNER JOIN club AS home_club ON home_club.club_id = home.club_id
INNER JOIN club AS away_club ON away_club.club_id = away.club_id
WHERE match.date_of_match = '...';

--11. In ra thông tin của vua phá lưới của giải đấu ... trong mùa giải ...
--   Biết rằng vua phá lưới là một hoặc nhiều cầu thủ ghi nhiều bàn thắng nhất giải đấu trong mùa giải đó.
-- Find the top scorer(s) in a specific league and season
WITH player_goals AS 
(
    SELECT 
        player_profile.player_id,
        player_profile.player_name,
        SUM(player_statistic.score) AS total_goals
    FROM player_profile
    INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
    INNER JOIN match ON player_statistic.match_id = match.match_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    WHERE league_organ.season_id = '...'
    GROUP BY player_profile.player_id
),
top_scorers AS 
(
    SELECT 
        player_id, 
        player_name, 
        total_goals,
        RANK() OVER (ORDER BY total_goals DESC) AS ranking
    FROM player_goals
)
SELECT 
    player_id, 
    player_name, 
    total_goals
FROM top_scorers
WHERE ranking = 1;


--12. In ra thông tin cầu thủ xuất sắc nhất giải đấu ... trong mùa giải ...
--   Biết rằng cầu thủ xuất sắc nhất là cầu thủ có tổng số bàn thắng + kiến tạo nhiều nhất va có số thẻ phạt ít nhất trong mùa giải đó.
WITH player_stats AS 
(
    SELECT 
        player_profile.player_id,
        player_profile.player_name,
        SUM(player_statistic.score) AS total_goals,
        SUM(player_statistic.assist) AS total_assists,
        SUM(player_statistic.yellow_cards) AS total_yellow_cards,
        SUM(player_statistic.red_cards) AS total_red_cards,
        (SUM(player_statistic.score) + SUM(player_statistic.assist)) AS total_contributions,
        (SUM(player_statistic.yellow_cards) + SUM(player_statistic.red_cards)) AS total_cards
    FROM player_profile
    INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
    INNER JOIN match ON player_statistic.match_id = match.match_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    INNER JOIN league ON league.league_id = league_organ.league_id
    WHERE  league.league_name = '...' AND league_organ.season = '...'
    GROUP BY player_profile.player_id
),
best_players AS 
(
    SELECT 
        player_id, 
        player_name, 
        total_goals,
        total_assists,
        total_contributions,
        total_cards,
        RANK() OVER (ORDER BY total_contributions DESC, total_cards ASC) AS ranking
    FROM player_stats
)
SELECT 
    player_id, 
    player_name, 
    total_goals, 
    total_assists, 
    total_contributions, 
    total_cards
FROM best_players
WHERE ranking = 1;


--13. Liệt kê các clb trong giải đấu ... ở mùa giải 2023-2024 được tham gia vào giải đấu cup "UEFA Champion League" năm sau
--    Biết rằng giải đấu có thể thức "Đấu vòng tròn" và clb nằm trong top 4 của bảng xếp hạng năm đó.
SELECT club.club_name
FROM club
INNER JOIN premierleague_20232024_ranking ON club.club_id = premierleague_20232024_ranking.club_id -- Co the thay bang cac giai khac
WHERE ranking <= 4;

--14. Liệt kê các clb trONg giải đấu ... ở mùa giải 2023-2024 được tham gia vào giải đấu cup "UEFA Europe League" năm sau
--    Biết rằng các clb được chọn ra từ giải đấu có thể thức "Đấu vòng tròn" ở vị trí thứ 5 và 6 hoặc các clb vô địch giải đấu có thể thức
--    "Đấu cup".
SELECT club.club_name
FROM club
INNER JOIN premierleague_20232024_ranking ON club.club_id = premierleague_20232024_ranking.club_id -- Co the thay bang cac giai khac
WHERE ranking IN (5, 6)
UNION
SELECT club.club_name 
FROM club 
INNER JOIN premierleague_20232024_ranking ON club.club_id = premierleague_20232024_ranking.club_id
INNER JOIN home ON home.club_id = club.club_id
INNER JOIN away ON away.club_id = club.club_id
INNER JOIN match ON match.match_id = home.match_id
WHERE match.round = 'Chung kết' 
    AND  premierleague_20232024_ranking.ranking > 6
    AND (home.num_of_goals > away.num_of_goals OR (home.num_of_goals = away.num_of_goals AND home.penalties > away.penalties))
;

-- 16. In ra tên cầu thủ có nhiều bàn thắng nhất trong 5 giải đấu "Premier League", "Laliga", "Bundesliga", "Seria", "Ligue 1" trong mùa giải '...'
WITH player_goals AS 
(
    SELECT 
        player_profile.player_name,
        league.league_name,
        league_organ.season,
        SUM(player_statistic.score) AS total_goals
    FROM player_profile
    INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
    INNER JOIN match ON player_statistic.match_id = match.match_id
    INNER JOIN league_organ ON match.season_id = league_organ.season_id
    INNER JOIN league ON league.league_id = league_organ.league_id
    WHERE league.league_name IN ('Premier League', 'LaLiga', 'Bundesliga', 'Serie A', 'Ligue 1') 
        AND league_organ.season = '...'
    GROUP BY player_profile.player_id, league.league_name, league_organ.season
),
top_scorer AS 
(
    SELECT 
        player_id, 
        player_name, 
        total_goals,
        RANK() OVER (ORDER BY total_goals DESC) AS ranking
    FROM player_goals
)
SELECT 
    player_id, 
    player_name, 
    total_goals
FROM top_scorer
WHERE ranking = 1;


-- 17. In ra tong số bàn thắng và số kiến tạo của cac cầu thủ trong màu áo của clb ... trong thời gian thi đấu,
SELECT player_profile.player_name, SUM(player_statistic.score) as total_scores, SUM(player_statistic.assist) as total_assissts
FROM player_profile
INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club on player_role.player_id = club.club_id
WHERE club.club_name = '...' AND player_role.transfer_date <= NOW()
GROUP BY player_profile.player_id
ORDER BY total_goals DESC, total_assissts DES; 

--18. In ra thông tin cầu thủ có điểm rating cao nhất trong vòng đấu ... của giải đấu .. ở mùa giải ..
SELECT 
    player_profile.player_name,
    player_profile.player_id,
    player_statistic.rating,
    match.round,
    league.league_name,
    league_organ.season
FROM player_statistic
INNER JOIN player_profile ON player_statistic.player_id = player_profile.player_id
INNER JOIN match ON player_statistic.match_id = match.match_id
INNER JOIN league_organ ON match.season_id = league_organ.season_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE 
    AND league.league_name = '...' 
    AND league_organ.season = '...'
ORDER BY player_statistic.rating DESC
LIMIT 1;



-- 20. Tìm cầu thủ thi đấu nhiều trận nhất trong giải đấu ... ở mùa giải ...
SELECT player_profile.player_name, COUNT(player_statistic.player_id) AS num_of_matches 
FROM player_profile
LEFT JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
LEFT JOIN match ON player_statistic.match_id = match.match_id
LEFT JOIN participation on participation ON match.parti_id = participation.parti_id
WHERE participation.league_id = '...'  AND participation.season = '...';

-- 23. Liệt kê cầu thủ có ... bàn thắng trở lên trong mùa giải ... ở giải đấu ...
SELECT player_profile.player_name, club.club_name, SUM(player_statistic.score) AS 'total score'
FROM player_profile
INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club ON club.club_id = player_role.club_id
INNER JOIN participation ON club.club_id = participation.parti_id
INNER JOIN league ON league.league_id = participation.parti_id
WHERE 'total score' > ... AND participation.season = ... AND league.league_name = ...
GROUP BY player_profile.player_id
ORDER BY 'total score' DESC;

-- 24. Trung bình số bàn thắng ghi được trong 1 trận của giải đấu ... ở mùa giải ...
SELECT player_profile.player_name, club.club_name, AVG(player_statistic.score) AS 'avg score'
FROM player_profile
INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club ON club.club_id = player_role.club_id
INNER JOIN participation ON club.club_id = participation.parti_id
INNER JOIN league ON league.league_id = participation.parti_id
AND participation.season = ... AND league.league_name = ...
GROUP BY player_profile.player_id;

--25. Thứ hạng trung bình của clb ... trong giải đấu ... từ mùa giải ... đến nay.
SELECT 
    club.club_name,
    AVG(league_organ.ranking) AS average_ranking
FROM club
INNER JOIN league_organ ON club.club_id = league_organ.club_id
INNER JOIN league ON league_organ.league_id = league.league_id
WHERE league.league_name = '...'
    AND league_organ.season >= '...'
GROUP BY club.club_name;

--26. Liet ke cac tran dau co tong so ban thang ghi duoc nhieu nhat

--27. Liet ke cac tran dau co ti so thang thua dam nhat