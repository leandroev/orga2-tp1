extern getCompareFunction
extern getCloneFunction
extern getDeleteFunction
extern getPrintFunction
extern listPrint
extern intClone
extern fprintf
extern malloc
extern free 
extern listNew

%define NULL 0
;	/** Document **/
%define offDocCount 0
%define offDocValues 8
%define sizeDocument 16
%define offDocElemType 0
%define offDocElemData 8
%define sizeDocElem	16
;	/** List **/
%define offListType 0
%define offListSize 4
%define offListFirst 8
%define offListLast 16
%define offListElemData 0
%define offListElemNext 8
%define offListElemPrev 16
%define sizeListElem 24
;   /** Tree **/
%define offTreeFirst 0
%define offTreeSize 8
%define offTreeTypeKey 12
%define offTreeDup 16
%define offTreeTypeData 20
%define offTreeNodeKey 0
%define offTreeNodeValue 8
%define offTreeNodeLeft 16
%define offTreeNodeRight 24
%define sizeTreeNode 32
section .data
	uno: dd 1 
	menosUno: dd -1
	null: db 'NULL', 0
	formatoString: db '%s', 0
	abre: db '(', 0
	cierra:db ')->' , 0

section .text

global floatCmp
global floatClone
global floatDelete

global strClone
global strLen
global strCmp
global strDelete
global strPrint

global docClone
global docDelete

global listAdd

global treeInsert
global treePrint

;*** Float ***
				; int32_t floatCmp(float* a, float* b);
floatCmp:		; eax <- int32_t  (rdi <- *a, rsi <- *b)
	; no toco la pila
	movss xmm0, [rdi] 	; segun el manual, los bits [127-32] se llenan de 0's
	comiss xmm0, [rsi]	; comparo los floats
	
	je .sonIguales
	ja .esMayor
	jb .esMenor
	
	.sonIguales: 		; a = b
		mov eax, 0
		jmp .fin 

	.esMayor:			; a > b
		mov eax, -1
		jmp .fin 
	
	.esMenor:			; a < b
		mov eax, 1		
	
	.fin:
	ret

				; float* floatClone(float* a);
floatClone:		; rax <- float*    (rdi <- *a)
	push rbp		; pila alieada
	mov rbp, rsp
	push rdi		; guardo *float en la pila | pila desalineada
	sub rsp, 8		; pila alineada

	mov rdi, 4
	call malloc 	; pido  4 bytes para el float

	; recupero el puntero a float
	add rsp,8 		
	pop rdi			; rdi <- float *a
	mov esi, [rdi]	; obtengo el dato float apuntado
	mov [rax], esi	; lo copio en memoria
	pop rbp
ret

					; void floatDelete(float* a)
floatDelete:		;				  rdi <- *a
	jmp free
ret

;*** String ***
				; char* strClone(char* a)
strClone:		; rax <- char*	rdi <- *a
	push rbp		; pila alineada
	mov rbp, rsp
	
	push rbx
	sub rsp, 8		; pila alineada
	
	mov rbx, rdi	; rbx <- *a
	call strLen 	; rax <- largo del String
	
	inc eax			; tengo que agregar un '0' al final del char*
	mov edi, eax
	call malloc		; rax <- char* clonString
	mov rdi, 0 		; index

	.recorrido:
		mov r8b, [rbx+rdi] 	; obtengo el char
		mov [rax+rdi], r8b 	; copio el char a memoria
		inc rdi 		
		cmp r8b, 0 			; si es 0 termine
		jne .recorrido
	
	.fin:
	add rsp, 8
	pop rbx
	pop rbp
ret

			; uint32_t strLen(char* a)
strLen:		; eax <- uint32_t rdi <- *a
	mov eax, 0
	.recorrido:
		cmp byte [rdi+rax], 0
		je .fin
		inc eax			; incremento length
		jmp .recorrido
	.fin:
ret

			; int32_t strCmp(char* a, char* b)
strCmp:		; eax <- int32_t rdi <- *a, rsi <- *b
	mov ecx, 0
	.recorrido:
		mov r8b, [rdi+rcx]	; r8 <- a[i]
		mov r9b, [rsi+rcx]	; r9 <- b[i]
		cmp r8b, r9b		; comparo caracteres
		jne .distintos		; si son distintos salto
		; hubo coincidencia de caracteres hasta este punto
		cmp r8b, 0			; chequeo si llegue al final de los string
		je .sonIguales
		; aun no termine de recorrer ningun string
		inc ecx
		jmp .recorrido

	.distintos:	; *los mov condicionales no toman operandos inmediatos*
		cmovb eax, [uno]	
		cmova eax, [menosUno]
		jmp .fin

	.sonIguales:
		mov eax, 0
	.fin:
