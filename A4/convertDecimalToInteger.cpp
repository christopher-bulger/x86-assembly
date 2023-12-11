#include <iostream>
#include <string>
using namespace std;

/* value = 0
for each digit starting from the left
    value = value x 10
    value = value + digit
if (sign == ‘-’) value = value * -1 */

int main(){
    string decimalNum = "0";
    int sign = 1;
    int value = 0;
    int digit;
    int i = 0;

    while(decimalNum[i] == ' ')
        i++;
    
    if(decimalNum[i] == '-'){
        sign = -1;
        i++;
    }

    if(decimalNum[i] == '+')
        i++;

    while(decimalNum[i] == ' ')
        i++;

    while(decimalNum[i] != ' '){
        digit = decimalNum[i] - '0';
        value *= 10;
        value += digit; 
        i++;

        if(!decimalNum[i]){
            cout << "End of string" << endl;
            break;
        }
    }  

    while(decimalNum[i] == ' '){
        i++;

        if(!decimalNum[i]){
            cout << "End of string" << endl;
            break;
        }
    }
    
    cout << value * sign << endl;
    

    return 0;
}