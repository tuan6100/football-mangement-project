
#include "query.h"


int main()
{
  int choice;
  char c;

  system("clear");

  cout << 
  R"(             __        __   _                            _                           
             \ \      / /__| | ___ ___  _ __ ___   ___  | |_ ___     ___  _   _ _ __  
              \ \ /\ / / _ \ |/ __/ _ \| '_ ` _ \ / _ \ | __/ _ \   / _ \| | | | '__|
               \ V  V /  __/ | (_| (_) | | | | | |  __/ | || (_) | | (_) | |_| | |   
                \_/\_/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/   \___/ \__,_|_|  
                   __| | ___ _ __ ___   ___    _ __  _ __ ___ (_) ___  ___| |_        
                  / _` |/ _ \ '_ ` _ \ / _ \  | '_ \| '__/ _ \| |/ _ \/ __| __|         
                 | (_| |  __/ | | | | | (_) | | |_) | | | (_) | |  __/ (__| |_   
                  \__,_|\___|_| |_| |_|\___/  | .__/|_|  \___// |\___|\___|\__|    
                                              |_|           |__/               )" << endl;
   
  label: do
  {
    cout << R"(
    1. Display data in the database
    2. Query in the database
    0. Quit

    Please select your option: )";
    cin >> choice;
    switch(choice)
    {
      case 0: {
            string promp = R"(gum confirm && echo "yes" > ../SOURCE_FILES/store.txt || echo "no" > ../SOURCE_FILES/store.txt)";
            system(promp.c_str());
            ifstream file("../SOURCE_FILES/store.txt");
            string s;
            while (getline(file, s)) 
            {            
            //cout << s << endl;
              if (s == "yes")
              {
                  file.close();
//                   cout << right << setw(10) << R"(
//  ____ ___ _   _ _   _ _   _ _   _ _   _ _   _ _   _ 
// / ___|_ _| | | | | | | | | | | | | | | | | | | | | |
// \___ \| || | | | | | | | | | | | | | | | | | | | | |
//  ___) | || |_| | |_| | |_| | |_| | |_| | |_| | |_| |
// |____/___|\___/ \___/ \___/ \___/ \___/ \___/ \___/ 
             
//                   )";
                  system("gum spin --spinner globe --title Bye -- sleep 3");
                  system("clear");                 
                  return 1;
             }
              else if (s == "no")
             {
                  file.close();
                  goto label; 
             }            
            }
            break;
      }

      case 1: {
            cout << "List of tables:" << endl;
            QUERY qr("\\d"); 
            qr.display();
            break;
      }
      case 2: {
            cout << "List of queries you should try:" << endl;
            system("gum style >  ../../Data/query-fm.txt");
            int option;
            cout << "Enter your choice: ";
            cin >> option;
            switch (option)
            {
            case 1:
                  query_1st();   
                  cout << "Press Tab+Enter to continue..." << endl;                 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;
            
            case 2:
                  query_2nd();   
                  cout << "Press Tab+Enter to continue..." << endl;                 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;
            
            case 3:
                  query_3rd();   
                  cout << "Press Tab+Enter to continue..." << endl;                 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;
            

            case 4:
                  query_4th();   
                  cout << "Press Enter to continue..." << endl; 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;

            // case 5:
            //       query_5th();   
            //       cout << "Press any key to continue..." << endl; 
            //       fflush(stdin);
            //       getchar();
            //       break;

            // case 6:
            //       query_6th();   
            //       cout << "Press any key to continue..." << endl; 
            //       fflush(stdin);
            //       getchar();
            //       break;

            case 7:
                  query_7th();   
                  cout << "Press Tab+Enter to continue..." << endl;                 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;
            
            
            case 8:
                  query_8th();
                  cout << "Press Tab+Enter to continue..." << endl;                 
                  fflush( stdout );
                  do c = getchar(); while ((c != '\t') && (c != EOF));
                  break;
            
                  
            // case 9:
            //       query_9th();   
            //       cout << "Press any key to continue..." << endl; 
            //       fflush(stdin);
            //       getchar();
            //       break;

            // case 10:
            //       query_10th();   
            //       cout << "Press any key to continue..." << endl; 
            //       fflush(stdin);
            //       getchar();
            //       break;
            
            default:
                 cout << "Thank you!" << endl;
                 break;
            }
             
            system("gum spin --spinner dot --title \"Loading\" -- sleep 3");       
            break;
      }
      default: {
            cout << "Invalid choice\n" << endl;
            break;
      }
    }

  }
  while (choice != 0);

 
 
  return 0;
}



