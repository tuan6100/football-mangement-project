#include "query.h"
// select 
//      player_profile.player_name, 
//      SUM(player_statistic.score + player_statistic.assist) as total_score_assist
// from player_profile
// inner join player_statistic ON player_statistic.player_id = player_profile.player_id
// inner join match ON player_statistic.match_id = match.match_id
// where player_profile.player_name = "..." 
//       AND EXTRACT(YEAR FROM match.date_of_match) = 2024
// GROUP BY player_profile.player_name;

void query_4th()
{
    football fb;
    string line, list;
    pqxx::connection db = connect_to_db(pghost);

    cout << "List of player" << endl;
    list = "select player_name from  player_profile";
    makelist(db, list);
    ifstream file("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        fb.club.push_back(line);
    file.close();

    for (auto player : fb.player)
    {
            string query = R"(
select 
     player_profile.player_name, 
     SUM(player_statistic.score + player_statistic.assist) as total_score_assist
from player_profile
inner join player_statistic ON player_statistic.player_id = player_profile.player_id
inner join match ON player_statistic.match_id = match.match_id
where player_profile.player_name = ')" + player + R"('
      and extract(year from match.date_of_match) in (2023, 2024)
group by player_profile.player_name;
)";
        QUERY qr(query);
        qr.display();
    }   
}
