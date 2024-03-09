#include <iostream>
#include <vector>
 
using namespace std;
 
class base{
public:
float X;

void getX(){  cout << endl << X << endl;}
void setX(float y){X=y;}

};

 
template<typename T1>
class test_class: public base
{
 public :
 T1 X;

void getX(){ cout << endl << X << endl;}
void setX(T1 y){X=y;}
 
};
 
 
int main(){
 
vector<base*>  vec; // this is my vector of pointers to base-class
vec.push_back(new test_class<double>); // fill the vector with derived class
vec.push_back(new test_class<int>);


vec[0]->setX(10.3);
vec[1]->setX(5.78);

vec[0]->getX();
vec[1]->getX(); // is not an integer!

return 0;
 
 
} 