ret

strDelete:
	jmp free
ret

				; void strPrint(char* a, FILE* pFile);
strPrint:		;				rdi <- *a,	rsi <- *pFile
	push rbp			; pila alineada
	mov rbp, rsp

	mov rdx, rdi 		; rdx <- *a
	mov rdi, rsi 		; rdi <- *pFile
	mov rsi, formatoString ; rsi <- *formatoString
	cmp byte [rdx], 0	; chequeo si es string ""
	jne .termina
    mov rdx, null		; rdx <- "NULL"
    
	.termina:

	call fprintf
	
	pop rbp
ret

;*** Document ***
				; document_t* docClone(document_t* a);
docClone:		; rax <- *document_t 	  rdi <- *a
	push rbp			; pila alineada
	mov rbp, rsp
	push rbx
	push r12 			; pila alineada
	push r13
	push r14 			; pila alineada

	mov rbx, rdi 		; rbx <- *a
	;creo un documento
	mov rdi, sizeDocument	; rdi <- sizeof(document_t)
	call malloc 			; rax <- *nuevoDocument
	 
	mov r12, rax			; r12 <- *nuevoDocument
	mov r13d, [rbx+offDocCount]	; r13 <- a->count
	mov [r12+offDocCount], r13d	; nuevoDocument->count = r13
	mov qword [r12+offDocValues], NULL	; nuevoDocument->values = NULL
	; chequeo que *a tenga docElems
	cmp r13, 0
	je .fin
	; pido memoria para el arreglo values
	mov eax, sizeDocElem 		; eax <- sizeof(docElem_T)
	mul r13d 					; eax <- eax * a->count
	mov rdi, rax 				; rdi <- (16*cantidad de elementos)		
	call malloc
	; copio los docElems
	mov r14, rax				; r14 <- nuevoDocument->values
	mov [r12+offDocValues], r14	; nuevoDocument->values = r14
	mov rbx, [rbx+offDocValues] ; rbx <- a->values
	.ciclo:
		mov edi, [rbx+offDocElemType]	; rdi <- type_t
		; obtengo la funcion clonar
		mov [r14+offDocElemType], edi 	; r14->type = rdi
		call getCloneFunction			; rax <- funcClone
		; clono el dato
		mov rdi, [rbx+offDocElemData] 	; rdi <- *dato a clonar
		call rax						; rax <- *datoClon
		mov [r14+offDocElemData], rax 	; r14->data = rax
		; avanzo en la estructura docElems
		add r14, sizeDocElem 			; avanzo al siguiente docElems
		add rbx, sizeDocElem
		dec r13 						; un docElem menos que copiar
		cmp r13, 0						; si r13 = 0 termine
		jne .ciclo

	.fin:
	; retorno el puntero al nuevoDocument
	mov rax, r12

	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

				; void docDelete(document_t* a);
docDelete:		; 					rdi <- *a
	push rbp		; pila alineada
	mov rbp, rsp

	cmp dword [rdi+offDocCount], 0	; me fijo si no hay nada docElems que borrar
	je .noBorrar

	push rbx
	push r12		; pila alineada
	push r13
	push r14		; pila alineada

	mov rbx, rdi 	; rbx <- *a
	mov r12, [rdi+offDocValues] ; r12 <- document->values
	mov r13d, [rdi+offDocCount]	; r13 <- document->count
	mov r14, 0					; r14 <- indexElem

	.recorrido:
		mov edi, [r12+r14+offDocElemType]
		call getDeleteFunction	; rax <- funcDelete*
		mov rdi, [r12+r14+offDocElemData]
		call rax				; llamo a funcDelete
		;ya borre el dato, continuo con los siguientes si los hay
		add r14, 16		; cada elemento es de 16bytes
		dec r13
		cmp r13, 0
		jne .recorrido

	; ya no quedan datos, solo el arreglo de elementos y el documento en si
	mov rdi, [rbx+offDocValues]
	call free	; free(values) libero memoria del arreglo
	mov rdi, rbx
	call free	; free(values) libero memoria del documento

	.popear:
	pop r14
	pop r13
	pop r12
	pop rbx
	.noBorrar:
	pop rbp
ret

;*** List ***
				; 	void listAdd(list_t* l, void* data);
