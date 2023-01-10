cmake_minimum_required(VERSION 3.24)
project(CompilerStep1 C)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

set(CMAKE_C_STANDARD 99)

bison_target(CompilerStep1 grammar.y grammar.c)
flex_target(CompilerStep1 analex.i analex.c)

add_executable(CompilerStep1 grammar.c analex.c)
