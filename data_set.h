#ifndef __DATA_SET_H__
#define __DATA_SET_H__

typedef struct data {
    int tid;
    char* s;
    int type;
} DATA;

typedef union list_data {
    int i;
    char* s;
} LIST_DATA;

typedef struct link_list {
    LIST_DATA data;
    int type;
    struct link_list* next;
} LIST;

typedef struct var_data {
    char* name;
    int type;
    int size;
    LIST* array_list;
} VAR_DATA;



DATA* data_new(int type, int tid, char* str);
void data_free(DATA* data);

LIST* list_new(LIST_DATA data, int type);
LIST* list_append(LIST* list, LIST* append);
void list_free(LIST* list);

int var_set(char* var_name, LIST* arr_list);
void var_set_type(LIST* var_list, int type);
DATA* var_get(char* var_name, LIST* var_list);
void var_save(void);
void var_free(void);


#endif