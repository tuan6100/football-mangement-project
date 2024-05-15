#include "query.h"

pqxx::connection connect_to_db(const string& host) 
{
    pqxx::connection db(host);
    if (!db.is_open()) {
        throw std::runtime_error("Failed to connect to the database.");
    }
    return db;
}

void makelist(pqxx::connection& db, const string& query)
{

    pqxx::work txn(db);
    pqxx::result result = txn.exec(query);
    txn.commit(); 
    ofstream file2("../SOURCE_FILES/data.txt");
    if (!file2.is_open())
        cout << "Error: Cannot open file" << endl;
    else {
    for (auto row : result)
    {
        for (auto field : row)
        {
            file2 << field.c_str() << endl;
        }
        cout << endl;
    }
    file2.close();
    string promp = R"(gum choose --no-limit --header="Press Space to choose" < ../SOURCE_FILES/data.txt > ../SOURCE_FILES/store.txt)";
    system(promp.c_str());
    }
    //system("rm $HOME/Documents/Code/SQL/Project/football/CLI/SOURCE_FILES/data.txt");
}
