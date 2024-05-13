#include "query.h"

// SELECT
//     league.league_name,
//     EXTRACT(YEAR FROM match.date_of_match) AS season,
//     match.round,
//     match.date_of_match,
//     (CAST(home.num_of_goals AS CHAR) || '-' || CAST(away.num_of_goals AS CHAR)) AS match_score
// FROM match
// INNER JOIN home ON match.match_id = home.match_id
// INNER JOIN away ON match.match_id = away.match_id
// INNER JOIN league ON match.league_id = league.league_id
// WHERE
//     (home.club_id = '...' AND away.club_id = '...')
//     OR (home.club_id = '...' AND away.club_id = '...');


void query_7th()
{
    football fbhome, fbaway;
    string line, list;
    pqxx::connection db = connect_to_db(pghost);

    cout << "Select home club: " << endl;
    list = "select club.club_name from club";
    makelist(db, list);
    ifstream file("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        fbhome.club.push_back(line);
    file.close();  

    cout << "Select away club: " << endl;
    list = "select club.club_name from club";
    makelist(db, list);
    ifstream file1("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        fbaway.club.push_back(line);
    file1.close();  

    for (auto home : fbhome.club)
    {
        for (auto away : fbaway.club)
        {
            string query = R"(
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
    (home.club_id = ')" + home + R"(' AND away.club_id = ')" + away + R"('
    OR (home.club_id = ')" + away + R"(' AND away.club_id = ')" + home + R"(';
)";

        QUERY qr(query);
        qr.display();
        }
    }
}