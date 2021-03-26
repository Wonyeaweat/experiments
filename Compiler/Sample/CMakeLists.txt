cmake_minimum_required(VERSION 3.5)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_BUILD_TYPE Debug CACHE STRING "")
set(CMAKE_CXX_FLAGS_DEBUG "-ggdb3 -O0 -DDEBUG" CACHE STRING "" FORCE)


project(parser_Sample)


find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

bison_target(PARSER Sample.y 
                ${CMAKE_CURRENT_BINARY_DIR}/sample_parser.cpp
            DEFINES_FILE ${CMAKE_CURRENT_BINARY_DIR}/sample_parser.hpp
            VERBOSE REPORT_FILE ${CMAKE_CURRENT_BINARY_DIR}/sample_bison.out)

flex_target(LEXER Sample.l 
                ${CMAKE_CURRENT_BINARY_DIR}/sample_lexer.cpp)

add_flex_bison_dependency(LEXER PARSER)

include_directories(${CMAKE_CURRENT_BINARY_DIR})
set(src sample_ast.cpp sample_driver.cpp sample.cpp)

add_executable(Sample ${src} ${BISON_PARSER_OUTPUTS} ${FLEX_LEXER_OUTPUTS})
# target_link_libraries(Sample ${FLEX_LIBRARIES})