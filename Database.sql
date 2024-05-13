2)
SELECT
    SUM(p.score) AS total_goals,
    SUM(p.assist) AS total_assists
FROM
    Player Statistic p
JOIN
    Match m ON p.match_id = m.match_id
WHERE
    p.player_id = '...'
    AND m.date_of_match >= '...'
    AND m.date_of_match <= CURRENT_DATE;


5)
SELECT
    c.club_name AS club,
    ph.year AS year
FROM
    Football Club c
JOIN
    Player Roll pr ON c.club_id = pr.club_id
JOIN
    Player Honours ph ON pr.player_id = ph.player_id
JOIN
    League l ON ph.league_id = l.league_id
WHERE
    l.league_name = '...'
    AND ph.year = ...
    AND ph.honours = 'Champion';


8)
SELECT
    FC.club_name,
    COUNT(CASE WHEN HM.num_of_goals > AM.num_of_goals THEN 1 END) AS Wins,
    COUNT(CASE WHEN HM.num_of_goals = AM.num_of_goals THEN 1 END) AS Draws,
    COUNT(CASE WHEN HM.num_of_goals < AM.num_of_goals THEN 1 END) AS Defeateds,
    (COUNT(CASE WHEN HM.num_of_goals > AM.num_of_goals THEN 1 END) * 3 +
    COUNT(CASE WHEN HM.num_of_goals = AM.num_of_goals THEN 1 END)) AS Points
FROM
    Football_Club FC
JOIN Participation P ON FC.club_id = P.club_id
JOIN League L ON P.league_id = L.league_id
JOIN Match M ON M.date_of_match BETWEEN '2023-09-09' AND '2024-08-01'
LEFT JOIN Home_Match HM ON M.match_id = HM.match_id AND HM.club_id = FC.club_id
LEFT JOIN Away_Match AM ON M.match_id = AM.match_id
WHERE
    L.league_name = 'Premier League' AND
    FC.club_name = 'ABC' AND
    P.season = '2023-2024'
GROUP BY
    FC.club_name;



INSERT INTO public.home (match_id, club_id, ball_possession, num_of_goals, total_shots, shots_on_target, corner_kicks, offsides, fouls, penalties)
VALUES
('##MUNLIV240407', 'MUN', 38, 2, 9, 5, 6, 3, 9, NULL),
('##MCIARS240331', 'MCI', 73, 0, 12, 1, 7, 2, 9, NULL),
('##LIVMCI240310', 'LIV', 53, 1, 19, 6, 7, 6, 6, NULL),
('##MCIMUN240303', 'MCI', 73, 3, 27, 8, 15, 0, 5, NULL),
('##MCICHE240218', 'MCI', 71, 1, 31, 5, 12, 0, 7, NULL),
('##ARSLIV240204', 'ARS', 42, 3, 15, 7, 2, 3, 11, NULL),
('##LIVMUN231217', 'LIV', 69, 0, 34, 8, 12, 4, 13, NULL),
('##MCITOT231203', 'MCI', 55, 3, 17, 4, 10, 2, 14, NULL),
('##MCILIV231125', 'MCI', 60, 1, 16, 5, 9, 3, 9, NULL),
('##CHEMCI231112', 'CHE', 45, 4, 17, 9, 3, 1, 13, NULL),
('##TOTCHE231107', 'TOT', 38, 1, 8, 5, 1, 3, 12, NULL),
('##MUNMCI231029', 'MUN', 39, 0, 7, 3, 7, 4, 9, NULL),
('##ARSMCI231008', 'ARS', 49, 1, 12, 2, 5, 2, 8, NULL),
('##TOTLIV230930', 'TOT', 65, 2, 24, 8, 11, 4, 11, NULL),
('##ARSTOT230924', 'ARS', 46, 2, 13, 6, 11, 2, 12, NULL),
('##ARSMUN230903', 'ARS', 55, 3, 17, 5, 12, 2, 8, NULL),
('##MUNLIV240317', 'MUN', 41, 4, 28, 11, 5, 3, 11, NULL),
('##MCICHE240420', 'MCI', 63, 1, 14, 3, 8, 3, 9, NULL),
('##CHELIV230813', 'CHE', 65, 1, 10, 4, 4, 3, 5, NULL),
('##RMABAR240422', 'RMA', 46, 3, 14, 8, 2, 1, 11, NULL),
('##ATMBAR240318', 'ATM', 40, 0, 13, 3, 7, 8, 15, NULL),
('##RMAATM240205', 'RMA', 55, 1, 17, 4, 2, 2, 6, NULL),
('##BARRMA231028', 'BAR', 52, 1, 15, 3, 6, 1, 15, NULL),
('##LEVBAY240211', 'LEV', 39, 3, 14, 8, 4, 3, 13, NULL),
('##BAYDOR240331', 'BAY', 61, 0, 17, 2, 7, 2, 7, NULL),
('##DORLEV20240421', 'DOR', 48, 1, 8, 2, 2, 0, 14, NULL),
('##ARSCHE24/4/24', 'ARS', 44, 5, 27, 10, 4, 3, 12, NULL);

