#include <iostream>
#include <fstream>
using namespace std;

int main(){
    string fileName;
    ifstream infile;
    bool c = false;
    bool f = false;
    int count;

    //  ./a.out -c 1000 -f filename.txt 


    // argc = 5

    for(int i = 0; i < argc; i++){
        //compare argv[i] to "-c"
            //c = true;
            //count = argv[i + 1]
        //compare argv[i] to "-f"
            //f = true;
            //fileName = argv[i + 1]
        //
    }

    //check if we have found -c and -f (if statement)
        //if not found, output error
        //end program

    infile.open(fileName);


    return 0;
}