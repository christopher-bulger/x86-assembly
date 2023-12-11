#include<iostream>
using namespace std;

int main(){
    const int LENGTH = 50;
    int sum = 0, min, max, ave, oddCount = 0, evenCount = 0;

    int list1[LENGTH] = {2078, 3854, 6593, 947, 5252, 1190, 716, 3587, 8014, 9563,
                        9821, 3195, 1051, 6454, 5752, 980, 9015, 2478, 5624, 7251,
                        2936, 1073, 1731, 5376, 4452, 792, 2375, 2542, 5666, 2228,
                        454, 2379, 6066, 3340, 2631, 9138, 3530, 7528, 7152, 1551,
                        9537, 9590, 2168, 9647, 5362, 2728, 5939, 4620, 1828, 5736};

    int list2[LENGTH] = {5087, 6614, 6035, 6573, 6287, 5624, 4240, 3198, 5162, 6972,
                        6219, 1331, 1039, 23, 4540, 2950, 2758, 3243, 1229, 8402,
                        8522, 4559, 1704, 4160, 6746, 5289, 2430, 9660, 702, 9609,
                        8673, 5012, 2340, 1477, 2878, 2331, 3652, 2623, 4679, 6041,
                        4160, 2310, 5232, 4158, 5419, 2158, 380, 5383, 4140, 1874};

    int list3[LENGTH];

    for(int i = 0; i < LENGTH; i++){

        list3[i] = (list1[i] + list2[i]) / 2;

        if(i == 0){
            min = list3[i];
            max = list3[i];
        }      
        else{
            if(list3[i] < min)
                min = list3[i];
            if(list3[i] > max)
                max = list3[i];
        }

        if(list3[i] % 2 == 0)
            evenCount++;
        else{
            oddCount++;
        }
        
        sum += list3[i]; 
    }
    
    ave = sum / LENGTH;

    cout << "LIST 3" << endl;
    for(int i = 0; i < LENGTH; i++){
        if(i != 0 && i % 10 == 0)
            cout << endl;
        cout << list3[i] << " ";
    }
    cout << endl << endl;

    cout << "SUM: " << sum << endl;
    cout << "MIN: " << min << endl;
    cout << "MAX: " << max << endl;
    cout << "AVE: " << ave << endl;
    cout << "oddCount: " << oddCount << endl;
    cout << "evenCount: " << evenCount << endl;

    return 0;
}