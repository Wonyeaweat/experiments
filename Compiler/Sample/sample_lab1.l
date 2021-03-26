%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unordered_map>
#include <string>
enum identifier {
    KEYWORD_AND = 1,
    KEYWORD_ARRAY,
    KEYWORD_BEGIN,
    KEYWORD_BOOL,
    KEYWORD_CALL,
    KEYWORD_CASE,
    KEYWORD_CHAR,
    KEYWORD_CONSTANT,
    KEYWORD_DIM,
    KEYWORD_DO,
    KEYWORD_ELSE,
    KEYWORD_END,
    KEYWORD_FALSE,
    KEYWORD_FOR,
    KEYWORD_IF,
    KEYWORD_INPUT,
    KEYWORD_INTEGER,
    KEYWORD_NOT,
    KEYWORD_OF,
    KEYWORD_OR,
    KEYWORD_OUTPUT,
    KEYWORD_PROCEDURE,
    KEYWORD_PROGRAM,
    KEYWORD_READ,
    KEYWORD_REAL,
    KEYWORD_REPEAT,
    KEYWORD_SET,
    KEYWORD_STOP,
    KEYWORD_THEN,
    KEYWORD_TO,
    KEYWORD_TRUE,
    KEYWORD_UNTIL,
    KEYWORD_VAR,
    KEYWORD_WHILE,
    KEYWORD_WRITE,
    TOKEN_IDENTIFIER,
    TOKEN_REAL,
    TOKEN_STRING,
    OPERATOR_PARTHEN_BEGIN,
    OPERATOR_PARTHEN_END,
    OPERATOR_MUL,
    COMMENT_END,

    OPERATOR_ADD,
    OPERATOR_COMMA,
    OPERATOR_SUB,
    OPERATOR_DOT,
    OPERATOR_DOUBLE_DOT,
    OPERATOR_DIV,
    COMMENT_BEGIN,
    OPERATOR_COLON,
    OPERATOR_ASSIGN,
    OPERATOR_SEMICOLON,
    OPERATOR_LESS,
    OPERATOR_LEQ,
    OPERATOR_NEQ,
    OPERATOR_EQUAL,
    OPERATOR_GREATER,
    OPERATOR_GE,
    OPERATOR_BRACKET_BEGIN,
    OPERATOR_BRACKET_END,
    OPERATOR_QUOTATION,
    PARSE_ERROR
};
#define maxn 2048
int yylval;
char str_buf[maxn], *str_buf_ptr;
int line_num, char_num;
std::unordered_map<std::string, int> mp_id;
// std::unordered_map<int,         int> num_id;
int id_num_token;
%}

%x comment chars parenthesis brackets
%s except
%option noyywrap yylineno
%%
"and"               {  return KEYWORD_AND;   }
"array"             {  return KEYWORD_ARRAY; }
"begin"             {  return KEYWORD_BEGIN; }
"bool"              {  return KEYWORD_BOOL;  }
"call"              {  return KEYWORD_CALL;  }
"case"              {  return KEYWORD_CASE;  }
"char"              {  return KEYWORD_CHAR;  }
"constant"          {  return KEYWORD_CONSTANT; }
"dim"               {  return KEYWORD_DIM; }
"do"                {  return KEYWORD_DO; }
"else"              {  return KEYWORD_ELSE; }
"end"               {  return KEYWORD_END; }
"false"             {  return KEYWORD_FALSE; }
"for"               {  return KEYWORD_FOR; }
"if"                {  return KEYWORD_IF; }
"input"             {  return KEYWORD_INPUT; }
"integer"           {  return KEYWORD_INTEGER; }
"not"               {  return KEYWORD_NOT; }
"of"                {  return KEYWORD_OF; }
"or"                {  return KEYWORD_OR; }
"output"            {  return KEYWORD_OUTPUT; }
"("                 {  return OPERATOR_PARTHEN_BEGIN;        }
")"                 {  return OPERATOR_PARTHEN_END;        }
"procedure"         {  return KEYWORD_PROCEDURE; }
"program"           {  return KEYWORD_PROGRAM; }
"read"              {  return KEYWORD_READ; }
"real"              {  return KEYWORD_REAL; }
"repeat"            {  return KEYWORD_REPEAT; }
"set"               {  return KEYWORD_SET; }
"stop"              {  return KEYWORD_STOP; }
"then"              {  return KEYWORD_THEN; }
"to"                {  return KEYWORD_TO; }
"true"              {  return KEYWORD_TRUE; }
"until"             {  return KEYWORD_UNTIL; }
"var"               {  return KEYWORD_VAR; }
"while"             {  return KEYWORD_WHILE; }
"write"             {  return KEYWORD_WRITE; }

