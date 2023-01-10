%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

// Reference to lexical analyser variables
extern int lines;
extern int lex_errors;

int synt_errors;
int print_error(const char* const fmt, ...);

int yylex();
int yyerror(const char* const msg);
%}

%token TYPE_INT
%token TYPE_FLOAT
%token TYPE_BOOLEAN
%token TYPE_STRING

%token REPEAT
%token MAIN

%token IDENTIFIER

%token OPEN_PAREN CLOSE_PAREN
%token OPEN_BRACKET CLOSE_BRACKET
%token COMMA SEMICOLON

%token LITERAL_INT
%token LITERAL_FLOAT
%token LITERAL_BOOLEAN
%token LITERAL_STRING

%token OP_ATRIB
%token OP_ARITH

%%

/* Rules */

%start Program;

Program:
      TYPE_INT MAIN OPEN_PAREN Arguments CLOSE_PAREN Statement_Block
    | error { yyerror("Program does not contain a 'main' function"); }
    ;

Statement_Block:
    OPEN_BRACKET Statement_Block_Rep CLOSE_BRACKET
    ;

Statement_Block_Rep:
      /* empty */
    | Statement_Block_Rep Statement_Block
    | Statement_Block_Rep Statement
    ;

Statement:
      Declaration { printf("Line %d: Found a declaration\n", lines); }
    | Attribution { printf("Line %d: Found an attribution\n", lines); }
    | Loop { printf("Line %d: Found a loop command\n", lines); }
    | error { yyerror("Ill-formed statement"); }
    ;

Declaration:
    Type Identifier_List SEMICOLON
    ;

Type:
      TYPE_INT
    | TYPE_FLOAT
    | TYPE_BOOLEAN
    | TYPE_STRING
    ;

Arguments:
      /* empty */
    | Identifier_List
    | error { yyerror("Invalid argument list for 'main' function"); }
    ;

Identifier_List:
      IDENTIFIER
    | IDENTIFIER COMMA Identifier_List
    | error { yyerror("Ill-formed identifier list"); }
    ;

Attribution:
    IDENTIFIER OP_ATRIB Expression SEMICOLON
    ;

Loop:
    REPEAT OPEN_PAREN Expression CLOSE_PAREN Statement_Block
    ;

Expression:
      LITERAL_INT
    | LITERAL_FLOAT
    | LITERAL_BOOLEAN
    | LITERAL_STRING
    | IDENTIFIER
    | Expression OP_ARITH Expression
    | OPEN_PAREN Expression CLOSE_PAREN
    ;

%%

int print_error(const char* const fmt, ...) {
    va_list args;
    va_start(args, fmt);

    printf("[ERROR] Line %d: ", lines);
    vprintf(fmt, args);
    putchar('\n');

    va_end(args);
}

int yyerror(const char* const msg) {
    synt_errors++;
    return print_error(msg);
}

int main (int argc, char **argv) {
    yyparse();

    printf("Program analysis finished\n");
    printf("Syntactical errors: %d, Lexical errors: %d\n", synt_errors, lex_errors);

    return EXIT_SUCCESS;
}