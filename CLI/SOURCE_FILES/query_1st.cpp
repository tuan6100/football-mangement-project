#include "query.h"

/*SELECT player_profile.player_name
from player_profile
inner join player_role ON player_profile.player_id = player_role.player_id
inner join club ON club.club_id = player_role.club_id
inner join natiON ON player_profile.natiON_id = natiON.natiON_id
WHERE club.club_name = '...' and  natiON.natiON_name= '...';*/

void query_1st()
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

    cout << "list of nation" << endl;
    list = "select nation.nation_name from nation";
    makelist(db, list);
    ifstream file1("../SOURCE_FILES/store.txt");
    while (getline(file1, line))
        fb.nation.push_back(line);
    file1.close();
    
    for (auto club : fb.club)
    {
        for (auto nation : fb.nation)
        {
            string query = R"(
SELECT player_profile.player_name 
from player_profile
INNER JOIN player_role ON player_profile.player_id = player_role.player_id
INNER JOIN club ON club.club_id = player_role.club_id
INNER JOIN nation ON player_profile.nation_id = nation.nation_id
WHERE club.club_name = ')" +  club + R"(' AND nation.nation_name = ')" + nation + "'";
        QUERY qr(query);
        qr.display();
        }
    }   
}
