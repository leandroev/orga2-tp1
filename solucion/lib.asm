extern malloc
extern free 

section .data

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
floatClone:		; rax <- *float    (rdi <- *a)
	push rbp		; pila alieada
	mov rbp, rsp
	push rdi		; guardo rdi en la pila | pila desalineada
	sub rsp, 8		; pila alineada

	mov rdi, 4
	call malloc 	; pido  bytes para el float

	; recupero el puntero a float
	add rsp,8 		
	pop rdi			; rdi <- float *a
	mov rsi, [rdi]	; obtengo el dato float apuntado
	mov [rax], rsi	; lo copio en memoria
	pop rbp
ret

floatDelete:
	jmp free
ret

;*** String ***

strClone:
ret
strLen:
ret
strCmp:
ret
strDelete:
ret
strPrint:
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