listAdd:		;				 rdi <- *l, rsi <- *data
	push rbp				; pila alineada
	mov rbp, rsp
	push rbx
	push r12				; pila alineada
	push r13
	push r14 				; pila alineada
	push r15
	sub rsp, 8 				; pila alineada

	mov rbx, rdi 			; rbx <- *l
	mov r12, rsi 			; r12 <- *data
	mov r13d, [rbx+offListType] ; r13 <- l->type
	mov rdi, r13
	call getCompareFunction
	mov r13, rax				; r13 <- funcCompare
	
	mov rdi, sizeListElem 		; rdi <- sizeof(listElem_t)
	call malloc
	mov r14, rax 				; r14 <- *nuevoListElem

	cmp dword [rbx+offListSize], 0
	je .vacia 					; chequeo si hay elementos
	mov r15, [rbx+offListFirst] ; r15 <- l->first
	.ciclo:
		mov rdi, r12 			
		mov rsi, [r15+offListElemData]
		call r13 				; comparo el nuevoDato con los de la lista (cmp(a,b))
		cmp eax, 1 				
		jl .sigo  				; si obtengo a >= b sigo comparando
		; encontré donde ubicar el listElem
		mov [r14+offListElemNext], r15
		mov r8, [r15+offListElemPrev]
		mov [r14+offListElemPrev], r8
		mov [r15+offListElemPrev], r14
		cmp r8, NULL 			; chequeo si el dato es el nuevo l->first
		je .esPrimero
		mov [r8+offListElemNext], r14
		jmp .termine
	
	.sigo:
		; avanzo al siguiente de la lista
		mov r15, [r15+offListElemNext]
		cmp r15, NULL 	; chequeo si ya no quedan elementos
		je .esUltimo
		jmp .ciclo

	.vacia: 		; caso agregar primer elemento
		mov [rbx+offListFirst], r14
		mov [rbx+offListLast], r14
		mov qword [r14+offListElemNext], NULL
		mov qword [r14+offListElemPrev], NULL
		jmp .termine

	.esPrimero: 	; es primer elemento pero no el unico
		mov [rbx+offListFirst], r14
		jmp .termine
	
	.esUltimo:		; es el ultimo elemento de la lista
		mov r15, [rbx+offListLast]
		mov [r15+offListElemNext], r14
		mov [r14+offListElemPrev], r15
		mov qword [r14+offListElemNext], NULL
		mov [rbx+offListLast], r14

	.termine:
		mov [r14+offListElemData], r12 	; agrego el dato al listElem
		inc dword [rbx+offListSize]		; incremento el campo size de lista

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

;*** Tree ***
					; int treeInsert(tree* t,  void* key,  void* data)
