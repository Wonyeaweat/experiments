#include <cerrno>
#include <climits>
#include <cstdlib>
#include <cstring>

#include "sample_driver.hpp"
#include "sample_parser.hpp"

extern FILE* yyin;
extern int yy_flex_debug;

Sample::Driver::Driver()
    : trace_scanning(false), trace_parsing(false), syntaxError(false) {}

Sample::Driver::~Driver(){};
int Sample::Driver::quater_id = 0;
int Sample::Driver::temp_var_count = 0;

int Sample::Driver::parse(const std::string& filename) {
    this->filename = filename;
    scan_begin();
    Sample::Parser parser(*this);
    parser.set_debug_level(trace_parsing);
    int res = parser.parse();
    scan_end();
    return res;
}

void Sample::Driver::scan_begin(void) {
    yy_flex_debug = trace_scanning;
    if (filename.empty() || filename == "-") {
        yyin = stdin;
    } else if (!(yyin = fopen(filename.c_str(), "r"))) {
        std::cerr << "Cannot open file : " << filename << " " << strerror(errno)
                  << std::endl;
        exit(1);
    }
}

void Sample::Driver::scan_end(void) { fclose(yyin); }