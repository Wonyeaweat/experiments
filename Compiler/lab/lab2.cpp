#include"lab2.h" // lab2.h == lab1.cpp->class complier
#include<bits/stdc++.h>
using namespace std;
#define il inline
#define fi first
#define se second
#define error Error(vec,cur),exit(-1)
typedef pair<int,int> pii;
#define NONE "NONE"
void Error(vector<pii>vec,int cur)
{
    cout<<"Error at "<<vec[cur].fi<<' '<<vec[cur].se<<endl;
}
class plus_compiler
{
public:
    string to_string(int num)
    {
        string ret;
        while(num)
        {
            ret.push_back(num%10+'0');
            num/=10;
        }
        reverse(ret.begin(),ret.end());
        return ret;
    }
    struct forth
    {
        string A,B,C,D;
        forth(string _,string __,string ___,string ____)
        {
            A=_,B=__,C=___,D=____;
        }
    };
    int nn=0;
    string ns()
    {
        return "T"+to_string(++nn);
    }
    string deal(string A)
    {
        string tp;
        for(int i=0;i<A.size();i++)
        {
            tp.push_back(A[i]);
            if(A[i]=='+'||A[i]=='-'||A[i]=='*'||A[i]=='/')
            {
                string x=ns();
                string y=deal(A.substr(i+1));
                string op;op.push_back(A[i]);
                append(op,A.substr(0,i),y,x);
                return x;
            }
        }
        return tp;
    }
    compiler A;
    vector<pii>vec;
    vector<forth>result;
    int cur;
    void out()
    {
        for(int i=0;i<result.size();i++)
            cout<<'('<<i<<")("<<result[i].A<<','<<result[i].B<<','<<result[i].C<<','<<result[i].D<<")\n";
    }
    void solve()
    {
        vec=A.run(0);
        cur=0;
        parsePROG();
        append("sys",NONE,NONE,NONE);
        cout<<'\n';
        out();
    }
    void match(int num)
    {
        if(vec[cur].fi==num) cur++;
        else error;
    }
    void append(string a,string b,string c,string d)
    {
        result.push_back(forth(a,b,c,d));
    }
    void parsePROG()
    {
        match(23);
        match(36);
        match(52);
        append("Program",A.name[vec[cur-2].se],NONE,NONE);
        if(vec[cur].fi==33) parseVARS();
        if(vec[cur].fi==3) parseCOMBY();
        else error;
    }
    void parseVARS()
    {
        match(33);
        parseVARDEF();
    }
    void parseVARDEF()
    {
        if(vec[cur].fi==36) parseVARTAB();
        else error;
        match(50);
        parseTYPE();
        match(52);
        if(vec[cur].fi==36) parseVARDEF();
    }
    void parseVARTAB()
    {
        match(36);
        if(vec[cur].fi==44)
        {
            match(44);
            parseVARTAB();
        }
    }
    void parseTYPE()
    {
        if(vec[cur].fi==4 || vec[cur].fi==7 || vec[cur].fi==17) cur++;
        else error;
    }
    void parseCOMBY()
    {
        match(3);
        parseYTAB();
        match(12);
    }
    void parseYTAB()
    {
        parseY();
        if(vec[cur].fi==52)
        {
            cur++;
            parseYTAB();
        }
    }
    void parseY()
    {
        if(vec[cur].fi==36) parseEQUAL();
        else if(vec[cur].fi==15) parseIF();
        else if(vec[cur].fi==34) parseWHILE();
        else if(vec[cur].fi==26) parseREAP();
        else if(vec[cur].fi==3) parseCOMBY();
        else error;
    }
    void parseEQUAL()
    {
        match(36);
        match(51);
        string var=A.name[vec[cur-2].se];
        string ret=parseSSA();
        append(":=",ret,NONE,var);
    }
    string parseSSA() 
    {
        string tp1=parseSSB();
        string tp2=parseSSAp();
        string x=deal(tp1+tp2);
        return x;
    }
    string parseSSB() 
    {
        string tp1=parseSSC();
        string tp2=parseSSBp();
        string x=deal(tp1+tp2);
        return x;
    }
    string parseSSC() 
    {
        if(vec[cur].fi==45)
        {
            ++cur;
            string tp=parseSSC();
            string nns=ns();
            append(NONE,"minus",tp,nns);
            return nns;
        }
        else return parseSSD();
    }
    string parseSSD() 
    {
        if(vec[cur].fi==36) cur++;
        else if(vec[cur].fi==37) cur++;
        else if(vec[cur].fi==39)
        {
            cur++;
            string x=parseSSA();
            match(40);
            return x;
        }
        return A.name[vec[cur-1].se];
    }
    string parseSSBp()
    {
        if(vec[cur].fi==41)
        {
            cur++;
            string tp1=parseSSC();
            string tp2=parseSSBp();
            return "*"+tp1+tp2;
        }
        else if(vec[cur].fi==48)
        {
            cur++;
            string tp1=parseSSC();
            string tp2=parseSSBp();
            return "/"+tp1+tp2;
        }
        else return "";
    }
    string parseSSAp()
    {
        if(vec[cur].fi==43)
        {
            cur++;
            string tp1=parseSSB();
            string tp2=parseSSAp();
            return "+"+tp1+tp2;
        }
        else if(vec[cur].fi==45)
        {
            cur++;
            string tp1=parseSSB();
            string tp2=parseSSAp();
            return "-"+tp1+tp2;
        }
        else return "";
    }
    void parseIF()
    {
        int tcur=result.size();;
        match(15);
        parseBA();
        match(29);
        int Ttrue=result.size();
        parseY();
        int Ffalse=result.size();
        if(vec[cur].fi==11)
        {
            append("j",NONE,NONE,NONE);
            Ffalse++;
            int temp=result.size()-1;
            match(11);
            parseY();
            result[temp].D=to_string(result.size());
        }
        for(int i=tcur;i<result.size();i++)
        {
            if(result[i].D=="T") result[i].D=to_string(Ttrue);
            if(result[i].D=="F") result[i].D=to_string(Ffalse);
        }
    }
    void parseBA()
    {
        parseBB();
        parseBAp();
    }
    void parseBAp()
    {
        if(vec[cur].fi==20)
        {
            cur++;
            result[result.size()-1].D=to_string(result.size());
            parseBB();
            parseBAp();
        }
    }
    void parseBB()
    {
        parseBC();
        parseBBp();
    }
    void parseBBp()
    {
        if(vec[cur].fi==1)
        {
            cur++;
            result[result.size()-2].D=to_string(result.size());
            parseBC();
            parseBBp();
        }
    }
    void parseBC()
    {
        if(vec[cur].fi==18)
        {
            cur++;
            parseBC();
        }
        else
            parseBD();
    }
    void parseBD()
    {
        if(vec[cur].fi==13 || vec[cur].se==31)
        {
            parseBCONST();
        }
        else if(vec[cur].fi==39)
        {
            match(39);
            parseBA();
            match(40);
        }
        else
        {
            string tp1=parseSSA();
            if(vec[cur].fi>=53&&vec[cur].fi<=58)
            {
                int tp=result.size();
                string op;
                if(vec[cur].fi==53) op="<";
                if(vec[cur].fi==54) op="<=";
                if(vec[cur].fi==55) op="<>";
                if(vec[cur].fi==56) op="=";
                if(vec[cur].fi==57) op=">";
                if(vec[cur].fi==58) op=">=";
                ++cur;
                append("j"+op,tp1,NONE,"T");
                append("j",NONE,NONE,"F");
                string tp2=parseSSA();
                result[tp].C=tp2;
                return;
            }
            append("jnz",tp1,NONE,"T");
            append("jnz",NONE,NONE,"F");
        }
    }
    void parseBCONST()
    {
        if(vec[cur].fi==13)
        {
            cur++;
            append("jnz","FALSE",NONE,"T");
            append("j",NONE,NONE,"F");
        }
        else
        {
            cur++;
            append("jnz","TRUE",NONE,"T");
            append("j",NONE,NONE,"F");
        }
    }
    void parseWHILE()
    {
        match(34);
        int tcur=result.size();
        parseBA();
        match(10);
        int Ttrue=result.size();
        parseY();
        append("j",NONE,NONE,to_string(tcur));
        int Ffalse=result.size();
        for(int i=tcur;i<result.size();i++)
        {
            if(result[i].D=="T") result[i].D=to_string(Ttrue);
            if(result[i].D=="F") result[i].D=to_string(Ffalse);
        }
    }
    void parseREAP()
    {
        int Ttrue=result.size();
        match(26);
        parseY();
        int tcur=result.size();
        match(32);
        parseBA();
        for(int i=tcur;i<result.size();i++)
        {
            if(result[i].D=="F") result[i].D=to_string(Ttrue);
            if(result[i].D=="T") result[i].D=to_string((int)result.size());
        }
    }
};
int main()
{
    plus_compiler A;
    A.solve();
}
