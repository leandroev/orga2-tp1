#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
    
    list_t* l= listNew(string);
   	
   	listAdd(l, "a");
   	listAdd(l, "b");
   	listAdd(l, "c");
   	listAdd(l, "d");
   	listAdd(l, "e");
   	listAdd(l, "f");
   	listAdd(l, "g");
   	listAdd(l, "h");
   	listAdd(l, "i");
   	listAdd(l, "j");
   	
   	list_t* lf= listNew(float);
   	
   	listAdd(lf, 1);
   	listAdd(lf, 3.56);
   	listAdd(lf, 3.567);
   	listAdd(lf, 8.2);
   	listAdd(lf, 0.45);
   	listAdd(lf, -1.34);
   	listAdd(lf, 4.5);
   	listAdd(lf, -3.789);
   	listAdd(lf, 15.34);
   	listAdd(lf, 120.23);

    list_t* l_c= listClone(l);
    list_t* lf_c= listClone(lf);

    listPrint(l, pfile);
    listPrint(lf, pfile);

    listDelete(l, pfile);
    listDelete(l_c, pfile);
    listDelete(lf, pfile);
    listDelete(lf_c, pfile);
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


