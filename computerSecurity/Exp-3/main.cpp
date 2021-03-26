#include<bits/stdc++.h>
using namespace std;
void function(char *str){
	char buffer[16];
	strcpy(buffer,str);
	cout<<buffer<<endl;
	return;
}
int main(){	
	char large_string[256];
	for(int i=0;i<255;i++)
		large_string[i]='A';
	function(large_string);
	return 0;
}
