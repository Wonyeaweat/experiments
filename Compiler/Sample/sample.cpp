#include <fstream>
#include <iostream>
#include <string>
#include <functional>
#include "sample_driver.hpp"
int main(int argc, char *argv[]) {
    Sample::Driver driver;
    // driver.trace_parsing = true;
    // driver.trace_scanning = true;
    if (argc != 2 && argc != 3) {
        fprintf(stderr, "Usage:\n Sample <Source file> [Output file]\n");
        exit(0);
    }
    FILE *fp = (argc == 3 ? fopen(argv[2], "w") : stdout);
    std::unique_ptr<FILE, std::function<void (FILE*)>> out_file(fp, [](FILE* fp) {
        fclose(fp);
    });

    std::string compile_file_name = argv[1];
    // Start to compile
    driver.parse(compile_file_name);
    if (driver.syntaxError) {
        fprintf(stderr, "Sample terminated with exit code 1.\n");
        exit(1);
    }
    auto print_quat = [fp](const Sample::Driver::Quat& x) {
        fprintf(fp, "(%2s) (%-2s, %-2s, %-2s, %-2s)\n", x.id.c_str(), x.op.c_str(), x.arg1.c_str(),
               x.arg2.c_str(), x.res.c_str());
    };
    
    driver.quater_res.back().id = "0";
    print_quat(driver.quater_res.back());
    driver.quater_res.pop_back();
    for (auto &x : driver.quater_res)
        print_quat(x);
    
    // std::cout << driver.var_dec->size() << " Variable(s):\n";
    // for (auto &x : *(driver.var_dec))
    //     std::cout << std::dynamic_pointer_cast<Sample::AST::VarDec>(x)->getVar()
    //               << " "
    //               << std::dynamic_pointer_cast<Sample::AST::VarDec>(x)->getTyp()
    //               << "\n";
    return 0;
}