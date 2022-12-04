#ifndef __DATA_SET_H__
#define __DATA_SET_H__

typedef struct data {
    int tid;
    char* s;
    int type;
} DATA;

DATA* data_new(int type, int tid, char* str);
void data_free(DATA* data);

#endif