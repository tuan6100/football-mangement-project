#ifndef QUERY_H
#define QUERY_H
#include <iostream>
#include <string>
#include <vector>
#include <fstream>
#include <iomanip>
#include <pqxx/pqxx>

using namespace std;
const string pghost = "postgresql://tuan:20226100@localhost:5432/footballdb";


struct football
{
    vector<string> nation;
    vector<string> league;
    vector<string> club;
    vector<string> player;
    vector<string> manager;
};

class QUERY
{
    private:
        const string postgres = "psql -d footballdb -U tuan -c ";
        string command, query;
    
    public:
        QUERY(string query)
        {
            this->query = query;
            this->command = postgres + "\"" + query + " \"";
        }
        
        void display()
        {
            cout << this->query + " ;\n" << endl;
            system(this->command.c_str());
        }
         
        friend void query_1st();
        friend void query_2nd();
        friend void query_3rd();
        friend void query_4th(); 
        friend void query_5th();
        friend void query_6th();
        friend void query_7th();
        friend void query_8th();
        friend void query_9th();
        friend void query_10th();

};

pqxx::connection connect_to_db(const string& host);
void makelist(pqxx::connection& db, const string& query);
void query_1st();
void query_2nd();
void query_3rd();
void query_4th(); 
void query_5th();
void query_6th();
void query_7th();
void query_8th();
void query_9th();
void query_10th();

#endif
