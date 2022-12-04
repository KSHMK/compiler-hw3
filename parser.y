
%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include "data_set.h"

int CHAR_NUMBER;
int LINE_NUMBER;
int TEMP_VAR_COUNT = 1;

FILE* FILE_MIDDLE;

DATA* unary_handle(char op, DATA* in);
DATA* opcode_handle(char op, DATA* l, DATA* r);
DATA* assign_handle(char* var, DATA* in);
void p_out(char* str, ...);

void yyerror(char * str);
void lexerror(char *str);
int yylex(void);

%}


%union {
    char* sval;
    DATA* dval;
}


%token <sval> INTEGER 
%token <sval> VARIABLE 
%token <sval> DOUBLE

%left '+' '-'
%left '*' '/'
%right '='
%nonassoc UNARY

%type <dval> factor expr_unary expr_mul expr_add expr assign_state

%%
program:
    assign_state ';'
    | program assign_state ';'       { data_free($2); }
    |
    | error ';'                
    ;
assign_state:
    expr                        
    | VARIABLE '=' assign_state { $$=assign_handle($1, $3); } 
    ;

expr:
    expr_add                    
    ;

expr_add:
    expr_add '+' expr_mul       { $$=opcode_handle('+', $1, $3); }
    | expr_add '-' expr_mul     { $$=opcode_handle('-', $1, $3); }
    | expr_mul                  
    ;

expr_mul:
    expr_mul '*' expr_unary     { $$=opcode_handle('*', $1, $3); }
    | expr_mul '/' expr_unary   { $$=opcode_handle('/', $1, $3); }
    | expr_unary                
    ;

expr_unary:
    '+' expr_unary %prec UNARY   { $$=unary_handle('+', $2); }
    | '-' expr_unary %prec UNARY { $$=unary_handle('-', $2); }
    | factor                   
    ;

factor:
    INTEGER                     { $$=data_new(INTEGER, 0, $1); }
    | VARIABLE                  { $$=data_new(INTEGER, 0, $1); }
    | DOUBLE                    { $$=data_new(DOUBLE, 0, $1); }
    | '(' expr ')'              { $$=$2; }
    ;


%%

DATA* get_temp_var(int type)
{
    char* str = (char*)malloc(sizeof(char)*20);
    memset(str, 0, sizeof(char)*20);
    sprintf(str, "t%d", TEMP_VAR_COUNT);

    DATA* data = data_new(type, TEMP_VAR_COUNT, str);

    TEMP_VAR_COUNT++;
    return data;
}

DATA* unary_handle(char op, DATA* in)
{
    DATA* tmp = get_temp_var(in->type);
    p_out("%s = %c%s", tmp->s, op, in->s);
    data_free(in);
    return tmp;
}

DATA* assign_handle(char* var, DATA* in)
{
    p_out("%s = %s", var, in->s);
    free(var);
    return in;
}

DATA* opcode_handle(char op, DATA* l, DATA* r)
{
    int type = l->type;
    if(r->type == DOUBLE)
        type = DOUBLE;
    
    DATA* tmp = get_temp_var(type);
    p_out("%s = %s %c %s", tmp->s, l->s, op, r->s);
    data_free(l);
    data_free(r);
    return tmp;
}

void p_out(char* str, ...)
{
    va_list vl;
    va_start(vl, str);
    vfprintf(FILE_MIDDLE, str, vl);
    fprintf(FILE_MIDDLE, "\n");
    va_end(vl);
}

void lexerror(char *str) {
    fprintf(FILE_MIDDLE, "lexical error(%d:%d): %s\n", LINE_NUMBER, CHAR_NUMBER, str);
}

void yyerror(char *str) {
    fprintf(FILE_MIDDLE, "%s(%d)\n", str, LINE_NUMBER);
}

int main(void) {
    FILE_MIDDLE = fopen("ic.out","wb");
    LINE_NUMBER = 1;
    CHAR_NUMBER = 0;

    yyparse();
    fclose(FILE_MIDDLE);
    return 0;
}