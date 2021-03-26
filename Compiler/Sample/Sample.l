%option noyywrap nounput batch debug noinput
%option nounistd never-interactive
%{
#include <string>
#include "sample_driver.hpp"
#include "sample_parser.hpp"
#include "location.hh"

#undef yywrap
#define yywrap() 1
#define YY_NUMMPTR nullptr
std::string current_string;
Sample::location loc;
%}

%x in_string
%x in_comment
%x in_single_comment
%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

%%
[ \t\r]+            {   loc.step(); continue; }
\n                  {   loc.step(); loc.lines(yyleng); continue; }
and                 {   return Sample::Parser::make_KEYWORD_AND(loc);   }
array               {   return Sample::Parser::make_KEYWORD_ARRAY(loc); }
begin               {   return Sample::Parser::make_KEYWORD_BEGIN(loc); }
bool                {   return Sample::Parser::make_KEYWORD_BOOL(loc);  }
call                {   return Sample::Parser::make_KEYWORD_CALL(loc);  }
case                {   return Sample::Parser::make_KEYWORD_CASE(loc);  }
char                {   return Sample::Parser::make_KEYWORD_CHAR(loc);  }
constant            {   return Sample::Parser::make_KEYWORD_CONSTANT(loc); }
dim                 {   return Sample::Parser::make_KEYWORD_DIM(loc); }
do                  {   return Sample::Parser::make_KEYWORD_DO(loc); }
else                {   return Sample::Parser::make_KEYWORD_ELSE(loc); }
end                 {   return Sample::Parser::make_KEYWORD_END(loc); }
false               {   return Sample::Parser::make_KEYWORD_FALSE(loc); }
for                 {   return Sample::Parser::make_KEYWORD_FOR(loc); }
if                  {   return Sample::Parser::make_KEYWORD_IF(loc); }
input               {   return Sample::Parser::make_KEYWORD_INPUT(loc); }
integer             {   return Sample::Parser::make_KEYWORD_INTEGER(loc); }
not                 {   return Sample::Parser::make_KEYWORD_NOT(loc); }
of                  {   return Sample::Parser::make_KEYWORD_OF(loc); }
or                  {   return Sample::Parser::make_KEYWORD_OR(loc); }
output              {   return Sample::Parser::make_KEYWORD_OUTPUT(loc); }
"("                 {   return Sample::Parser::make_OPERATOR_PARTHEN_BEGIN(loc);        }
")"                 {   return Sample::Parser::make_OPERATOR_PARTHEN_END(loc);        }
procedure           {   return Sample::Parser::make_KEYWORD_PROCEDURE(loc); }
program             {   return Sample::Parser::make_KEYWORD_PROGRAM(loc); }
read                {   return Sample::Parser::make_KEYWORD_READ(loc); }
real                {   return Sample::Parser::make_KEYWORD_REAL(loc); }
repeat              {   return Sample::Parser::make_KEYWORD_REPEAT(loc); }
set                 {   return Sample::Parser::make_KEYWORD_SET(loc); }
stop                {   return Sample::Parser::make_KEYWORD_STOP(loc); }
then                {   return Sample::Parser::make_KEYWORD_THEN(loc); }
to                  {   return Sample::Parser::make_KEYWORD_TO(loc); }
true                {   return Sample::Parser::make_KEYWORD_TRUE(loc); }
until               {   return Sample::Parser::make_KEYWORD_UNTIL(loc); }
var                 {   return Sample::Parser::make_KEYWORD_VAR(loc); }
while               {   return Sample::Parser::make_KEYWORD_WHILE(loc); }
write               {   return Sample::Parser::make_KEYWORD_WRITE(loc); }