"+"                 {  return OPERATOR_ADD;                  }
"-"                 {  return OPERATOR_SUB;                  }
"*"                 {  return OPERATOR_MUL;                  }
"/"                 {  return OPERATOR_DIV;                  }
":"                 {  return OPERATOR_COLON;                }
";"                 {  return OPERATOR_SEMICOLON;            }
"."                 {  return OPERATOR_DOT;                  }
","                 {  return OPERATOR_COMMA;                }
".."                {  return OPERATOR_DOUBLE_DOT;           }
":="                {  return OPERATOR_ASSIGN; }
"="                 {  return OPERATOR_EQUAL;               }
"<>"                {  return OPERATOR_NEQ;  }
"<"                 {  return OPERATOR_LESS; }
"<="                {  return OPERATOR_LEQ;  }
">"                 {  return OPERATOR_GREATER;      }
">="                {  return OPERATOR_GE;           }
"["                 {  return OPERATOR_BRACKET_BEGIN;}
"]"                 {  return OPERATOR_BRACKET_END;  }
"/*"                { 
                        BEGIN(comment);
                        // printf("Comment start!\n");
                        return COMMENT_BEGIN;  
                    }
"'"                 {
                        BEGIN(chars);
                        str_buf_ptr = str_buf;
                        return OPERATOR_QUOTATION;
                    }

<chars>\n           |
<chars><<EOF>>      {
                        printf("[Error] In line %d, `String literal` is not enclosed. Expect `'` here.", yylineno);
                        exit(-1);
                        return PARSE_ERROR;
                    }
<chars>\\n          { *str_buf_ptr++ = '\n'; }
<chars>\\t          { *str_buf_ptr++ = '\t'; }
<chars>\\r          { *str_buf_ptr++ = '\r'; }
<chars>\\b          { *str_buf_ptr++ = '\b'; }
<chars>\\f          { *str_buf_ptr++ = '\f'; }
<chars>\\(.|\n)     { *str_buf_ptr++ = yytext[1];}
<chars>[^\\\n']+    {
                        char* now = yytext;
                        while(*now) *str_buf_ptr++ = *now++;
                    }
<chars>"'"          {
                        BEGIN(INITIAL);
                        *str_buf_ptr = '\0';
                        if (!mp_id.count(str_buf)) mp_id[str_buf] = ++id_num_token;
                        // printf("Found String: %s\n", str_buf);
                        return TOKEN_STRING;
                    }
<comment>[^*\n]*        {}  // eat the comment 
<comment>"*"+[^*/\n]*   {}  // eat '*'s not followed by `/`
<comment>\n             {}  // eat a new line
<comment>"*"+"/"        {
                            BEGIN(INITIAL);
                            return COMMENT_END;   
                        }
<comment><<EOF>>        {
                            printf("[Error] In line %d, `Comment` is not enclosed! Expect `*/` here. \n", yylineno);
                            exit(-1);
                            return PARSE_ERROR;
                        }
[-]?([0-9]+) {
                    long long num = atoll(yytext);
                    if (!mp_id.count(yytext)) mp_id[yytext] = ++id_num_token;
                    return TOKEN_REAL;
              }
[a-zA-Z_][a-zA-Z0-9]*   { 
                            // printf("Identifier %s\n", yytext);
                            if (!mp_id.count(yytext)) mp_id[yytext] = ++id_num_token;
                            return TOKEN_IDENTIFIER; 
                        }
[ \t\n]+                // eat the blank
<*>.|\n                 {
                            printf("[Error] Unknown character for %s\n", yytext);
                            return PARSE_ERROR;
                        }


%%
int main(int argc, char** argv) {
    if(argc > 1) {
        yyin = fopen(argv[1], "r");
        int res, tot = 0;
        while((res = yylex())) {
            /* const char* out = (res == TOKEN_STRING) ? str_buf : yytext; */
            /* printf("(%d, %8s)%8c", res, out, " \n"[++tot % 5 == 0]); */
            if (res == OPERATOR_QUOTATION)  continue;
            if (res == COMMENT_END || res == COMMENT_BEGIN) continue;
            std::string out = "-";
            if (res == TOKEN_REAL || res == TOKEN_IDENTIFIER)
                out = std::to_string(mp_id[yytext]);
            else if (res == TOKEN_STRING) out = std::to_string(mp_id[str_buf]);
            printf("(%2d, %2s)%8c", res, out.c_str(), " \n"[++tot % 5 == 0]);
        }
    }
}