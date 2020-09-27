extern getCompareFunction
extern getCloneFunction
extern getDeleteFunction
extern intClone
extern fprintf
extern malloc
extern free 
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

section .data
	uno: dd 1 
	menosUno: dd -1
	null: db 'NULL', 0
	formatoString: db '%s',0

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
	; si stackframe, no toco la pila, espero funcione
	movss xmm0, [rdi] 	; segun el manual, los bits [127-32] se llenan de 0's
	comiss xmm0, [rsi]	; comparo los floats
	
	je .sonIguales
	ja .esMayor
	jb .esMenor
	
	.sonIguales: 	
		mov eax, 0
		jmp .fin 

	.esMayor:
		mov eax, -1
		jmp .fin 
	
	.esMenor:
		mov eax, 1		; o es add rax, -1
	
	.fin:
	ret
				; float* floatClone(float* a);
floatClone:		; rax <- float*    (rdi <- *a)
	push rbp		; pila alieada
	mov rbp, rsp
	push rdi		; guardo rdi en la pila | pila desalineada
	sub rsp, 8		; pila alineada

	mov rdi, 4
	call malloc 	; pido  bytes para el float

	; recupero el puntero a float
	add rsp,8 		
	pop rdi			; rdi <- float *a
	mov esi, [rdi]	; obtengo el dato float apuntado
	mov [rax], esi	; lo copio en memoria
	pop rbp
ret
					; void floatDelete(float* a)
floatDelete:		;				  rdi <- *a
	push rbp
	mov rbp, rsp
	call free
	pop rbp
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
	
	inc eax			; tengo que agregar un '0' al final
	mov edi, eax
	call malloc		; rax <- char* clonString
	mov rdi, 0

	.recorrido:
		mov r8b, [rbx+rdi]
		mov [rax+rdi], r8b
		inc rdi
		cmp r8b, 0
		jne .recorrido
	
	.fin:
	add rsp, 8
	pop rbx
	pop rbp
ret
			; uint32_t strLen(char* a)
strLen:		; eax <- uint32_t rdi <- *a
	push rbp
	mov rbp, rsp
	mov eax, 0
	.recorrido:
		cmp byte [rdi+rax], 0
		je .fin
		inc eax
		jmp .recorrido
	.fin:
	pop rbp
ret
			; int32_t strCmp(char* a, char* b)
strCmp:		; eax <- int32_t rdi <- *a, rsi <- *b
	mov ecx, 0
	.recorrido:
		mov r8b, [rdi+rcx]
		mov r9b, [rsi+rcx]
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
	push rbp
	mov rbp, rsp
	call free
	pop rbp
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
	mov rdi, sizeDocument
	call malloc 		; rax <- *nuevoDocument
	 
	mov r12, rax		; r12 <- *nuevoDocument
	mov r13d, [rbx+offDocCount]		; r8 <- a->count
	mov [r12+offDocCount], r13 	; nuevoDocument->count = r8
	mov qword [r12+offDocValues], NULL	; nuevoDocument->values = NULL
	; comparo que *a tenga docElems
	cmp r13, 0
	je .fin
	; pido memoria para el arreglo values
	mov eax, sizeDocElem
	mul r13d
	mov rdi, rax 				; rdi <- 16*cantidad de elementos)		
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
		dec r13
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
	; ya no quedan datos, solo los elementos y el documento en si
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
				;				 rdi <- *l 	rsi <- *data
listAdd:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	mov rbx, rdi
	mov r12, rsi
	mov r13d, [rbx+offListType]
	mov rdi, r13
	call getCompareFunction
	mov r13, rax	; r13 <- funcCompare
	
	mov rdi, sizeListElem
	call malloc
	mov r14, rax

	cmp dword [rbx+offListSize], 0
	je .vacia
	mov r15, [rbx+offListFirst]
	.ciclo:
		mov rdi, r12
		mov rsi, [r15+offListElemData]
		call r13
		cmp eax, 1
		jl .sigo 
		
		mov [r14+offListElemNext], r15
		mov r8, [r15+offListElemPrev]
		mov [r14+offListElemPrev], r8
		mov [r15+offListElemPrev], r14
		cmp r8, NULL
		je .esPrimero
		mov [r8+offListElemNext], r14
		jmp .termine
	
	.sigo:
		mov r15, [r15+offListElemNext]
		cmp r15, NULL
		je .esUltimo
		jmp .ciclo

	.vacia:
		mov [rbx+offListFirst], r14
		mov [rbx+offListLast], r14
		mov qword [r14+offListElemNext], NULL
		mov qword [r14+offListElemPrev], NULL
		jmp .termine

	.esPrimero:
		mov [rbx+offListFirst], r14
		jmp .termine
	
	.esUltimo:
		mov r15, [rbx+offListLast]
		mov [r15+offListElemNext], r14
		mov [r14+offListElemPrev], r15
		mov qword [r14+offListElemNext], NULL
		mov [rbx+offListLast], r14

	.termine:
		mov [r14+offListElemData], r12
		inc dword [rbx+offListSize]	

	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
ret

;*** Tree ***

treeInsert:
ret
treePrint:
ret

