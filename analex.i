%{
#include <math.h>
#include <string.h>
#include <limits.h>

#include "grammar.h"

int lines = 1;
int lex_errors;

extern int print_error(const char* const fmt, ...);
%}

%x IN_STRING

DIGIT       [0-9]
NUMBER      {DIGIT}+
INTEGER     [+-]?{NUMBER}
FLOAT       {INTEGER}"."{NUMBER}?
LETTER      [a-zA-Z_]
ALPHA       {DIGIT}|{LETTER}
ID          {LETTER}{ALPHA}*
SPACE       [ \t]
BOOLEAN     true|false
DIVISOR     [(){},;]
OPERATOR    <>|[&|^]|[-+*/]|[<>](=?)|"?="
ATRIB       =|"+="|"-="|"*="|"/="

%%

    char str_buff[1024];
    char *str_ptr;

<IN_STRING>{
    \" {
        *str_ptr = '\0';
        BEGIN(INITIAL);
        printf("A string: \"%s\"\n", str_buff);
        return LITERAL_STRING;
    }

    . {
        *str_ptr++ = *yytext;
    }

    [\n] {
        *str_ptr = '\0';
        print_error("Unterminated string literal \"%s\"", str_buff);
        lex_errors++;
        lines++;
        BEGIN(INITIAL);
        return LITERAL_STRING;
    }

    <<EOF>> {
        *str_ptr = '\0';
        print_error("Unterminated string literal \"%s\"", str_buff);
        lex_errors++;
        yyterminate();
    }
}

\" {
    str_ptr = str_buff;
    BEGIN(IN_STRING);
}

"//".* {
    /* Consume the comment and do nothing */
}

{BOOLEAN} {
    printf("A boolean literal: %s (%d)\n",
        yytext, strcmp(yytext, "true") == 0 ? 1 : 0);
    return LITERAL_BOOLEAN;
}

{ID} {
    if (strcmp(yytext, "int") == 0) {
        return TYPE_INT;
    }

    if (strcmp(yytext, "float") == 0) {
        return TYPE_FLOAT;
    }

    if (strcmp(yytext, "bool") == 0) {
        return TYPE_BOOLEAN;
    }

    if (strcmp(yytext, "string") == 0) {
        return TYPE_STRING;
    }

    if (strcmp(yytext, "repeat") == 0) {
        return REPEAT;
    }

    if (strcmp(yytext, "main") == 0) {
        return MAIN;
    }

    printf("An identifier/type: \"%s\"\n", yytext);
    return IDENTIFIER;
}

{INTEGER} {
    long int value = strtol(yytext, NULL, 0);

    if (errno == ERANGE && (value == LONG_MIN || value == LONG_MAX)) {
        print_error("Unrepresentable Number (%s)", yytext);
        lex_errors++;
        return LITERAL_INT;
    }
    else {
        printf("An integer: \"%s\" (%ld)\n", yytext, value);
        return LITERAL_INT;
    }
}

{FLOAT} {
    printf("A float: \"%s\" (%f)\n", yytext, atof(yytext));
    return LITERAL_FLOAT;
}

{DIVISOR} {
    switch(*yytext) {
        case '(': return OPEN_PAREN;
        case ')': return CLOSE_PAREN;
        case '{': return OPEN_BRACKET;
        case '}': return CLOSE_BRACKET;
        case ',': return COMMA;
        case ';': return SEMICOLON;
    }

    printf("A divisor: \"%c\"\n", *yytext);
}

{ATRIB} {
    printf("An attribution: \"%s\"\n", yytext);
    return OP_ATRIB;
}

{OPERATOR} {
    printf("An operator: \"%s\"\n", yytext);
    return OP_ARITH;
}

{SPACE}+ {
    /* Consume the whitespace and do nothing */
}

{NUMBER}{ALPHA}+ {
    print_error("Invalid identifier \"%s\"", yytext);
    lex_errors++;
    return IDENTIFIER;
}

"."{NUMBER}+ {
    print_error("Invalid floating-point constant \"%s\"", yytext);
    lex_errors++;
    return LITERAL_FLOAT;
}

[\n] {
    lines++;
}

. {
    print_error("Unrecognized character: \"%c\"", *yytext);
    lex_errors++;
}

%%

int yywrap(void);

int yywrap() {
    return 1;
}
