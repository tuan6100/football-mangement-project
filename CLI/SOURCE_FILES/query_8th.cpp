    #include "query.h"

    // SELECT 
    //     club.club_id, club.club_name,
    //     SUM(CASE 
    //         WHEN home.num_of_goals > away.num_of_goals THEN 3
    //         WHEN home.num_of_goals = away.num_of_goals THEN 1
    //         ELSE 0
    //     END) AS point,
    //     COUNT(CASE WHEN home.num_of_goals > away.num_of_goals THEN 1 END) as win,
    //     COUNT(CASE WHEN home.num_of_goals = away.num_of_goals THEN 1 END) as draw,
    //     COUNT(CASE WHEN home.num_of_goals < away.num_of_goals THEN 1 END) as lose
    // FROM match
    // INNER JOIN home ON match.match_id = home.match_id
    // INNER JOIN away ON match.match_id = away.match_id
    // INNER JOIN club ON club.club_id = home.club_id
    // INNER JOIN league ON match.league_id = league.league_id
    // WHERE league.league_name = '...' 
    // GROUP BY club.club_id;

void query_8th()
{
    football fb;
    string line, list;
    pqxx::connection db = connect_to_db(pghost);

    cout << "List of league" << endl;
    list = "select league.league_name from league";
    makelist(db, list);
    ifstream file("../SOURCE_FILES/store.txt");
    while (getline(file, line))
        fb.club.push_back(line);
    file.close();  
    
    for (auto league : fb.league)
    {
            string query = R"(
    SELECT 
        club.club_id, club.club_name,
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
    INNER JOIN league ON match.league_id = league.league_id
    WHERE league.league_name = ')" + league + R"('
    GROUP BY club.club_id;
)";
        QUERY qr(query);
        qr.display();
    }   
}