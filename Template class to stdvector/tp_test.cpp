#include <iostream>
#include <vector>

using namespace std;


template<typename T1>
class test_class{

 T1 X;

};


int main(){

test_class<double> W;
test_class<int> Z;

vector<test_class<double> > vec; // this compiles fine, as I specify the class 
//vector<test_class> vec; // this is impossible, as test_class is only a template


return 0;


} 