INSERT INTO public.away (match_id, club_id, ball_possession, num_of_goals, total_shots, shots_on_target, corner_kicks, offsides, fouls, penalties)
VALUES
('#MUNLIV240407', 'LIV', 62, 2, 28, 7, 11, 2, 10, NULL),
('#MCIARS240331', 'ARS', 27, 0, 6, 2, 4, 1, 20, NULL),
('#LIVMCI240310', 'MCI', 47, 1, 10, 6, 4, 1, 10, NULL),
('#MCIMUN240303', 'MUN', 27, 1, 3, 1, 2, 1, 10, NULL),
('#MCICHE240218', 'CHE', 29, 1, 9, 6, 1, 5, 12, NULL),
('#ARSLIV240204', 'LIV', 58, 1, 10, 1, 4, 1, 11, NULL),
('#LIVMUN231217', 'MUN', 31, 0, 6, 1, 0, 2, 6, NULL),
('#MCITOT231203', 'TOT', 45, 3, 8, 4, 8, 2, 14, NULL),
('#MCILIV231125', 'LIV', 40, 1, 8, 3, 6, 4, 11, NULL),
('#CHEMCI231112', 'MCI', 55, 4, 15, 10, 3, 0, 15, NULL),
('#TOTCHE231107', 'CHE', 62, 4, 17, 8, 6, 7, 21, NULL),
('#MUNMCI231029', 'MCI', 61, 3, 21, 10, 12, 0, 5, NULL),
('#ARSMCI231008', 'MCI', 51, 0, 4, 2, 4, 2, 7, NULL),
('#TOTLIV230930', 'LIV', 35, 1, 12, 4, 5, 1, 17, NULL),
('#ARSTOT230924', 'TOT', 54, 2, 13, 5, 4, 3, 19, NULL),
('#ARSMUN230903', 'MUN', 45, 1, 10, 2, 3, 2, 8, NULL),
('#MUNLIV240317', 'LIV', 59, 3, 25, 11, 8, 4, 12, NULL),
('#MCICHE240420', 'CHE', 37, 0, 10, 5, 4, 2, 11, NULL),
('#CHELIV230813', 'LIV', 35, 1, 13, 1, 4, 5, 13, NULL),
('#RMABAR240422', 'BAR', 54, 2, 15, 6, 8, 2, 12, NULL),
('#ATMBAR240318', 'BAR', 60, 3, 9, 5, 3, 3, 9, NULL),
('#RMAATM240205', 'ATM', 45, 1, 10, 5, 8, 1, 15, NULL),
('#BARRMA231028', 'RMA', 48, 2, 13, 4, 3, 0, 15, NULL),
('#LEVBAY240211', 'BAY', 61, 0, 9, 1, 6, 1, 13, NULL),
('#BAYDOR240331', 'DOR', 39, 2, 11, 5, 7, 2, 7, NULL),
('#DORLEV20240421', 'LEV', 52, 1, 13, 3, 2, 0, 11, NULL),
('#ARSCHE24/4/24', 'CHE', 56, 0, 7, 1, 2, 0, 11, NULL),
('#LIVCHE240201', 'CHE', 49, 1, 4, 3, 1, 3, 16, NULL);
