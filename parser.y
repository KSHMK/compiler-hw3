
%{
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include "data_set.h"

int CHAR_NUMBER;
int LINE_NUMBER;
int TEMP_VAR_COUNT = 1;

FILE* FILE_MIDDLE;

DATA* unary_handle(char op, DATA* in);
DATA* opcode_handle(char op, DATA* l, DATA* r);
DATA* assign_handle(char* var, DATA* in);
LIST* var_def_array_handle(char* array_int, LIST* list);
LIST* var_array_handle(DATA* array_data, LIST* list);
void prnt_var_array(LIST* list);
void p_out(char* str, ...);

void yyerror(char * str);
void lexerror(char *str);
int yylex(void);

%}


%union {
    char* sval;
    DATA* dval;
    LIST* list;
}


%token <sval> INTEGER 
%token <sval> VARIABLE 
%token <sval> DOUBLE
%token <sval> TYPE_INTEGER
%token <sval> TYPE_DOUBLE

%left '+' '-'
%left '*' '/'
%right '='
%nonassoc UNARY

%type <dval> factor expr_unary expr_mul expr_add expr assign_state var_list
%type <list> var_array var_def_list var_def_array var_define

%%
program:
    state ';'
    | program state ';'       
    |
    | error ';'                
    ;

state:
    assign_state            { data_free($1); }
    | type_state
    ;

type_state:
    TYPE_INTEGER var_define     { var_set_type($2, INTEGER); }
    | TYPE_DOUBLE var_define    { var_set_type($2, DOUBLE); }
    ;

var_define:
    var_def_list                    
    | var_define ',' var_def_list   { $$=list_append($1, $3); }
    ;

var_def_list:
    VARIABLE var_def_array      { LIST_DATA data; data.i = var_set($1, $2); $$=list_new(data, 0); }

var_def_array:
    '[' INTEGER ']' var_def_array   { $$=var_def_array_handle($2, $4); }
    |                           { $$=NULL; }
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
    | var_list                  
    | DOUBLE                    { $$=data_new(DOUBLE, 0, $1); }
    | '(' expr ')'              { $$=$2; }
    ;

var_list:
    VARIABLE var_array          { $$=var_get($1, $2); }

var_array:
    '[' expr ']' var_array      { $$=var_array_handle($2, $4); }
    |                           { $$=NULL; }
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
    DATA* tmp_num;
    if(l->type != r->type)
    {
        tmp_num = get_temp_var(DOUBLE);
        if(l->type == INTEGER)
        {
            p_out("%s = inttoreal %s", tmp_num->s, l->s);
            data_free(l);
            l = tmp_num;
        }
        else {
            p_out("%s = inttoreal %s", tmp_num->s, r->s);
            data_free(r);
            r = tmp_num;
        }
    }
    int type = l->type;
    
    DATA* tmp = get_temp_var(type);
    p_out("%s = %s %c %s", tmp->s, l->s, op, r->s);
    data_free(l);
    data_free(r);
    return tmp;
}

LIST* var_def_array_handle(char* array_int_str, LIST* list)
{
    
    LIST_DATA data; 
    data.i = atoi(array_int_str);
    free(array_int_str);
    return list_append(list_new(data, 0), list);
}

LIST* var_array_handle(DATA* array_data, LIST* list)
{
    LIST_DATA data;
    data.s = strdup(array_data->s);
    data_free(array_data);
    return list_append(list_new(data, 1), list);
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
    printf("lexical error(%d:%d): %s\n", LINE_NUMBER, CHAR_NUMBER, str);
}

void yyerror(char *str) {
    printf("%s(%d)\n", str, LINE_NUMBER);
}

int main(void) {
    FILE_MIDDLE = fopen("ic.out","wb");
    LINE_NUMBER = 1;
    CHAR_NUMBER = 0;

    yyparse();
    var_save();
    var_free();
    fclose(FILE_MIDDLE);

    return 0;
}