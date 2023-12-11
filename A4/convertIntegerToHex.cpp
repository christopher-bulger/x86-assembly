#include <iostream>
#include <string>
#include <vector>
using namespace std;

int main(){
    //Parameters: signed dword int, byte array size 11

    //check if integer is negative
        //if negative, store -1 sign and multiply 
        //by -1 to make positive.
    //array[0] = '0', array[1] = 'X', array[Length - 1] = NULL
    //while integer != 0
        //integer /= 16
        //if remainder 0-9, array [i] = remainder + 48
        //else array[i] = remainder + 55
        //i--
    
    int integer = 200;
    int sign = -1;
    int remainder, index;
    char array[10];
    bool failure = false;

    if(integer < 0){
        integer *= - 1;
        sign = -1;
    }  

    array[0] = '0';
    array[1] = 'X';

    index = 9;
    while(integer != 0){
        remainder = integer % 16;
        integer /= 16;

        if(remainder >= 0 && remainder <= 9)
            array[index] = remainder + 48;
        else{
            array[index] = remainder + 55;
        }
        index --;
        if(index == 1){
            cout << "NUMBER TOO BIG" << endl;
            failure = true;
            break;
        }
    }

    if(failure)
        cout << "FAILURE" << endl;
    else{
        for(int i = 2; i <= index; i++){
            array[i] = '0';
        } 
        for(int i = 0; i < 10; i++){
            cout << array[i];
        }
        cout << endl;
    }

    return 0;
}
