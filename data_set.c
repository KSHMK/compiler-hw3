#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "data_set.h"
#include "parser.tab.h"

VAR_DATA VAR_LIST[100] = {0};
int var_count = 0;

DATA* data_new(int type, int tid, char* str)
{
    DATA* data = (DATA*)malloc(sizeof(DATA));
    memset(data, 0, sizeof(DATA));
    data->tid = tid;
    data->type = type;
    data->s = str;
    return data;
}

void data_free(DATA* data)
{
    free(data->s);
    free(data);
}

int var_set(char* var_name, LIST* array_list)
{
    char *tmp_var_name = strdup(var_name);
    int len = strlen(tmp_var_name);
    int var_id;
    if(len > 10)
        tmp_var_name[10] = '\x00';
    
    VAR_LIST[var_count].name = tmp_var_name;
    VAR_LIST[var_count].type = 0;
    VAR_LIST[var_count].array_list = array_list;
    var_id = var_count;
    var_count++;
    return var_id;
}

void var_set_type(LIST* var_list, int type)
{
    LIST* cur = var_list;
    while(cur)
    {
        VAR_LIST[cur->data].type = type;
        VAR_LIST[cur->data].size = 4;
        cur = cur->next;
    }
    list_free(var_list);
}

DATA* var_get(char* var_name)
{
    int i=0;
    char *tmp_var_name = strdup(var_name);
    int len = strlen(tmp_var_name);
    if(len > 10)
        tmp_var_name[10] = '\x00';
    
    for(i=0;i<var_count;i++)
    {
        if(!strcmp(VAR_LIST[i].name, tmp_var_name))
            break;
    }
    
    if(i == var_count)
    {
        free(tmp_var_name);
        return NULL;
    }
    
    return data_new(VAR_LIST[i].type, 0, tmp_var_name);
}

LIST* list_new(int data)
{
    LIST* new = (LIST*)malloc(sizeof(LIST));
    memset(new, 0, sizeof(LIST));
    new->data = data;
    return new;
}

LIST* list_append(LIST* list, LIST* append)
{
    list->next = append;
    return list;
}

void list_free(LIST* list)
{
    LIST* tmp = list;
    while(list)
    {
        tmp = list->next;
        free(list);
        list = tmp;
    }
}

int var_size(LIST* arr_list)
{
    int size = 1;
    while(arr_list)
    {
        size *= arr_list->data;
        arr_list = arr_list->next;
    }
    return size;
}

void var_save()
{
    FILE* out = fopen("sbt.out","w");
    int offset = 0;
    for(int i=0;i<var_count;i++)
    {
        fprintf(out, "%s\t", VAR_LIST[i].name);
        if(VAR_LIST[i].type == INTEGER)
            fprintf(out, "int\t");
        else
            fprintf(out, "double\t");
        fprintf(out, "%d\n", offset);

        offset += var_size(VAR_LIST[i].array_list) * VAR_LIST[i].size;
    }
}

void var_free()
{
    for(int i=0;i<var_count;i++)
    {
        free(VAR_LIST[i].name);
        list_free(VAR_LIST[i].array_list);
    }
}