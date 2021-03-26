
#include "sample_ast.hpp"

namespace Sample {
namespace AST {
// Var-------------------------------------

Var::Var(Sample::location loc, VariableType classType)
    : ASTNode(loc), classType(classType) {}

VariableType Var::getClassType() const { return classType; }

// Exp-------------------------------------

Exp::Exp(Sample::location loc, ExpressionType classType)
    : ASTNode(loc), classType(classType) {}

ExpressionType Exp::getClassType() { return classType; }

// Dec---------------------------------------
Dec::Dec(Sample::location loc, DeclarationType classType)
    : ASTNode(loc), classType(classType) {}

DeclarationType Dec::getClassType() { return classType; }

// NilExp-----------------------------------------------
NilExp::NilExp(Sample::location loc) : Exp(loc, NIL_EXP) {}

// VarDec-----------------------------------
VarDec::VarDec(Sample::location loc, const string &var, const string &typ,
               const shared_ptr<Exp> &init, bool escape)
    : Dec(loc, VAR_DEC), var(var), typ(typ), init(init), escape(escape) {}

const string &VarDec::getVar() const { return var; }
const string &VarDec::getTyp() const { return typ; }
const shared_ptr<Exp> &VarDec::getInit() const { return init; }
shared_ptr<Exp> MakeNilExp(Sample::location loc) {
    return make_shared<NilExp>(loc);
}
shared_ptr<Dec> MakeVarDec(Sample::location loc, const string &var,
                           const string &typ, shared_ptr<Exp> init) {
    return make_shared<VarDec>(loc, var, typ, init, true);
}
shared_ptr<DecList> MakeDecList(shared_ptr<Dec> head,
                                shared_ptr<DecList> tail) {
    if (!tail) 
        tail = make_shared<DecList>();
    tail->push_front(head);
    return tail;
}
}  // namespace AST
}  // namespace Sample