"+"                     {   return Sample::Parser::make_OPERATOR_ADD(loc);                  }
"-"                     {   return Sample::Parser::make_OPERATOR_SUB(loc);                  }
"*"                     {   return Sample::Parser::make_OPERATOR_MUL(loc);                  }
"/"                     {   return Sample::Parser::make_OPERATOR_DIV(loc);                  }
":"                     {   return Sample::Parser::make_OPERATOR_COLON(loc);                }
";"                     {   return Sample::Parser::make_OPERATOR_SEMICOLON(loc);            }
"."                     {   return Sample::Parser::make_OPERATOR_DOT(loc);                  }
","                     {   return Sample::Parser::make_OPERATOR_COMMA(loc);                }
".."                    {   return Sample::Parser::make_OPERATOR_DOUBLE_DOT(loc);           }
":="                    {   return Sample::Parser::make_OPERATOR_ASSIGN(loc);               }
"="                     {   return Sample::Parser::make_OPERATOR_EQUAL(loc);                }
"<>"                    {   return Sample::Parser::make_OPERATOR_NEQ(loc);                  }
"<"                     {   return Sample::Parser::make_OPERATOR_LESS(loc);                 }
"<="                    {   return Sample::Parser::make_OPERATOR_LEQ(loc);                  }
">"                     {   return Sample::Parser::make_OPERATOR_GREATER(loc);              }
">="                    {   return Sample::Parser::make_OPERATOR_GE(loc);                   }
"["                     {   return Sample::Parser::make_OPERATOR_BRACKET_BEGIN(loc);        }
"]"                     {   return Sample::Parser::make_OPERATOR_BRACKET_END(loc);          }
"/*"                    { 
                            BEGIN(in_comment);   
                        }
"//"                    {
                            BEGIN(in_single_comment);
                        }
<in_single_comment>\n       { BEGIN(INITIAL);   loc.lines(yyleng);   }
<in_single_comment>[^\n]*   { continue; }

<in_comment>[^*\n]*         {   continue; }  // eat the comment 
<in_comment>"*"+[^*/\n]*    {   continue; }  // eat '*'s not followed by `/`
<in_comment>\n              {   loc.lines(yyleng); }  // eat a new line
<in_comment>"*/"            {   BEGIN(INITIAL);  }
<in_comment><<EOF>>         {
                                driver.error(loc, "`Comment` is not enclosed! Expect `*/` here.");
                            }
\'                          {
                                BEGIN(in_string);
                                current_string.clear();
                            }
<in_string>\n           |   
<in_string><<EOF>>      {
                            driver.error(loc, "`String literal` is not enclosed. Expect `'` here.");
                        }
<in_string>\\n          {  current_string += '\n'; }
<in_string>\\t          {  current_string += '\t'; }
<in_string>\\r          {  current_string += '\r'; }
<in_string>\\b          {  current_string += '\b'; }
<in_string>\\f          {  current_string += '\f'; }
<in_string>\\[^\n]      {  current_string += yytext[1];}
<in_string>\\\n         {  
                            loc.lines(1);
                            current_string += yytext[1];
                        }
<in_string>[^\\\n']+    {
                           current_string += yytext;
                        }
<in_string>\'           {
                            BEGIN(INITIAL);
                            return Sample::Parser::make_TOKEN_STRING(current_string, loc);
                        }
[0-9]+                  {                            
                            return Sample::Parser::make_TOKEN_INT(strtoll(yytext, nullptr, 10), loc);
                        }
[a-zA-Z_][a-zA-Z0-9_]*   { 
                            return Sample::Parser::make_TOKEN_IDENTIFIER(yytext, loc);
                        }
<*>.|\n                 {
                            driver.error(loc, "Unknown character");
                        }
<<EOF>>                 {   return Sample::Parser::make_ENDFILE(loc); }

%%
/* int main(int argc, char** argv) {
    if(argc > 1) {
        int res, tot = 0;
        do_parse();
        // while((res = yylex())) {
        //     const char* out = (res == TOKEN_STRING) ? str_buf : yytext;
        //     printf("(%d, %8s)%8c", res, out, " \n"[++tot % 5 == 0]);
        // }
        puts("Done!");
    }
} */