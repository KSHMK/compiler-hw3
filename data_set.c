#include <stdlib.h>
#include <string.h>
#include "data_set.h"

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
