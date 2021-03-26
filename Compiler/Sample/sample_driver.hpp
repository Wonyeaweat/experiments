#ifndef SAMPLE_DRIVER_HH
#define SAMPLE_DRIVER_HH

#include <cstdio>
#include <string>
#include <unordered_map>

#include "sample_ast.hpp"

// bison
#include "location.hh"
#include "position.hh"
#include "sample_parser.hpp"

#define YY_DECL Sample::Parser::symbol_type yylex(Sample::Driver& driver)
YY_DECL;

namespace Sample {
class Driver {
   public:
    std::unordered_map<std::shared_ptr<Sample::AST::Exp>, std::string>
        quater_var_table;

    std::unordered_map<std::shared_ptr<Sample::AST::Exp>, int> quater_exp_table;

    std::unordered_map<int, std::shared_ptr<Sample::AST::Exp>> quater_id_table;

    struct Quat {
        std::string id;
        std::string op;
        std::string arg1;
        std::string arg2;
        std::string res;
    };
    std::vector<Quat> quater_res;

    static int quater_id;
    static int temp_var_count;
    bool syntaxError;
    bool trace_parsing;
    bool trace_scanning;
    std::string filename;
    std::shared_ptr<AST::Exp> result;
    std::shared_ptr<AST::DecList> var_dec;
    Driver();
    virtual ~Driver();
    void scan_begin();
    void scan_end();
    int parse(const std::string& filename);

    void error(const Sample::location& l, const std::string& m) {
        std::cerr << l << ": " << m << std::endl;
        exit(1);
    }
    int nextExpr() { return ++quater_id; }
    void printExprID() { printf("(%d) ", nextExpr()); }

    Quat&
    doGetRes(const std::shared_ptr<Sample::AST::Exp>& p) 
      {
          int id = quater_exp_table.count(p);
          int n = quater_exp_table[p];
          assert(id && n <= quater_res.size());
          return quater_res[n - 1];
      }
    void doEmit(const std::string& op, const std::string& arg1,
                const std::string& arg2, const std::string& res) {
        quater_res.push_back(
            {std::to_string(nextExpr()), op, (arg1.size() ? arg1 : "-"),
             (arg2.size() ? arg2 : "-"), (res.size() ? res : "-")});

        // printf("(%s, %s, %s, %s)\n", op.c_str(),
        //                              arg1.size() ? arg1.c_str() : "-",
        //                              arg2.size() ? arg2.c_str() : "-",
        //                              res.size() ? res.c_str() : "-");
    }
    std::string makeVar() {
        ++temp_var_count;
        using namespace std::string_literals;
        return "T"s + std::to_string(temp_var_count);
    }

    std::list<int>
    doMerge(std::list<int>& p1,
                 std::list<int>& p2) {

        if (!p2.size()) return p1;
        quater_res[p2.back() - 1].res = std::to_string(*p1.begin());
        std::list<int> res = p2;
        for (int x: p1)
            res.push_back(x);
        return res;
    }

    void doBackPatch(const std::list<int>& p1, int t) {
        for(int x: p1) 
            quater_res[x - 1].res = std::to_string(t);
    }
};

}  // namespace Sample

#endif  // ! SAMPLE_DRIVER_HH