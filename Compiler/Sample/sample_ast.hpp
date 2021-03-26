#ifndef SAMPLE_AST_HPP
#define SAMPLE_AST_HPP

#include <iostream>
#include <iterator>
#include <list>
#include <memory>
#include <string>

#include "location.hh"

namespace Sample {

namespace AST {
using namespace std;
class Dec;

using DecList = list<shared_ptr<Dec>>;

// Base class
class ASTNode {
    Sample::location loc;

   public:
    ASTNode(Sample::location &loc) { this->loc = loc; }
    const Sample::location &getLoc() const { return loc; }
};
enum VariableType { SIMPLE_VAR, FIELD_VAR, SUBSCRIPT_VAR };
class Var : public ASTNode {
    VariableType classType;

   public:
    Var(Sample::location loc, VariableType classType);

    virtual ~Var(){};

    VariableType getClassType() const;
};

enum Operator { PLUS, MINUS, TIMES, DIVIDE, EQ, NEQ, LT, LE, GT, GE };

// Exp - Base class for all expression nodes
enum ExpressionType {
    NIL_EXP
};

class Exp : public ASTNode {
    ExpressionType classType;

   public:
    int begin = 0;
    std::list<int> true_list;
    std::list<int> false_list;
    std::list<int> next_list;

    Exp(Sample::location loc, ExpressionType classType);
    virtual ~Exp(){};
    ExpressionType getClassType();
};

// Dec - Base class for all declaration nodes
enum DeclarationType { FUNCTION_DEC, VAR_DEC, TYPE_DEC };

class Dec : public ASTNode {
    DeclarationType classType;

   public:
    Dec(Sample::location loc, DeclarationType classType);

    virtual ~Dec(){};

    DeclarationType getClassType();
};

// NilExp - Extend class for all nil expression nodes
class NilExp : public Exp {
   public:
    NilExp(Sample::location loc);
};
// VarDec - Extend class for all varible declaration
class VarDec : public Dec {
    string var, typ;
    shared_ptr<Exp> init;
    bool escape;

   public:
    VarDec(Sample::location loc, const string &var, const string &typ,
           const shared_ptr<Exp> &init, bool escape);

    const string &getVar() const;
    void setVar(const string &var_) { var = var_; }
    void setTyp(const string &type_) { typ = type_; }

    const string &getTyp() const;

    const shared_ptr<Exp> &getInit() const;

    bool isEscape() const;

    void setEscape(bool escape);
};
// Exp::
shared_ptr<Dec> MakeVarDec(Sample::location loc, const string &var, const string &typ, shared_ptr<Exp> init);

shared_ptr<Exp> MakeNilExp(Sample::location loc);
shared_ptr<DecList> MakeDecList(shared_ptr<Dec> head, shared_ptr<DecList> tail);

}  // namespace AST
}  // namespace Sample

#endif  // SAMPLE_AST_HPP
