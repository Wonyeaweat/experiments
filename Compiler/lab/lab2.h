#include<bits/stdc++.h>
using namespace std;
#define il inline
#define fi first
#define se second
#define nas 61
#define inv 62
class compiler
{
    typedef pair<int,int> pii;
    struct pp
    {
        pii val,pos;
        pp(pii a,pii b)
        {
            val=a,pos=b;
        }
    };
    map<string,int> ht;
    map<string,int> idx;
    vector<pp>vec;
    int tot;
    il void init()
    {
        ht.clear(),idx.clear(),vec.clear(),tot=0;
        string s[35]={
            "and","array","begin","bool","call","case","char","constant","dim","do",
            "else","end","false","for","if","input","integer","not","of","or",
            "output","procedure","program","read","real","repeat","set","stop","then","to",
            "true","until","var","while","write"
        };
        string t[22]={
            "(",")","*","*/","+",",","-",".","..","/","/*",":",":=",
            ";","<","<=","<>","=",">",">=","[","]"
        };
        for(int i=0;i<35;i++) ht[s[i]]=i+1;
        for(int i=0;i<22;i++) ht[t[i]]=i+39;
    }
    il bool ischar(char c)
    {
        return (c>='A' && c<='Z') || (c>='a' && c<='z');
    }
    il bool isnum(char c)
    {
        return c>='0' && c<='9';
    }
    il int judge(string a)
    {
        if(ht.find(a)!=ht.end()) return ht[a];
        int sz=a.size();
        if(a[0]=='\'')
        {
            for(int i=1;i<sz-1;i++)
                if(a[i]=='\'')
                    return 62; //invalid
            if(a[sz-1]!='\'')
                return 61; //not a string
            else
            {
                if(!idx[a])
                {
                    idx[a]=++tot;
                    name[tot]=a;
                }
                return 38; //is a string
            }
        }
        if(isnum(a[0]))
        {
            for(int i=0;i<sz;i++)
                if(!isnum(a[i]))
                    return 62; //invalid
            if(!idx[a])
            {
                idx[a]=++tot;
                name[tot]=a;
            }
            return 37; //is a num
        }
        if(ischar(a[0]))
        {
            for(int i=0;i<sz;i++)
                if(!isnum(a[i]) && !ischar(a[i]))
                    return 62; //invalid
            if(!idx[a])
            {
                idx[a]=++tot;
                name[tot]=a;
            }
            return 36; //is a var
        }
        return 62;
    }
    il void show_title()
    {
        cout<<"This program is made by Amori\n";
        cout<<"Class: 2017 Computer Science 1\n";
        cout<<"Sno: 201730615155\n";
    }
    il void judge_helper(string tp,int line,int pos)
    {
        int id=judge(tp);
        int iid=0;
        if(id>=36 && id<=38) iid=idx[tp];
        vec.push_back(pp(pii(id,iid),pii(line,pos)));
    }
    il vector<pii> out(bool ret)
    {
        cout<<"\nAnalysis:\n\n";
        vector<pii>error1;
        vector<pii>error2;
        for(int i=0;i<vec.size();i++)
        {
            if(vec[i].val.fi==nas)
                error2.push_back(vec[i].pos);
            if(vec[i].val.fi==inv)
                error1.push_back(vec[i].pos);
        }
        int st=0;
        int mark=-1;
        for(int i=0;i<vec.size();i++)
        {
            if(vec[i].val.fi==49 && st==0)
                st=1;
            if(vec[i].val.fi==42)
            {
                if(st==1) st=0;
                else
                {
                    mark=i;
                    break;
                }
            }
        }
        bool flag=true;
        if(!error1.empty())
        {
            flag=false;
            cout<<"Error1 occurs (invalid input) at: \n";
            for(int i=0;i<error1.size();i++)
                cout<<"Line "<<error1[i].fi<<' '<<"Word "<<error1[i].se<<endl;
        }
        if(!error2.empty())
        {
            flag=false;
            cout<<"Error2 occurs (expected a ' ) at: \n";
            for(int i=0;i<error2.size();i++)
                cout<<"Line "<<error2[i].fi<<' '<<"Word "<<error2[i].se<<endl;
        }
        if(mark!=-1)
        {
            flag=false;
            cout<<"Error3 occurs (Start with '*/') at:\n";
            cout<<"Line "<<vec[mark].pos.fi<<' '<<"Word "<<vec[mark].pos.se<<endl;
        }
        if(st==1)
        {
            flag=false;
            cout<<"Error3 occurs (expected a '*/' at end)\n";
        }
        if(flag)
        {
            if(ret)
            {
                int cnt=0;
                st=0;
                for(int i=0;i<vec.size();i++)
                {
                    if(vec[i].val.fi==49) st=1;
                    if(vec[i].val.fi==42)
                    {
                        st=0;
                        continue;
                    }
                    if(st) continue;
                    cnt++;
                    cout<<'('<<vec[i].val.fi<<',';
                    if(vec[i].val.se==0) cout<<"-) ";
                    else cout<<vec[i].val.se<<") ";
                    if(cnt%5==0) cout<<endl;
                }
                cout<<endl;
            }
            vector<pii>rett;
            int cnt=0;
            st=0;
            for(int i=0;i<vec.size();i++)
            {
                if(vec[i].val.fi==49) st=1;
                if(vec[i].val.fi==42)
                {
                    st=0;
                    continue;
                }
                if(st) continue;
                pii temp(vec[i].val.fi,-1);
                if(vec[i].val.se==0);
                else temp.se=vec[i].val.se;
                rett.push_back(temp);
            }
            return rett;
        }
    }
public:
    map<int,string> name;
    char filename[105];
    vector<pii> run(bool f)
    {
        init();
        show_title();
        cout<<"Use test case 1/2/3/4?:(Y/N)\n";
        string s;
        cin>>s;
        if(s[0]=='Y')
        {
            cout<<"Please input the number of test case:(1/2/3/4)\n";
            int x;
            cin>>x;
            strcpy(filename,"test#.txt");
            filename[4]=x+'0';
            freopen(filename,"r",stdin);
        }
        else cout<<"Please start your input here:(End your input with Ctrl+z)\n";
        bool flag=0;
        int line=0;
        while(getline(cin,s))
        {
            line++;
            if(flag) {flag=false;continue;}
            int sz=s.size();
            string tp;
            int pos=0;
            for(int i=0;i<sz;i++)
            {
                if(s[i]!=' ')
                {
                    string x;
                    int num=0;
                    x.push_back(s[i]);
                    if(ht.find(x)!=ht.end()) num=ht[x];
                    if(num>=39)
                    {
                        if(!tp.empty()) judge_helper(tp,line,++pos),tp.clear();
                        if(i!=sz-1)
                        {
                            i++;
                            if(num==41 && s[i]=='/') vec.push_back(pp(pii(42,0),pii(line,++pos)));
                            else if(num==46 && s[i]=='.') vec.push_back(pp(pii(47,0),pii(line,++pos)));
                            else if(num==48 && s[i]=='*') vec.push_back(pp(pii(49,0),pii(line,++pos)));
                            else if(num==50 && s[i]=='=') vec.push_back(pp(pii(51,0),pii(line,++pos)));
                            else if(num==53 && s[i]=='=') vec.push_back(pp(pii(54,0),pii(line,++pos)));
                            else if(num==53 && s[i]=='>') vec.push_back(pp(pii(55,0),pii(line,++pos)));
                            else if(num==57 && s[i]=='=') vec.push_back(pp(pii(58,0),pii(line,++pos)));
                            else
                            {
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
