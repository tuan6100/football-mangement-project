#include <query.h>

// SELECT 
//     player_profile.player_name, 
//     COUNT(match.match_id) AS "num_of_matches"
// FROM  player_statistic
// INNER JOIN player_profile ON player_statistic.player_id = player_profile.player_id 
// INNER JOIN player_role ON player_statistic.player_id = player_role.player_id
// INNER JOIN match ON player_statistic.match_id = match.match_id
// INNER JOIN club ON player_role.club_id = club.club_id
// WHERE club.club_name = '...'  
//       AND player_profile.player_name = '...'  
//       AND EXTRACT(YEAR FROM match.date_of_match) >= ...
// GROUP BY player_profile.player_name;

void query_3rd()
{
    football fb;
    string line, list;
    pqxx::connection db = connect_to_db(pghost);

    cout << "List of club" << endl;
    list = "select club.club_name from club";
    makelist(db, list);
    ifstream file("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        fb.club.push_back(line);
    file.close();  

    string clubs = "where ";
    for(auto club : fb.club)
        clubs += "club.club_name = '" + club + "' or ";
    clubs.pop_back();
    clubs.pop_back();
    clubs.pop_back();
    clubs += ";";

    cout << "list of nation" << endl;
    list = R"(select player_profile.player_name from player_profile 
              inner join player_role on player_profile.player_id = player_role.player_id
              inner join club on player_role.club_id = club.club_id )" + clubs;
    makelist(db, list);
    ifstream file1("../SOURCE_FILES/store.txt");
    while (getline(file1, line))
        fb.player.push_back(line);
    file1.close();

    string year;
    cout << "Enter year: ";
    cin >> year;

    for (auto club : fb.club)
    {
        for (auto player : fb.player)
        {
            string query = R"(
SELECT 
    player_profile.player_name, 
    COUNT(match.match_id) AS "num_of_matches"
FROM  player_statistic
INNER JOIN player_profile ON player_statistic.player_id = player_profile.player_id 
INNER JOIN player_role ON player_statistic.player_id = player_role.player_id
INNER JOIN match ON player_statistic.match_id = match.match_id
INNER JOIN club ON player_role.club_id = club.club_id
WHERE club.club_name = ')" +  club + R"(' 
AND player_profile.player_name = ')" + player + R"('
AND EXTRACT(YEAR FROM match.date_of_match) >= ')" + year + R"('
GROUP BY player_profile.player_name ;)";
        QUERY qr(query);
        qr.display();
        }
    }   
}