treeInsert:			; eax<-result    rdi <- *t  rsi <- *key  rdx <- *data
	push rbp			; pila alineada
	mov rbp, rsp
	push rbx
	push r12			; pila alineada
	push r13
	push r14 			; pila alineada
	push r15
	sub rsp, 8 			; pila alineada

	mov rbx, rdi;		rbx <- *tree
	mov r12, rsi;		r12 <- *key
	mov r13, rdx;		r13 <- *data
	
	mov edi, [rbx+offTreeTypeKey]	; rdi <- tree->typeKey
	call getCompareFunction 	 	
	mov r15, rax					; r15 <- funcion Comparacion

	mov r14, [rbx + offTreeFirst]	; r14 <- *treeNode para recorrido
	cmp r14, NULL 					
	je .esRaiz 			; caso agregar raiz
	; caso ya existe raiz
	.ciclo:
		mov rdi, [r14+offTreeNodeKey]	; rdi <- treeNode->key
		mov rsi, r12 					; rsi <- *key
		call r15 			; comparo las keys (rdi,rsi)
		cmp eax, 0 
		jg .derecha 		; rdi < rsi
		jl .izquierda 		; rdi > rsi
		; caso rdi = rsi
		mov r8, [r14 + offTreeNodeValue]	; r8 <- treeNode->values
		cmp dword [r8 + offListSize], 1		; chequeo si la lista tiene elementos
		jne .insertar 		; caso lista vacia || caso lista acepta duplicados
		je .duplicados 		; chequeo si acepta o no duplicados

	.derecha:	; rama derecha
		mov r9, r14 		; r9 <- treeNode
		mov r14, [r14+ offTreeNodeRight] 
		cmp r14, NULL 		; chequeo si existe nodo derecho
		je .nuevaHojaDerecha
		jmp .ciclo
	
	.izquierda:	; rama izquierda
		mov r9, r14 		; r9 <- treeNode
		mov r14, [r14+ offTreeNodeLeft]
		cmp r14, NULL 		; chequeo si existe nodo izquierdo
		je .nuevaHojaIzquierda
		jmp .ciclo

	.nuevaHojaDerecha:
		mov r14, r9 		; r14 <- treeNode
		mov rdi, sizeTreeNode
		call malloc
		mov [r14+offTreeNodeRight], rax
		jmp .insertarClave

	.nuevaHojaIzquierda:
		mov r14, r9 		; r14 <- treeNode
		mov rdi, sizeTreeNode
		call malloc
		mov [r14+offTreeNodeLeft], rax
		jmp .insertarClave

	.insertarClave:
	; caso en el que no existe la clave
		mov r14, rax 				; r14 <- *nuevoTreeNode
		mov qword [r14 + offTreeNodeRight], NULL
		mov qword [r14 + offTreeNodeLeft], NULL
		
		mov edi, [rbx + offTreeTypeKey]	; rdi <- tree->typeKey
		call getCloneFunction  			; rax <- funcion clonar (tree->typeKey)
		mov rdi, r12 					; rdi <- *key
		call rax 
		mov [r14 + offTreeNodeKey], rax ; *nuevoTreeNode->key = rax
		
		mov edi, [rbx + offTreeTypeData]; rdi <- tree->typeData
		call listNew 					; creo lista de typeData
		mov [r14 + offTreeNodeValue], rax	; *nuevoTreeNode->values = rax
		mov r8, rax							; r8 <- treeNode->values
		jmp .insertar
		

	.insertar:
		mov r15, r8 			; r15 <- treeNode->values
		mov edi, [rbx+ offTreeTypeData] ; rdi <- tree->typeData
		call getCloneFunction 			; rax <- funcion clonar (tree->typeKey)
		mov rdi, r13  					; rdi <- *data
		call rax  						; call funcClone(*data)
		mov rdi, r15 					; rdi <- treeNode->values
		mov rsi, rax 					; rsi <- *clonData
		call listAdd 					; listAdd(clonData)
		inc dword [rbx + offTreeSize] 	; incremento size tree
		mov eax, 1 						; se inserto dato => eax = 1
		jmp .termina

	.esRaiz:
		mov rdi, sizeTreeNode 			; creo nuevo nodo raiz
		call malloc
		mov [rbx+offTreeFirst], rax 	; apunto al nodo como raiz del arbol
		jmp .insertarClave 				; agrego la clave

	.duplicados: 				
		cmp dword [rbx+offTreeDup], 0 	
		jne .insertar 		; caso acepta duplicados
		; caso no acepta duplicados
		mov eax, 0 			; no se inserto dato => eax = 1
		jmp .termina

	.termina:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

			;void treePrint(tree_t* tree, FILE* pfile)
treePrint:	; 				rdi <- *tree, rsi <- *pfile	
	push rbp		; pila alineada
	mov rbp, rsp
	push r12	 	
	push r13 		; pila alineada
	push r14 		
	sub rsp, 8 		; pila alineada
	
	mov r12, rdi 		; r12 <- *tree
	mov r14, rsi 		; r14 <- *pFile	
	mov edi, [r12+offTreeTypeKey]
	call getPrintFunction
	mov r13, rax 		; r13 <- printFuncKey

	mov rdi, [r12+offTreeFirst] ; rdi <- tree->first
	call treePrintAux
	
	add rsp, 8
	pop r14
 	pop r13
	pop r12
	pop rbp
ret


treePrintAux:
; r14 <- *pFile	 r13 <- printFuncKey rdi <- *treeNode 
	push rbp 		; pila alineada
	mov rbp, rsp
	push r15
	sub rsp, 8 		; pila alineada

	mov r15, rdi	; *treeNode
	cmp r15, NULL
	je .termina 	; si no hay nodo termina

	mov rdi, [r15+offTreeNodeLeft]	; rdi <- nodoIzquierdo
	call treePrintAux 				; llamada recursiva

	mov rdi, r14 	; rdi <- *pFile
	mov rsi, abre 	
	call fprintf	; print "("

	mov rsi, r14 	; rsi <- *pFile
	mov rdi, [r15+offTreeNodeKey] 	; rdi <- treeNode->key
	call r13 		; llamo a printFuncKey

	mov rdi, r14 	; rdi <- *pFile
	mov rsi, cierra 
	call fprintf 	; print ")->"

	mov rdi, [r15+offTreeNodeValue]	; rdi <- treeNode->values
	mov rsi, r14 	; rsi <- *pFile
	call listPrint 	; print lista

	mov rdi, [r15+offTreeNodeRight]	; rdi <- nodoDerecho
	mov rsi, r14 	; rsi <- *pFile
	call treePrintAux				; llamada recursiva

.termina:
	add rsp, 8
	pop r15
	pop rbp
ret