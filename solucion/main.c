#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
    
    list_t* l= listNew(TypeString);
   	
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
   	
   	list_t* lf= listNew(TypeFloat);
   	
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
	
	tree_t* arbol = treeNew(TypeInt, TypeString, 1);
	
	treeInsert(arbol, 24, "papanatas");
	treeInsert(arbol, 34, "rima");
	treeInsert(arbol, 24, "buscabullas");
	treeInsert(arbol, 11, "musica");
	treeInsert(arbol, 31, "Pikachu");
	treeInsert(arbol, 11, "Bulbasaur");
	treeInsert(arbol, -2, "Charmander");

	tree_t* arbol_2 = treeNew(TypeInt, TypeString, 1);

	treeInsert(arbol_2, -2, "Charmander");
	treeInsert(arbol_2, 11, "Bulbasaur");
	treeInsert(arbol_2, 31, "Pikachu");
	treeInsert(arbol_2, 11, "musica");
	treeInsert(arbol_2, 24, "buscabullas");
	treeInsert(arbol_2, 34, "rima");
	treeInsert(arbol_2, 24, "papanatas");

	treePrint(arbol, pfile);
	treePrint(arbol_2, pfile);

	treeDelete(arbol);
	treeDelete(arbol_2);
    
}

void test_document(FILE *pfile){
    document_t* doc = docNew(6, TypeInt, 83, TypeInt, 125, TypeFloat, 12.5, TypeFloat, 1.34, TypeString, "Hola", TypeString, "Chau");
    document_t* doc_c= docClone(doc);
    docPrint(doc, pfile);
    docPrint(doc_c, pfile);
    docDelete(doc);
    docDelete(doc_c);

}

int main (void){
    FILE *pfile = fopen("salida.caso.propios.txt","w");
    test_list(pfile);
    test_tree(pfile);
    test_document(pfile);
    fclose(pfile);
    return 0;
}


