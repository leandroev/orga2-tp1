extern malloc
extern free 

section .data
	uno: dd 1 
	menosUno: dd -1
	null: db 'NULL', 0

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
		mov eax, 1
		jmp .fin 
	
	.esMenor:
		mov eax, -1		; o es add rax, -1
	
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
ret

strPrint:
	
	cmp byte [rdi], 0
	jne .termina
    mov rdi, [null]
    
	.termina:
	call fprintf(rsi, [rdi])
ret

;*** Document ***

docClone:
ret
docDelete:
ret

;*** List ***

listAdd:
ret

;*** Tree ***

treeInsert:
ret
treePrint:
ret

