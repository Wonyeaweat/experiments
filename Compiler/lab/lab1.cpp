#include<bits/stdc++.h>
using namespace std;
#define nas 61 // Not A String
#define inv 62 // INValid
#define ias 38 // Is A String
#define ian 37 // Is A Num
#define iav 36 // Is A Variable
class compiler{
    typedef pair<int,int> pii;
    struct pp{
        pii val,pos;
        pp(pii a,pii b){
            val=a,pos=b;
        }
    };
    map<string,int> ht;
    map<string,int> idx;
    vector<pp>vec;
    int tot;
    void init(){
        ht.clear(),idx.clear(),vec.clear(),tot=0;
        string s[35]={
            "and","array","begin","bool","call",
            "case","char","constant","dim","do",

            "else","end","false","for","if",
            "input","integer","not","of","or",
            
            "output","procedure","program","read","real",
            "repeat","set","stop","then","to",
            
            "true","until","var","while","write"
        };
        string t[22]={
            "(",")","*","*/","+",
            ",","-",".","..","/",

            "/*",":",":=",";","<",
            "<=","<>","=",">",">=",
            
            "[","]"
        };
        for(int i=0;i<35;i++) ht[s[i]]=i+1;
        for(int i=0;i<22;i++) ht[t[i]]=i+39;
    }
    bool ischar(char c){return (c>='A' && c<='Z') || (c>='a' && c<='z');}
    bool isnum(char c){return c>='0' && c<='9';}
    int judge(string a){
        if(ht.find(a)!=ht.end()) return ht[a];
        int sz=a.size();
        if(a[0]=='\''){
            for(int i=1;i<sz-1;i++) if(a[i]=='\'') return inv; 
            if(a[sz-1]!='\'') return nas; 
            else{
                if(!idx[a]){
                    idx[a]=++tot;
                    name[tot]=a;
                }
                return ias; 
            }
        }
        if(isnum(a[0])){
            for(int i=0;i<sz;i++) if(!isnum(a[i])) return inv; 
            if(!idx[a]){
                idx[a]=++tot;
                name[tot]=a;
            }
            return ian; 
        }
        if(ischar(a[0])){
            for(int i=0;i<sz;i++) if(!isnum(a[i]) && !ischar(a[i])) return inv; 
            if(!idx[a]){
                idx[a]=++tot;
                name[tot]=a;
            }
            return iav; 
        }
        return inv;
    }
    void judge_helper(string tp,int line,int pos){
        int id=judge(tp);
        int iid=0;
        if(id>=36 && id<=38) iid=idx[tp];
        vec.push_back(pp(pii(id,iid),pii(line,pos)));
    }
    vector<pii> out(bool ret){
        cout<<"\nAnalysis:\n\n";
        vector<pii>error1;
        vector<pii>error2;
        for(int i=0;i<vec.size();i++){
            if(vec[i].val.first==nas) error2.push_back(vec[i].pos);
            if(vec[i].val.first==inv) error1.push_back(vec[i].pos);
        }
        int st=0;
        int mark=-1;
        for(int i=0;i<vec.size();i++){
            if(vec[i].val.first==49 && st==0) st=1;
            if(vec[i].val.first==42){
                if(st==1) st=0;
                else {mark=i;break;}
            }
        }
        bool flag=true;
        if(!error1.empty()){
            flag=false;
            cout<<"Error1 occurs (invalid input) at: \n";
            for(int i=0;i<error1.size();i++)
                cout<<"Line "<<error1[i].first<<' '<<"Word "<<error1[i].second<<endl;
        }
        if(!error2.empty()){
            flag=false;
            cout<<"Error2 occurs (expected a ' ) at: \n";
            for(int i=0;i<error2.size();i++)
                cout<<"Line "<<error2[i].first<<' '<<"Word "<<error2[i].second<<endl;
        }
        if(mark!=-1){
            flag=false;
            cout<<"Error3 occurs (Start with '*/') at:\n";
            cout<<"Line "<<vec[mark].pos.first<<' '<<"Word "<<vec[mark].pos.second<<endl;
        }
        if(st==1){
            flag=false;
            cout<<"Error3 occurs (expected a '*/' at end)\n";
        }
        if(flag){
            if(ret){
                int cnt=0;
                st=0;
                for(int i=0;i<vec.size();i++){
                    if(vec[i].val.first==49) st=1;
                    if(vec[i].val.first==42){st=0;continue;}
                    if(st) continue;
                    cnt++;
                    cout<<'('<<vec[i].val.first<<',';
                    if(vec[i].val.second==0) cout<<"-) ";
                    else cout<<vec[i].val.second<<") ";
                    if(cnt%5==0) cout<<endl;
                }
                cout<<endl;
            }
            vector<pii>rett;
            int cnt=0;
            st=0;
            for(int i=0;i<vec.size();i++){
                if(vec[i].val.first==49) st=1;
                if(vec[i].val.first==42){st=0;continue;}
                if(st) continue;
                pii temp(vec[i].val.first,-1);
                if(vec[i].val.second==0);
                else temp.second=vec[i].val.second;
                rett.push_back(temp);
            }
            return rett;
        }
    }
public:
    map<int,string> name;
    char filename[105];
    vector<pii> run(bool f){
        init();
        cout<<"201836590301_王叶伟_实验一"<<endl; 
        cout<<"Use test case?:(Y/N)\n";
        string s;
        cin>>s;
        if(s[0]=='Y' || s[0]=='y'){
            cout<<"Input the number of test case:(1/2/3/4)\n";
            int x;cin>>x;
            strcpy(filename,"test#.txt");
            filename[4]=x+'0';
            freopen(filename,"r",stdin);
        }
        else cout<<"Please start your input here:(End your input with Ctrl+z)\n";
        bool flag=0;
        int line=0;
        while(getline(cin,s)){
            line++;
            if(flag) {flag=false;continue;}
            int sz=s.size();
            string tp;
            int pos=0;
            for(int i=0;i<sz;i++){
                if(s[i]!=' '){
                    string x;
                    int num=0;
                    x.push_back(s[i]);
                    if(ht.find(x)!=ht.end()) num=ht[x];
                    if(num>=39){
                        if(!tp.empty()) judge_helper(tp,line,++pos),tp.clear();
                        if(i!=sz-1){
                            i++;
                            if(num==41 && s[i]=='/') vec.push_back(pp(pii(42,0),pii(line,++pos)));
                            else if(num==46 && s[i]=='.') vec.push_back(pp(pii(47,0),pii(line,++pos)));
                            else if(num==48 && s[i]=='*') vec.push_back(pp(pii(49,0),pii(line,++pos)));
                            else if(num==50 && s[i]=='=') vec.push_back(pp(pii(51,0),pii(line,++pos)));
                            else if(num==53 && s[i]=='=') vec.push_back(pp(pii(54,0),pii(line,++pos)));
                            else if(num==53 && s[i]=='>') vec.push_back(pp(pii(55,0),pii(line,++pos)));
                            else if(num==57 && s[i]=='=') vec.push_back(pp(pii(58,0),pii(line,++pos)));
                            else{
                                i--;
                                vec.push_back(pp(pii(num,0),pii(line,++pos)));
                            }
                        }
                        else vec.push_back(pp(pii(num,0),pii(line,++pos)));
                    }
                    else tp.push_back(s[i]);
                }
                else if(!tp.empty()) judge_helper(tp,line,++pos),tp.clear();
            }
            if(!tp.empty()) judge_helper(tp,line,++pos),tp.clear();
        }
        return out(f);
    }
};
int main(){
    compiler A;
    A.run(1);
    while(1);
}
