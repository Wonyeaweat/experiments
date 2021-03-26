%skeleton "lalr1.cc"
%language "c++"
%defines
%define api.namespace {Sample}
%define api.parser.class {Parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%define parse.trace
%define parse.lac   full
%define parse.error verbose
%locations
%initial-action
{
    /* @$.begin.file = @$.end.file = &driver.filename; */
}

%code requires {
#include "sample_ast.hpp"
    namespace Sample {
        class Driver;
        class Scanner;
    }
}

%param {Sample::Driver& driver}

%code {

#include "sample_ast.hpp"
#include "sample_driver.hpp"
#include <iostream>

std::shared_ptr<Sample::AST::Exp> ast_root;
std::shared_ptr<Sample::AST::DecList> dec_root;

using namespace Sample::AST;

}


%token ENDFILE 0 "END OF FILE"

%token
    KEYWORD_AND KEYWORD_ARRAY KEYWORD_BEGIN KEYWORD_BOOL KEYWORD_CALL 
    KEYWORD_CASE KEYWORD_CHAR KEYWORD_CONSTANT KEYWORD_DIM KEYWORD_DO 
    KEYWORD_ELSE KEYWORD_END KEYWORD_FALSE KEYWORD_FOR KEYWORD_IF 
    KEYWORD_INPUT KEYWORD_INTEGER KEYWORD_NOT KEYWORD_OF KEYWORD_OR 
    KEYWORD_OUTPUT KEYWORD_PROCEDURE KEYWORD_PROGRAM KEYWORD_READ 
    KEYWORD_INT KEYWORD_REAL KEYWORD_REPEAT KEYWORD_SET KEYWORD_STOP KEYWORD_THEN 
    KEYWORD_TO KEYWORD_TRUE KEYWORD_UNTIL KEYWORD_VAR KEYWORD_WHILE 
    KEYWORD_WRITE OPERATOR_QUOTATION 
    OPERATOR_PARTHEN_BEGIN OPERATOR_PARTHEN_END OPERATOR_MUL 
    COMMENT_END OPERATOR_ADD OPERATOR_COMMA OPERATOR_SUB 
    OPERATOR_DOT OPERATOR_DOUBLE_DOT OPERATOR_DIV 
    COMMENT_BEGIN OPERATOR_COLON OPERATOR_ASSIGN 
    OPERATOR_SEMICOLON OPERATOR_LESS OPERATOR_LEQ 
    OPERATOR_NEQ OPERATOR_EQUAL OPERATOR_GREATER 
    OPERATOR_GE OPERATOR_BRACKET_BEGIN OPERATOR_BRACKET_END 
    PARSE_ERROR;


%token <int>               TOKEN_INT
%token <std::string>       TOKEN_STRING
%token <std::string>       TOKEN_IDENTIFIER


%right KEYWORD_THEN KEYWORD_ELSE

%type<std::string>   token_type
%type<Sample::AST::Operator>   relation_operator

%type<std::shared_ptr<Sample::AST::Exp>>  arithmetic_exp term factor arithmetic_value 
%type<std::shared_ptr<Sample::AST::Exp>>  bool_expression bool_value bool_term bool_factor

%type<std::shared_ptr<Sample::AST::Exp>>  statement statement_assign statement_while statement_repeat statement_compund
%type<std::shared_ptr<Sample::AST::Exp>>  M_empty N_empty



%type<std::shared_ptr<Sample::AST::Exp>>  statement_table
%type<std::shared_ptr<Sample::AST::Exp>>  program

%type<std::shared_ptr<Sample::AST::DecList>>  var_description  
%type<std::shared_ptr<Sample::AST::DecList>>  var_definition  

%type<std::shared_ptr<Sample::AST::DecList>>  token_table


%start program

%%

token_type: 
        KEYWORD_INTEGER 
        {  
            $$ = "integer";
        }
|       KEYWORD_BOOL 
        {
            $$ = "bool";
        }
|       KEYWORD_CHAR
        {
            $$ = "char";
        } 
        ;

arithmetic_exp: 
        arithmetic_exp OPERATOR_ADD term 
        {
            // auto exp = MakeOpExp(@$, Sample::AST::Operator::PLUS, $1, $3);
            auto exp = MakeNilExp(@$);
            std::string temp = driver.makeVar();
            auto& x = driver.quater_var_table;
            x.insert({exp, temp});


            std::string left  = x.count($1) ? x[$1] : "";
            std::string right = x.count($3) ? x[$3] : "";
            driver.doEmit("+", left, 
                               right,
                               temp);
            exp->begin = Driver::quater_id;
            // driver.quater_id_table.insert({ Driver::quater_id, exp});
            // driver.quater_exp_table.insert({  exp, Driver::quater_id });
            $$ = exp;
        }
|       arithmetic_exp OPERATOR_SUB term  
        {
            // auto exp = MakeOpExp(@$, Sample::AST::Operator::MINUS, $1, $3);
            auto exp =  MakeNilExp(@$);
            std::string temp = driver.makeVar();
            auto& x = driver.quater_var_table;
            x.insert({exp, temp});


            std::string left  = x.count($1) ? x[$1] : "";
            std::string right = x.count($3) ? x[$3] : "";
            driver.doEmit("-", left, 
                               right,
                               temp);
            
            exp->begin = Driver::quater_id;
            $$ = exp;
        }
|       term 
        {
            $$ = $1;
            auto& x = driver.quater_var_table;
            if (!x.count($1)) {
                std::string temp = driver.makeVar();
                x.insert({$1, temp});
            }
        }
        ;

term:   
        term OPERATOR_MUL factor 
        {
            // auto exp = MakeOpExp(@$, Sample::AST::Operator::TIMES, $1, $3);
            auto exp = MakeNilExp(@$);
            std::string temp = driver.makeVar();
            auto& x = driver.quater_var_table;
            x.insert({exp, temp});


            std::string left  = x.count($1) ? x[$1] : "";
            std::string right = x.count($3) ? x[$3] : "";
            driver.doEmit("*", left, 
                               right,
                               temp);
            
            exp->begin = Driver::quater_id;

            $$ = exp;

        }
|       term OPERATOR_DIV factor 
        {
            // auto exp = MakeOpExp(@$, Sample::AST::Operator::DIVIDE, $1, $3);
            auto exp = MakeNilExp(@$);
            std::string temp = driver.makeVar();
            auto& x = driver.quater_var_table;
            x.insert({exp, temp});


            std::string left  = x.count($1) ? x[$1] : "";
            std::string right = x.count($3) ? x[$3] : "";
            driver.doEmit("/", left, 
                               right,
                               temp);

            exp->begin = Driver::quater_id;
            
            $$ = exp;
        }
|       factor 
        {
            $$ = $1;
            auto& x = driver.quater_var_table;
            if (!x.count($1)) {
                std::string temp = driver.makeVar();
                x.insert({$1, temp});
            }
        }
        ;
factor:         
        arithmetic_value 
        {
            $$ = $1;
            auto& x = driver.quater_var_table;
            if (!x.count($1)) {
                std::string temp = driver.makeVar();
                x.insert({$1, temp});
            }
        }
|       OPERATOR_SUB factor 
        {
            // auto exp = MakeOpExp(@$, Sample::AST::Operator::MINUS, MakeIntExp(@1, 0) , $2);
            auto exp =  MakeNilExp(@$);
            std::string temp = driver.makeVar();
            auto& x = driver.quater_var_table;
            x.insert({exp, temp});


            std::string left  = "0";
            std::string right = x.count($2) ? x[$2] : "";
            driver.doEmit("-", left, 
                               right,
                               temp);
            
            exp->begin = Driver::quater_id;
            
            $$ = exp;
        }
        ;

arithmetic_value:   
        TOKEN_INT  
        {
            // $$ = MakeIntExp(@$, $1);
            $$ = MakeNilExp(@$);
            auto& x = driver.quater_var_table;
            if (!x.count($$)) {
                std::string temp = std::to_string($1);
                x.insert({$$, temp});
            }
        }
|       TOKEN_IDENTIFIER 
        {
            // $$ = MakeVarExp(@$, MakeSimpleVar(@$, $1));
            $$ = MakeNilExp(@$);
            auto& x = driver.quater_var_table;
            if (!x.count($$)) {
                std::string temp = $1;
                x.insert({$$, temp});
            }
        }    
|       OPERATOR_PARTHEN_BEGIN arithmetic_exp OPERATOR_PARTHEN_END  
        {
            $$ = $2;
            auto& x = driver.quater_var_table;
            if (!x.count($2)) {
                std::string temp = driver.makeVar();
                x.insert({$2, temp});
            }
        }
        ;

bool_expression:    
        bool_expression KEYWORD_OR M_empty bool_term 
        {
            // auto if_exp = MakeIfExp(@$, nullptr, -1, -1);
            auto if_exp = MakeNilExp(@$);
            // if_exp->begin = $1->begin;
            driver.doBackPatch($1->false_list, $3->begin);
            if_exp->true_list = driver.doMerge($1->true_list, $4->true_list);
            if_exp->false_list = $4->false_list;
            $$ = if_exp;
        }
|       bool_term  
        {
            $$ = $1;
        }
        ;
bool_term:          
        bool_term KEYWORD_AND M_empty bool_factor 
        {
            // auto if_exp = MakeIfExp(@$, nullptr, -1, -1);
            auto if_exp = MakeNilExp(@$);
            driver.doBackPatch($1->true_list, $3->begin);
            if_exp->true_list = $4->true_list;
            if_exp->false_list = driver.doMerge($1->false_list, $4->false_list);
            $$ = if_exp;
        }
|       bool_factor
        {
            $$ = $1;
        }
        ;
bool_factor:        
        bool_value
        {
            $$ = $1;
        }
|       KEYWORD_NOT bool_factor 
        {
            // $$ = MakeIfExp(@$, nullptr, -1, -1);
            $$ = MakeNilExp(@$);
            $$->begin = $2->begin;
            $$->true_list = $2->false_list;
            $$->false_list = $2->true_list;
        }
        ;
bool_value:  
        KEYWORD_TRUE 
        {
            // $$ = MakeIntExp(@$, 1);
            $$ = MakeNilExp(@$);
            driver.doEmit("j", "", "", "0");
            $$->begin = Driver::quater_id;
            $$->true_list = {Driver::quater_id};

        }
|       KEYWORD_FALSE 
        {
            // $$ = MakeIntExp(@$, 0);
            $$ = MakeNilExp(@$);
            driver.doEmit("j", "", "", "0");
            $$->begin = Driver::quater_id;
            $$->false_list = {Driver::quater_id};
        }
|       OPERATOR_PARTHEN_BEGIN  bool_expression  OPERATOR_PARTHEN_END
        {
            // $$ = MakeIntExp(@$, 0);
            $$ = MakeNilExp(@$);
            $$->true_list = $2->true_list;
            $$->false_list = $2->false_list;
        }
|       arithmetic_exp  relation_operator  arithmetic_exp
        {
            auto &x = driver.quater_var_table;
            // (op, arg1, arg2, jmp)
            std::string Op = [=] {
                switch($2) {
                    case Sample::AST::Operator::LT:
                        return "j<";
                    case Sample::AST::Operator::NEQ:
                        return "j<>";
                    case Sample::AST::Operator::LE:
                        return "j<=";
                    case Sample::AST::Operator::GE:
                        return "j>=";
                    case Sample::AST::Operator::GT:
                        return "j>";
                    case Sample::AST::Operator::EQ:
                        return "j=";
                }
                return "";
            }();

            std::string left  = x.count($1) ? x[$1] : "Error!";
            std::string right = x.count($3) ? x[$3] : "Error!";
            // true:
            int now = Driver::quater_id + 1;
            driver.doEmit(Op,  left, 
                               right,
                               "-1");
            
            
            // auto if_ = MakeIfExp(@$, MakeOpExp(@$, $2, $1, $3), now + 2, now + 1);
            auto if_ = MakeNilExp(@$);

            // if_->getCond()->getQuadID() = now;
            if_->begin = now;
            if_->true_list = {now};
            if_->false_list = {now + 1};

            // false:
            driver.doEmit("j", "", 
                               "",
                               "-1");
            $$ = if_;
        }
        ;
relation_operator:      
        OPERATOR_LESS  
        {
            $$ = Sample::AST::Operator::LT;
        }
|       OPERATOR_NEQ
        {
            $$ = Sample::AST::Operator::NEQ;
        }
|       OPERATOR_LEQ
        {
            $$ = Sample::AST::Operator::LE;
        }
|       OPERATOR_GE 
        {
            $$ = Sample::AST::Operator::GE;
        }
|       OPERATOR_GREATER
        {
            $$ = Sample::AST::Operator::GT;
        }
|       OPERATOR_EQUAL      
        {
            $$ = Sample::AST::Operator::EQ;
        }
        ;


// statements

statement:          
        statement_assign      
        {
            $$ = $1;
            
        }
|       KEYWORD_IF bool_expression KEYWORD_THEN M_empty statement  
        {
            int Mbegin = $4->begin;
            driver.doBackPatch($2->true_list, Mbegin);
            // $$ = MakeIfExp(@$, nullptr, -1, -1);
            $$ = MakeNilExp(@$);
            $$->next_list = driver.doMerge($2->false_list, $5->next_list);
        }
|       KEYWORD_IF bool_expression KEYWORD_THEN M_empty statement KEYWORD_ELSE N_empty M_empty statement
        {
            driver.doBackPatch($2->true_list, $4->begin);
            driver.doBackPatch($2->false_list, $8->begin);
            auto temp = driver.doMerge($5->next_list, $7->next_list);
            // $$ = MakeIfExp(@$, nullptr, -1, -1);
            $$ = MakeNilExp(@$);
            $$->next_list = driver.doMerge(temp, $9->next_list);
        }
|       statement_while
        {
            $$ = $1;
        }
|       statement_repeat
        {
            $$ = $1;
        }
|       statement_compund
        {
            $$ = $1;
        }

statement_assign:
        TOKEN_IDENTIFIER OPERATOR_ASSIGN arithmetic_exp 
        {
            // $$ = MakeAssignExp(@$, MakeSimpleVar(@$, $1), $3);
            $$ = MakeNilExp(@$);
            auto& x = driver.quater_var_table;
            std::string rhs  = x.count($3) ? x[$3] : "Error!";
            std::string lhs;
            driver.doEmit(":=", rhs, 
                                lhs,
                                $1);
            $$->begin = Driver::quater_id;
        }
        ;


statement_while:    KEYWORD_WHILE  M_empty bool_expression M_empty KEYWORD_DO statement 
        {
            // $$ = MakeWhileExp(@$, $2, $4);
            $$ = MakeNilExp(@$);
            driver.doBackPatch($6->next_list, $2->begin);
            driver.doBackPatch($3->true_list, $4->begin);
            $$->next_list = $3->false_list;
            driver.doEmit("j", "", "", std::to_string($2->begin));
        }
        ;

M_empty:    %empty
        {
            $$ = MakeNilExp(@$);
            $$->begin = Driver::quater_id + 1;
        }
        ;

N_empty:   %empty 
        {
            $$ = MakeNilExp(@$);
            $$->next_list = {Driver::quater_id + 1};
            driver.doEmit("j", "", "", "-1");
        }
        ;


statement_repeat:   KEYWORD_REPEAT M_empty statement KEYWORD_UNTIL bool_expression 
        {
            $$ = MakeNilExp(@$);
            driver.doBackPatch($5->false_list, $2->begin);
            // $$->true_list = $5->true_list;
            $$->next_list = $5->true_list;
        }
        ;

statement_compund: KEYWORD_BEGIN  statement_table KEYWORD_END  
        {
            $$ = MakeNilExp(@$);
            $$->next_list = $2->next_list;
        }
        ;

statement_table:    statement_table M_empty OPERATOR_SEMICOLON statement      
        {
            $$ = MakeNilExp(@$);
            driver.doBackPatch($1->next_list, $2->begin);
            $$->next_list = $4->next_list;
        }
|       statement                   
        {
            $$ = MakeNilExp(@$);
            $$->next_list = $1->next_list;
        }
        ;

// definition

program:    KEYWORD_PROGRAM TOKEN_IDENTIFIER OPERATOR_SEMICOLON var_description statement_compund OPERATOR_DOT  
            {
                driver.doEmit("sys","", 
                                    "",
                                    "");
                int now = Driver::quater_id;
                driver.doBackPatch($5->next_list, now);
                driver.doEmit("program", $2, "", "");
            }
            ;

var_description:    KEYWORD_VAR var_definition  
            {
                $$ = $2;
            }
|           {   $$ = std::make_shared<Sample::AST::DecList>(); }
            %empty ;

var_definition:     token_table  OPERATOR_COLON token_type  OPERATOR_SEMICOLON  var_definition   
            {
                for (auto &x : *($1)) {
                    std::dynamic_pointer_cast<VarDec>(x)->setTyp($3);
                }
                for (auto &y: *($5)) {
                    $1->push_back(y);
                }
                $$ = $1;

            }
|           token_table  OPERATOR_COLON token_type OPERATOR_SEMICOLON  
            {
                for (auto &x : *($1)) {
                    std::dynamic_pointer_cast<VarDec>(x)->setTyp($3);
                }
                $$ = $1;
            }
            ;

token_table:        TOKEN_IDENTIFIER  OPERATOR_COMMA token_table    
            {
                    $$ = MakeDecList(MakeVarDec(@$, $1, ""s, nullptr), $3);
            }
            |       TOKEN_IDENTIFIER                                
            {
                    $$ = MakeDecList(MakeVarDec(@$, $1, ""s, nullptr), nullptr);
            }
            ;

%%
void Sample::Parser::error (const location_type & l, const string & m) {
    driver.error(l, m);
    driver.syntaxError = true;
}