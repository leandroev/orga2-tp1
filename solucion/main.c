#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "lib.h"

void test_list(FILE *pfile){
    
    list_t* l= listNew(TypeString);
   	
   	listAdd(l, strClone("a"));
   	listAdd(l, strClone("d"));
   	listAdd(l, strClone("e"));
   	listAdd(l, strClone("b"));
   	listAdd(l, strClone("c"));
   	listAdd(l, strClone("j"));
   	listAdd(l, strClone("h"));
   	listAdd(l, strClone("f"));
   	listAdd(l, strClone("g"));
   	listAdd(l, strClone("i"));
   	
   	list_t* lf= listNew(TypeFloat);
   	
   	float dataf1 = 1.0f;    listAdd(lf, floatClone(&dataf1));
   	float dataf2 = 3.56f;   listAdd(lf, floatClone(&dataf2));
   	float dataf3 = 3.567f;  listAdd(lf, floatClone(&dataf3));
   	float dataf4 = 8.2f;    listAdd(lf, floatClone(&dataf4));
   	float dataf5 = 0.45f;   listAdd(lf, floatClone(&dataf5));
   	float dataf6 = -1.34f;  listAdd(lf, floatClone(&dataf6));
   	float dataf7 = 4.5f;    listAdd(lf, floatClone(&dataf7));
   	float dataf8 = 3.789f;  listAdd(lf, floatClone(&dataf8));
   	float dataf9 = 15.34f;  listAdd(lf, floatClone(&dataf9));
   	float dataf10 = 120.23f;listAdd(lf, floatClone(&dataf10));

    list_t* l_c= listClone(l);
    list_t* lf_c= listClone(lf);

    listPrint(l, pfile);
    listPrint(lf, pfile);

    listDelete(l);
    listDelete(l_c);
    listDelete(lf);
    listDelete(lf_c);
}

void test_tree(FILE *pfile){
	
	tree_t* arbol = treeNew(TypeInt, TypeString, 1);
	int32_t intA;
	intA = 24; treeInsert(arbol, &intA, "papanatas");
	intA = 34; treeInsert(arbol, &intA, "rima");
	intA = 24; treeInsert(arbol, &intA, "buscabullas");
	intA = 11; treeInsert(arbol, &intA, "musica");
	intA = 31; treeInsert(arbol, &intA, "Pikachu");
	intA = 11; treeInsert(arbol, &intA, "Bulbasaur");
	intA = -2; treeInsert(arbol, &intA, "Charmander");

	tree_t* arbol_2 = treeNew(TypeInt, TypeString, 1);

	intA = -2; treeInsert(arbol_2, &intA, "Charmander");
	intA = 11; treeInsert(arbol_2, &intA, "Bulbasaur");
	intA = 31; treeInsert(arbol_2, &intA, "Pikachu");
	intA = 11; treeInsert(arbol_2, &intA, "musica");
	intA = 24; treeInsert(arbol_2, &intA, "buscabullas");
	intA = 34; treeInsert(arbol_2, &intA, "rima");
	intA = 24; treeInsert(arbol_2, &intA, "papanatas");

	treePrint(arbol, pfile);
	treePrint(arbol_2, pfile);

	treeDelete(arbol);
	treeDelete(arbol_2);
    
}

void test_document(FILE *pfile){

	int32_t dataInt1 = 83;
	int32_t dataInt2 = 125;
	float dataFloat1 = 12.5f;
	float dataFloat2 = 1.3f;
    document_t* doc = docNew(6, TypeInt, &dataInt1, TypeInt, &dataInt2, TypeFloat, &dataFloat1, TypeFloat, &dataFloat2, TypeString, "Hola", TypeString, "Chau");
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


