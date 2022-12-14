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
        VAR_LIST[cur->data.i].type = type;
        VAR_LIST[cur->data.i].size = 4;
        cur = cur->next;
    }
    list_free(var_list);
}

DATA* var_get(char* var_name, LIST* var_list)
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
    
    if(var_list != NULL)
    {
        char *array_str = (char*)malloc(1000);
        char tmp[30] = {0};
        memset(array_str, 0, 1000);
        strcat(array_str, tmp_var_name);
        while(var_list)
        {
            sprintf(tmp, "[%s]", var_list->data.s);
            strcat(array_str, tmp);
            var_list = var_list->next;
        }
        
        free(tmp_var_name);
        tmp_var_name = array_str;
    }

    return data_new(VAR_LIST[i].type, 0, tmp_var_name);
}

LIST* list_new(LIST_DATA data, int type)
{
    LIST* new = (LIST*)malloc(sizeof(LIST));
    memset(new, 0, sizeof(LIST));
    new->data = data;
    new->type = type;
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
        if(list->type == 1)
            free(list->data.s);
        free(list);
        list = tmp;
    }
}

int var_size(LIST* arr_list)
{
    int size = 1;
    while(arr_list)
    {
        size *= arr_list->data.i;
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
        if(VAR_LIST[i].array_list == NULL)
        {
            if(VAR_LIST[i].type == INTEGER)
                fprintf(out, "int\t");
            else if(VAR_LIST[i].type == DOUBLE)
                fprintf(out, "double\t");
        }
        else
        {
            int ac = 0;
            LIST* ar = VAR_LIST[i].array_list;
            while(ar)
            {
                fprintf(out, "array(%d, ",ar->data.i);
                ar = ar->next;
                ac++;
            }
            if(VAR_LIST[i].type == INTEGER)
                fprintf(out, "int");
            else if(VAR_LIST[i].type == DOUBLE)
                fprintf(out, "double");
            for(int i=0;i<ac;i++)
                fprintf(out,")");
            fprintf(out,"\t");
        }
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