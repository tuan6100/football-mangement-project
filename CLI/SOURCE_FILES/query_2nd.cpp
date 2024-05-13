#include <query.h>
// SELECT
//     player_profile.player_name,
//     SUM(CASE WHEN p.score >= 0 THEN p.score ELSE 0 END) AS total_goals,
//     SUM(p.assist) AS total_assists
// FROM
//     player_statistic as p
// INNER JOIN player_profile ON p.player_id = player_profile.player_id
// INNER JOIN match m ON p.match_id = m.match_id
// WHERE
//     player_profile.player_name SIMILAR TO '(...|...)%'
//     AND m.date_of_match >= '1/2/2023'
//     AND m.date_of_match <= CURRENT_DATE
// GROUP BY player_profile.player_id;

void query_2nd()
{
    string line, list, players ="";
    pqxx::connection db = connect_to_db(pghost);

    cout << "List of player" << endl;
    list = "select player_name from player_profile";
    makelist(db, list);
    ifstream file("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        players += line + "|";
    file.close();  
    
    string date;
    cout << "Enter date: ";
    cin >> date;

    string query = R"(
SELECT
    player_profile.player_name,
    SUM(CASE WHEN p.score >= 0 THEN p.score ELSE 0 END) AS total_goals,
    SUM(p.assist) AS total_assists
FROM
    player_statistic as p
INNER JOIN player_profile ON p.player_id = player_profile.player_id
INNER JOIN match m ON p.match_id = m.match_id
WHERE
    player_profile.player_name SIMILAR TO '()" + players + R"()%' 
    AND m.date_of_match >= ')" + date + R"('
    AND m.date_of_match <= CURRENT_DATE
    GROUP BY player_profile.player_id;
)";
        QUERY qr(query);
        qr.display();  
}