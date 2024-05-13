
--1. Liệt kê danh sách cầu thủ có quốc tịch ... và thi đấu ở clb ...

SELECT player_profile.player_name 
from player_profile
inner join player_role ON player_profile.player_id = player_role.player_id
inner join club ON club.club_id = player_role.player_id
inner join natiON ON player_profile.natiON_id = natiON.natiON_id
WHERE club.club_name = '...' and  natiON.natiON_name= '...';

--4. Liệt kê tổng số bàn thắng/kiến tạo cầu thủ ghi được trong mùa giải ...
select 
     player_profile.player_name, 
     SUM(player_statistic.score + player_statistic.assist) as total_score_assist
from player_profile
inner join player_statistic ON player_statistic.player_id = player_profile.player_id
inner join match ON player_statistic.match_id = match.match_id
where player_profile.player_name = "..." 
      AND EXTRACT(YEAR FROM match.date_of_match) in (2023, 2024)
GROUP BY player_profile.player_name;

--7. In ra lịch sử đối đấu giữa 2 đội bóng ... và ... từ năm ... đến năm ...
--   Thông tin in ra bao gồm mùa giải, tên giải đấu, vòng đấu, tỉ số trận đấu.
SELECT
    league.league_name,
    EXTRACT(YEAR FROM match.date_of_match) AS season,
    match.round,
    match.date_of_match,
    (CAST(home.num_of_goals AS CHAR) || '-' || CAST(away.num_of_goals AS CHAR)) AS match_score
FROM match
INNER JOIN home ON match.match_id = home.match_id
INNER JOIN away ON match.match_id = away.match_id
INNER JOIN league ON match.league_id = league.league_id
WHERE
    (home.club_id = '...' AND away.club_id = '...')
    OR (home.club_id = '...' AND away.club_id = '...');


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

--13. Liệt kê các clb trong giải đấu ... ở mùa giải ... được tham gia vào giải đấu cup "UEFA Champion League" năm sau
--    Biết rằng giải đấu có thể thức "Đấu vòng tròn" và clb nằm trong top 4 của bảng xếp hạng năm đó.
SELECT club.club_name
FROM club
INNER JOIN premierleague_20232024_ranking ON club.club_id = premierleague_20232024_ranking.club_id -- Co the thay bang cac giai khac
WHERE ranking <= 4

--14. Liệt kê các clb trONg giải đấu ... ở mùa giải ... được tham gia vào giải đấu cup "UEFA Europe League" năm sau
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

-- 17. In ra tong số bàn thắng và số kiến tạo của cac cầu thủ trong màu áo của clb ... trong thời gian thi đấu,
SELECT player_profile.player_name, SUM(player_statistic.score) as total_scores, SUM(player_statistic.assist) as total_assissts
FROM player_profile
INNER JOIN player_statistic ON player_profile.player_id = player_statistic.player_id
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club on player_role.player_id = club.club_id
WHERE club.club_name = '...' AND player_role.transfer_date <= NOW()
GROUP BY player_profile.player_id
ORDER BY total_goals DESC, total_assissts DES; 

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
INNER jOIN club ON club.club_id = player_role.club_id
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
INNER jOIN club ON club.club_id = player_role.club_id
INNER JOIN participation ON club.club_id = participation.parti_id
INNER JOIN league ON league.league_id = participation.parti_id
AND participation.season = ... AND league.league_name = ...
GROUP BY player_profile.player_id;

--25. Thứ hạng trung bình của clb ... trong giải đấu ... từ mùa giải ... đến nay.
