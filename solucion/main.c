#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
    listNew(string);
    for(int i=0; i<10; i++){
    	listAdd(l, )
    }
}

void test_tree(FILE *pfile){
    
}

void test_document(FILE *pfile){
    docNew(0);
    docClone();
    docPrint();
    docPrint();
    docDelete();
    docDelete();

}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_list(pfile);
    test_tree(pfile);
    test_document(pfile);
    fclose(pfile);
    return 0;
}


