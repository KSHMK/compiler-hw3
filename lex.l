%{
#include <stdlib.h>
#include "data_set.h"
#include "parser.tab.h"

void lexerror(char *str);
extern int CHAR_NUMBER;
extern int LINE_NUMBER;
int check = 0;

%}

%option noyywrap

%%

[a-zA-Z][0-9a-zA-Z]* {
    yylval.sval = strdup(yytext);
    CHAR_NUMBER += yyleng;
    return VARIABLE;
}

[0-9]+  {
    yylval.sval = strdup(yytext);
    CHAR_NUMBER += yyleng;
    return INTEGER;
}

[0-9]*\.[0-9]+ {
    yylval.sval = strdup(yytext);
    CHAR_NUMBER += yyleng;
    return DOUBLE;
}

[-+()=/*;] { CHAR_NUMBER += yyleng; return *yytext; }

[\n] { CHAR_NUMBER = 0; LINE_NUMBER++; }

[ \t]   { CHAR_NUMBER += yyleng; }

.   lexerror(yytext);

%%

int checker(int t)
{
    if(check && t)
        return 1;
    
}