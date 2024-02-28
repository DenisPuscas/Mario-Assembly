.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 720
area_height EQU 504
area DD 0

counter DD 400 ; numara evenimentele de tip timer
score DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

mario_width equ 24
mario_height equ 32

inamic_width equ 32
inamic_height equ 32

latura equ 36

symbol_width EQU 10
symbol_height EQU 20

pozitie_x dd 0
pozitie_y dd 0

pozitie_steag_x dd 702
pozitie_steag_y dd 108

pozitie_steag_2_x dd 576
pozitie_steag_2_y dd 252

pozitie_cover_steag_2_x dd 576
pozitie_cover_steag_2_y dd 252

pozitie_inamic_x dd 0
pozitie_inamic_y dd 0
sens_miscare dd 0
stop_inamic dd 0

pozitie_bloc_x dd 252
pozitie_bloc_y dd 288

bani dd 0
stare_bani dd 0
pozitie_bani_x dd 0
pozitie_bani_y dd 0
fara_bani dd '3'

sfarsit_joc dd 0
castigare_joc dd 0

fall dd 0
jump dd 0
index_salt dd 0

traiectorie dd 0
oprire_salt dd 0

x_teren dd 0
y_teren dd 0
lungime_teren equ 48
inaltime_teren equ 14
index_cadru dd 0

faza dd 0
index_miscare dd 0

include digits.inc
include letters.inc
include blocks.inc
include blocks2.inc
include mario.inc
include inamici.inc
include teren.inc
include litereFinal.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '10'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_albastru
	
	cmp byte ptr [esi], 2
	je simbol_pixel_2
	
	cmp byte ptr [esi], 3
	je simbol_pixel_3

	cmp byte ptr [esi], 4
	je simbol_pixel_4
	
	cmp byte ptr [esi], 5
	je simbol_pixel_5

	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_albastru:
	mov dword ptr [edi], 08d8ff5h
	jmp simbol_pixel_next
simbol_pixel_2:
	mov dword ptr [edi], 0000000h
	jmp simbol_pixel_next
simbol_pixel_3:
	mov dword ptr [edi], 0ffff00h
	jmp simbol_pixel_next
simbol_pixel_4:
	mov dword ptr [edi], 0f8d81eh
	jmp simbol_pixel_next
simbol_pixel_5:
	mov dword ptr [edi], 0d89e36h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_final proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax, '0'
	lea esi, litereFinal
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_negru

	mov dword ptr [edi], 0FFFFFFh
	jmp simbol_pixel_next
simbol_pixel_negru:
	mov dword ptr [edi], 0

simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text_final endp

make_block_teren proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jge block_2
	sub eax, '0'
	lea esi, blocks
	jmp draw_text
	
block_2:
	sub eax, 'A'
	lea esi, blocks2

draw_text:
	mov ebx, latura
	mul ebx
	mov ebx, latura
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, latura
bucla_simbol_linii:
	mov edi, area ; pointer la matricea de pixeli
	mov eax, y_teren
	add eax, latura
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, x_teren
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latura
bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_block_teren endp

make_block proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax, '0'
	lea esi, blocks
draw_text:
	mov ebx, latura
	mul ebx
	mov ebx, latura
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, latura
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, latura
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latura
bucla_simbol_coloane:
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_block endp

make_flag proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, 9
	lea esi, blocks2
draw_text:
	mov ebx, latura
	mul ebx
	mov ebx, latura
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, latura
bucla_simbol_linii:
	mov edi, area ; pointer la matricea de pixeli
	mov eax, pozitie_steag_y ; pointer la coord y
	add eax, latura
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, pozitie_steag_x ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latura
bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_flag endp

make_flag_2 proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, 10
	lea esi, blocks2
draw_text:
	mov ebx, latura
	mul ebx
	mov ebx, latura
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, latura
bucla_simbol_linii:
	mov edi, area ; pointer la matricea de pixeli
	mov eax, pozitie_steag_2_y ; pointer la coord y
	add eax, latura
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, pozitie_steag_2_x ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latura
bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_flag_2 endp

make_cover_flag_2 proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, 3
	lea esi, blocks2
draw_text:
	mov ebx, latura
	mul ebx
	mov ebx, latura
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, latura
bucla_simbol_linii:
	mov edi, area ; pointer la matricea de pixeli
	mov eax, pozitie_cover_steag_2_y ; pointer la coord y
	add eax, latura
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, pozitie_cover_steag_2_x ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, latura
bucla_simbol_coloane:
	cmp dword ptr [esi], 08d8ff5h
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next

simbol_pixel_next:
	add esi, 4
	
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_cover_flag_2 endp

make_mario proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax, '0'
	lea esi, mario
draw_text:
	mov ebx, mario_width
	mul ebx
	mov ebx, mario_height
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, mario_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, mario_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, mario_width
bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_mario endp

make_inamici proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	sub eax, '0'
	lea esi, inamici
draw_text:
	mov ebx, inamic_width
	mul ebx
	mov ebx, inamic_height
	mul ebx
	mov ebx, 4
	mul ebx
	add esi, eax
	mov ecx, inamic_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, inamic_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, inamic_width
bucla_simbol_coloane:
	cmp dword ptr [esi], 0
	je simbol_pixel_next
	mov eax, dword ptr [esi]
	mov dword ptr [edi], eax
	jmp simbol_pixel_next
simbol_pixel_next:
	add esi, 4
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_inamici endp



;un macro ca sa apelam mai usor desenarea simbolului
make_inamici_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_inamici
	add esp, 16
endm

make_mario_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_mario
	add esp, 16
endm

make_block_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_block
	add esp, 16
endm

make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text_final_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text_final
	add esp, 16
endm

make_teren proc
	push ebp
	mov ebp, esp
	pusha
	
	mov x_teren, 0
	mov y_teren, 0
	
	mov eax, 0
	lea esi, teren

draw_text:
	mov ebx, lungime_teren
	mul ebx
	mov ebx, inaltime_teren
	mul ebx
	add esi, eax
	add esi, index_cadru
	mov ecx, inaltime_teren
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, y_teren ; pointer la coord y
	add eax, inaltime_teren
	sub eax, ecx
	mov ebx, lungime_teren
	mul ebx
	add eax, x_teren ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, 20
bucla_simbol_coloane:
	cmp word ptr [esi], 1
	je block1
	cmp word ptr [esi], 2
	je block2
	cmp word ptr [esi], 3
	je block3
	cmp word ptr [esi], 4
	je block4
	cmp word ptr [esi], 6
	je block6
	cmp word ptr [esi], 7
	je block7
	cmp word ptr [esi], 8
	je block8
	cmp word ptr [esi], 9
	je block9
	cmp word ptr [esi], 10
	je block10
	cmp word ptr [esi], 11
	je block11
	cmp word ptr [esi], 12
	je block12
	cmp word ptr [esi], 13
	je block13
	cmp word ptr [esi], 14
	je block14
	cmp word ptr [esi], 15
	je block15
	cmp word ptr [esi], 16
	je block16
	cmp word ptr [esi], 17
	je block17
	cmp word ptr [esi], 18
	je block18
	cmp word ptr [esi], 19
	je block19
	cmp word ptr [esi], 20
	je block20
	
	push '0'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block1:
	push '1'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block2:
	push '2'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block3:
	push '3'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block4:
	push '4'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block6:
	push '6'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block7:
	push '7'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block8:
	push '8'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block9:
	push '9'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block10:
	push 'A'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block11:
	push 'B'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block12:
	push 'C'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block13:
	push 'D'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block14:
	push 'E'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block15:
	push 'F'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block16:
	push 'G'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block17:
	push 'H'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block18:
	push 'I'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block19:
	push 'J'
	call make_block_teren
	add esp, 4
	jmp simbol_pixel_next
block20:
	push 'K'
	call make_block_teren
	add esp, 4
simbol_pixel_next:
	add esi, 2
	inc edi
	add x_teren, 36
	dec ecx
	cmp ecx, 0
	jg bucla_simbol_coloane

	pop ecx
	mov x_teren, 0
	add y_teren, 36
	add esi, 56
	
	dec ecx
	cmp ecx, 0
	jg bucla_simbol_linii
	
	cmp pozitie_bloc_x, 0
	jle fara_bloc
	sub pozitie_bloc_x, 36
	make_block_macro fara_bani, area, pozitie_bloc_x, pozitie_bloc_y
	jmp continuare
fara_bloc:
	mov pozitie_bloc_x, 0
	mov pozitie_bloc_y, 0
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
make_teren endp

proc_dreapta proc
	push ebp
	mov ebp, esp
	pusha

;cadere---------------------------	
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade
	
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade
	jmp oprire
;----------------------------cadere	
nu_cade:
;blocare---------------------------
	mov eax, pozitie_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;blocare---------------------------

continuare:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	add pozitie_x, 4
	make_mario_macro '3', area, pozitie_x, pozitie_y
	
oprire:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_dreapta endp

proc_stanga proc
	push ebp
	mov ebp, esp
	pusha
	
;cadere---------------------------
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	sub eax, 8
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade
	
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade
	jmp oprire
;----------------------------cadere	
nu_cade:
;oprire----------------------------
	mov eax, pozitie_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	dec eax
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	dec eax
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;-----------------------------oprire

	cmp pozitie_x, 0
	je oprire

continuare:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_x, 4
	make_mario_macro '3', area, pozitie_x, pozitie_y
	
oprire:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_stanga endp

proc_jos proc
	push ebp
	mov ebp, esp
	pusha
	
	make_mario_macro '0', area, pozitie_x, pozitie_y
	add pozitie_y, 4
	make_mario_macro '2', area, pozitie_x, pozitie_y
	
	popa
	mov esp, ebp
	pop ebp
	ret
proc_jos endp

proc_sus proc
	push ebp
	mov ebp, esp
	pusha
	
	mov ecx, 3
bucla:
;oprire----------------------------
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	cmp pozitie_y, 70
	jle oprire
;----------------------------oprire
	
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	make_mario_macro '2', area, pozitie_x, pozitie_y

	dec ecx
	cmp ecx, 0
	jg bucla
	
	cmp index_salt, 8
	jl continuare
	
oprire:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	make_mario_macro '1', area, pozitie_x, pozitie_y
	mov jump, 0
	mov index_salt, 0
	
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_sus endp

testare_blocare_salt proc
	push ebp
	mov ebp, esp
	pusha

;sus---------------------------
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	cmp pozitie_y, 70
	jle oprire
;-----------------------------sus
;dreapta-------------------------
	mov eax, pozitie_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, mario_width
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, mario_width
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;------------------------------dreapta
;stanga-------------------------------	
	mov eax, pozitie_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	dec eax
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	dec eax
	shl eax, 2
	add eax, area
	mov esi, eax
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;-----------------------------stanga
	
	cmp pozitie_x, 0
	je oprire
	
	jmp continuare
oprire:
	mov oprire_salt, 1
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
testare_blocare_salt endp

proc_sus_stanga proc
	push ebp
	mov ebp, esp
	pusha
	
	
;oprire----------------------------
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;----------------------------oprire
	cmp traiectorie, 1
	je t1
	cmp traiectorie, 2
	je t2
	cmp traiectorie, 3
	je t3
	cmp traiectorie, 4
	je t4
	cmp traiectorie, 5
	je t5
	cmp traiectorie, 6
	je t6
	cmp traiectorie, 7
	je t7
	cmp traiectorie, 8
	je t8
	cmp traiectorie, 9
	je t9
	cmp traiectorie, 10
	je t10
	cmp traiectorie, 11
	je t11
	cmp traiectorie, 12
	je t12
	cmp traiectorie, 13
	je t13
	cmp traiectorie, 14
	je t14
	cmp traiectorie, 15
	je t15
	
	;ts0
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	
t1:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t2:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 2
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t3:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 2
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t4:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare

t5:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t6:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t7:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t8:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t9:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t10:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t11:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t12:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t13:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t14:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare

t15:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	mov traiectorie, 0

	
oprire:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	make_mario_macro '1', area, pozitie_x, pozitie_y
	mov traiectorie, 0
	mov oprire_salt, 0
	mov jump, 0
	mov index_salt, 0
	
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_sus_stanga endp

proc_sus_dreapta proc
	push ebp
	mov ebp, esp
	pusha
	
;oprire----------------------------
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
	
	mov eax, pozitie_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire
;----------------------------oprire
	cmp traiectorie, 1
	je t1
	cmp traiectorie, 2
	je t2
	cmp traiectorie, 3
	je t3
	cmp traiectorie, 4
	je t4
	cmp traiectorie, 5
	je t5
	cmp traiectorie, 6
	je t6
	cmp traiectorie, 7
	je t7
	cmp traiectorie, 8
	je t8
	cmp traiectorie, 9
	je t9
	cmp traiectorie, 10
	je t10
	cmp traiectorie, 11
	je t11
	cmp traiectorie, 12
	je t12
	cmp traiectorie, 13
	je t13
	cmp traiectorie, 14
	je t14
	cmp traiectorie, 15
	je t15
	
	;ts0
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	
t1:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t2:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 2
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t3:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 2
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t4:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare

t5:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t6:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t7:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t8:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t9:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t10:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t11:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t12:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t13:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare
	
t14:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	inc traiectorie
	jmp continuare

t15:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	sub pozitie_y, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	add pozitie_x, 4
	call testare_blocare_salt
	cmp oprire_salt, 1
	je oprire
	make_mario_macro '2', area, pozitie_x, pozitie_y
	mov traiectorie, 0

	
oprire:
	make_mario_macro '0', area, pozitie_x, pozitie_y
	make_mario_macro '1', area, pozitie_x, pozitie_y
	mov traiectorie, 0
	mov oprire_salt, 0
	mov jump, 0
	mov index_salt, 0
	
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_sus_dreapta endp


;inamici-------------------------
proc_miscare_inamic proc
	push ebp
	mov ebp, esp
	pusha

	cmp sens_miscare, 0
	je miscare_stanga

;miscare-dreapta--------------------
	mov eax, pozitie_inamic_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	add eax, 33
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire_dreapta
	
	mov eax, pozitie_inamic_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	add eax, 33
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire_dreapta

	make_inamici_macro '0', area, pozitie_inamic_x, pozitie_inamic_y
	add pozitie_inamic_x, 4
	make_inamici_macro '1', area, pozitie_inamic_x, pozitie_inamic_y
;---------------------------------miscare-dreapta
	jmp oprire
;----------------------------------
miscare_stanga:
	mov eax, pozitie_inamic_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	sub eax, 2
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire_stanga
	
	mov eax, pozitie_inamic_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	sub eax, 2
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne oprire_stanga

	cmp pozitie_inamic_x, 0
	je oprire_stanga
	
	make_inamici_macro '0', area, pozitie_inamic_x, pozitie_inamic_y
	sub pozitie_inamic_x, 4
	make_inamici_macro '1', area, pozitie_inamic_x, pozitie_inamic_y
;------------------------------------------------------	
oprire_dreapta:
	mov sens_miscare, 0
	jmp oprire

oprire_stanga:
	mov sens_miscare, 1

oprire:
	popa
	mov esp, ebp
	pop ebp
	ret
proc_miscare_inamic endp


comparare_stop_inamic proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, pozitie_inamic_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	je c1
	mov stop_inamic, 1
c1:
	mov eax, pozitie_inamic_y
	sub eax, 4
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	add eax, 31
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	je c2
	mov stop_inamic, 1
c2:	
	popa
	mov esp, ebp
	pop ebp
	ret
comparare_stop_inamic endp

testare_atingere_inamic proc
	push ebp
	mov ebp, esp
	pusha

	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 26
	shl eax, 2
	add eax, area
	mov esi, eax
	
	mov ecx, 31
bucla:
	mov eax, pozitie_inamic_y
	add eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, pozitie_inamic_x
	sub eax, 2
	shl eax, 2
	add eax, area
	cmp eax, esi
	jne continuare
	mov sfarsit_joc, 1
continuare:
	loop bucla

	popa
	mov esp, ebp
	pop ebp
	ret
testare_atingere_inamic endp
;------------------------inamici

testare_atingere_bloc proc
	push ebp
	mov ebp, esp
	pusha

	mov ecx, 3
	mov edx, 0
bucla:
	push edx
	mov eax, pozitie_bloc_y
	add eax, 38
	mov ebx, area_width
	mul ebx
	add eax, pozitie_bloc_x
	pop edx
	add eax, edx
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne atins
	
	add edx, 17
	loop bucla
	jmp continuare
atins:
	cmp fara_bani, '5'
	je nu_mai_sunt
	inc bani
	add score, 200
nu_mai_sunt:
	cmp stare_bani, 0
	jne continuare
	add stare_bani, 1
continuare:
	popa
	mov esp, ebp
	pop ebp
	ret
testare_atingere_bloc endp

animatie_bani proc
	push ebp
	mov ebp, esp
	pusha
	
	cmp stare_bani, 1
	jne fara_atribuire
	cmp fara_bani, '5'
	je continuare2
	
	mov eax, pozitie_bloc_x
	add eax, 13
	mov pozitie_bani_x, eax
	mov eax, pozitie_bloc_y
	sub eax, 21
	mov pozitie_bani_y, eax
	
fara_atribuire:
	cmp stare_bani, 6
	je continuare2
	cmp stare_bani, 5
	je terminare_animatie
	cmp stare_bani, 1
	jne miscare_bani
	
	make_text_macro 'Z', area, pozitie_bani_x, pozitie_bani_y
	jmp continuare
	
miscare_bani:
	make_text_macro ' ', area, pozitie_bani_x, pozitie_bani_y
	sub pozitie_bani_y, 8
	make_text_macro 'Z', area, pozitie_bani_x, pozitie_bani_y
	jmp continuare
	
terminare_animatie:
	make_text_macro ' ', area, pozitie_bani_x, pozitie_bani_y
	mov stare_bani, 0
	jmp continuare2
	
continuare:
	inc stare_bani
continuare2:
	popa
	mov esp, ebp
	pop ebp
	ret
animatie_bani endp

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	cmp castigare_joc, 1
	je joc_castigat
	
	cmp sfarsit_joc, 1
	je joc_terminat
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer 
	cmp eax, 3
	jz evt_keyboard 
	; nu s-a efectuat click pe nimic
;initializare-------------------
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
;--------------------initializare
	
	call make_teren
	make_block_macro '3', area, pozitie_bloc_x, pozitie_bloc_y
	
	
	make_mario_macro '1', area, 100, 384
	mov pozitie_x, 100
	mov pozitie_y, 384

	make_inamici_macro '1', area, 504, 400
	mov pozitie_inamic_x, 504
	mov pozitie_inamic_y, 400
	
	jmp afisare_litere
	
evt_click:

	jmp afisare_litere
	
evt_keyboard:
	cmp faza, 0
	jne evt_timer
	
	mov eax, [ebp+arg2]
	cmp eax, 'Z'
	jne cont1
	mov sfarsit_joc, 1
	cont1:
	cmp eax, 'D'
	je miscare_dreapta
	cmp eax, 'A'
	je miscare_stanga
	cmp eax, 'W'
	jne c1
	cmp jump, 0
	je miscare_sus
c1:
	cmp eax, 'Q'
	jne c2
	cmp jump, 0
	je miscare_sus_stanga
c2:
	cmp eax, 'E'
	jne afisare_litere
	cmp jump, 0
	je miscare_sus_dreapta
	jmp afisare_litere

miscare_dreapta:
	cmp pozitie_x, 336
	jge deplasare_cadru
doar_miscare:
	call proc_dreapta
	jmp afisare_litere
	
deplasare_cadru:
	cmp index_cadru, 54
	jg doar_miscare
	
	mov ecx, latura
bucla_cadru:
	mov eax, pozitie_y
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	add eax, ecx
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne doar_miscare
	
	mov eax, pozitie_y
	add eax, 31
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 24
	add eax, ecx
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne doar_miscare
	
	loop bucla_cadru

	add index_cadru, 2
	call make_teren
	
;inamic------------------------
	cmp pozitie_inamic_x, 36
	jg cont2
	mov stop_inamic, 4
cont2:
	sub pozitie_inamic_x, 36
	sub pozitie_x, 18
	cmp stop_inamic, 4
	je fara_inamic
	make_inamici_macro '1', area, pozitie_inamic_x, pozitie_inamic_y
fara_inamic:
;--------------------------inamic
;steag---------------------------
	cmp index_cadru, 41
	jl fara_steag
	sub pozitie_steag_x, 36
	call make_flag
	
fara_steag:
;---------------------------steag

	make_mario_macro '3', area, pozitie_x, pozitie_y
	jmp afisare_litere
	
miscare_stanga:
	call proc_stanga
	jmp afisare_litere
	
miscare_sus:
	cmp fall, 1
	je afisare_litere
;oprire-in-aer-----------		
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade2
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade2
	jmp afisare_litere
nu_cade2:
;--------------------oprire-in-aer
	mov jump, 1
	jmp afisare_litere
	
miscare_sus_stanga:
	cmp fall, 1
	je afisare_litere
;oprire-in-aer-----------	
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade3
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade3
	jmp afisare_litere
nu_cade3:
;--------------------oprire-in-aer	
	mov jump, 2
	jmp afisare_litere
	
miscare_sus_dreapta:
	cmp fall, 1
	je afisare_litere
;oprire-in-aer-----------	
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade4
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne nu_cade4
	jmp afisare_litere
nu_cade4:
;--------------------oprire-in-aer	
	mov jump, 3
	jmp afisare_litere

;timer----------------------------------------------------------------------------------------------------------------------------------------
evt_timer:

;terminare-joc--------------------
	mov eax, pozitie_steag_x
	add eax, 4
	cmp pozitie_x, eax
	jl neterminat
	mov castigare_joc, 1
	jmp joc_castigat
neterminat:
;------------------------terminare-joc

;testare-sfarsit-joc-----------------
	cmp pozitie_y, 470 
	jl cadere_in_gol 
	mov sfarsit_joc, 1
cadere_in_gol:
	
	call testare_atingere_inamic
	cmp sfarsit_joc, 0
	je continuare_joc
;---------------------testare-sfarsit-joc

;joc-pierdut------------------------------------
joc_terminat:
	mov edx, 320
	mov ecx, 8
bucla_text_final:
	make_text_final_macro '0', area, edx, 220
	make_text_final_macro '0', area, edx, 280
	add edx, 10
	loop bucla_text_final

	make_text_final_macro '0', area, 320, 240
	make_text_final_macro '0', area, 330, 240
	make_text_final_macro '1', area, 340, 240 ;G
	make_text_final_macro '2', area, 350, 240 ;A
	make_text_final_macro '3', area, 360, 240 ;M
	make_text_final_macro '4', area, 370, 240 ;E
	make_text_final_macro '0', area, 380, 240
	make_text_final_macro '0', area, 390, 240
	make_text_final_macro '0', area, 320, 260
	make_text_final_macro '0', area, 330, 260
	make_text_final_macro '5', area, 340, 260 ;O
	make_text_final_macro '6', area, 350, 260 ;V
	make_text_final_macro '4', area, 360, 260 ;E
	make_text_final_macro '7', area, 370, 260 ;R
	make_text_final_macro '0', area, 380, 260
	make_text_final_macro '0', area, 390, 260
	jmp final_draw
;-------------------------------------------joc-pierdut
	
continuare_joc:

;block-bani---------------------------------------------
	call testare_atingere_bloc
	cmp stare_bani, 0
	je continuare_stare_bani
	call animatie_bani
	
continuare_stare_bani:
	cmp fara_bani, '3'
	jne continuare_fara_bani
	cmp bani, 3
	jne continuare_fara_bani
	mov fara_bani, '5'
	make_block_macro fara_bani, area, pozitie_bloc_x, pozitie_bloc_y
continuare_fara_bani:
;---------------------------------------------------block-bani
	
;inamici---------------------
	cmp stop_inamic, 0
	jne continuare_inamic
	call comparare_stop_inamic
continuare_inamic:
	cmp stop_inamic, 4
	je sfarsit_inamic
	cmp stop_inamic, 3
	je inamic_mort
	cmp stop_inamic, 2
	je intarziere_inamic
	cmp stop_inamic, 1
	je oprire_miscare_inamic
	call proc_miscare_inamic
	jmp sfarsit_inamic
oprire_miscare_inamic:
	make_inamici_macro '0', area, pozitie_inamic_x, pozitie_inamic_y
	make_inamici_macro '2', area, pozitie_inamic_x, pozitie_inamic_y
	mov stop_inamic, 2
	jmp sfarsit_inamic
intarziere_inamic:
	mov stop_inamic, 3
	jmp sfarsit_inamic
inamic_mort:
	make_inamici_macro '0', area, pozitie_inamic_x, pozitie_inamic_y
	mov pozitie_inamic_x, 0
	mov pozitie_inamic_y, 0
	mov stop_inamic, 4
	add score, 100
sfarsit_inamic:
;----------------------------inamici
	
	cmp jump, 1
	je salt
	cmp jump, 2
	je salt_stanga
	cmp jump, 3
	je salt_dreapta
	
	
;cadere---------------------------
	mov ecx, 3
bucla_cadere:
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne eticheta
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 23
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne eticheta
cadere:
	mov fall, 1
	call proc_jos
	dec ecx
	cmp ecx, 0
	jg bucla_cadere
	jmp salt
;----------------------------cadere
eticheta:
	mov fall, 0
	make_mario_macro '0', area, pozitie_x, pozitie_y
	make_mario_macro '1', area, pozitie_x, pozitie_y
	jmp static
salt:
;saritura--------------------------
	cmp fall, 1
	je static
	inc index_salt
	call proc_sus
	jmp static
;-----------------------------saritura	
salt_stanga:
	cmp fall, 1
	je static
	inc index_salt
	call proc_sus_stanga
	jmp static

salt_dreapta:
	cmp fall, 1
	je static
	inc index_salt
	call proc_sus_dreapta
	jmp static

static:
	dec counter
	cmp counter, 1
	jge mai_este_timp
	mov sfarsit_joc, 1
mai_este_timp:
	
afisare_litere:
;timer---------------------------------------
	make_text_macro 'T', area, 640, 20 ;T
	make_text_macro 'I', area, 650, 20 ;I
	make_text_macro 'M', area, 660, 20 ;M
	make_text_macro 'E', area, 670, 20 ;E

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 670, 40
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 660, 40
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 650, 40
;--------------------------------------timer
	
	
	make_text_macro 'M', area, 40, 20 ;M
	make_text_macro 'A', area, 50, 20 ;A
	make_text_macro 'R', area, 60, 20 ;R
	make_text_macro 'I', area, 70, 20 ;I
	make_text_macro 'O', area, 80, 20 ;O

;scor------------------------------------
	make_text_macro '0', area, 40, 40
	mov ebx, 10
	mov eax, score
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 40
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 70, 40
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 60, 40
	;cifra miilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 50, 40
;----------------------------------scor
	
;coins------------------------------------
	make_text_macro 'C', area, 247, 20 ;C
	make_text_macro 'O', area, 257, 20 ;O
	make_text_macro 'I', area, 267, 20 ;I
	make_text_macro 'N', area, 277, 20 ;N
	make_text_macro 'S', area, 287, 20 ;S
	
	make_text_macro 'Z', area, 250, 39
	make_text_macro 'X', area, 266, 40
	mov eax, bani
	add eax, '0'
	make_text_macro eax, area, 280, 40
;coins-------------------------------------	
	
;world-------------------------------------
	make_text_macro 'W', area, 460, 20 ;W
	make_text_macro 'O', area, 470, 20 ;O
	make_text_macro 'R', area, 480, 20 ;R
	make_text_macro 'L', area, 490, 20 ;L
	make_text_macro 'D', area, 500, 20 ;D
	
	make_text_macro '1', area, 465, 40 ;1
	make_text_macro 'Y', area, 480, 40 ;-
	make_text_macro '1', area, 495, 40 ;1
;--------------------------------------world
	jmp final_draw
	
joc_castigat:
	cmp faza, 1
	je faza_1
	cmp faza, 2
	je faza_2
	cmp faza, 3
	je faza_3
	cmp faza, 4
	je faza_4
	cmp faza, 5
	je faza_5


	make_mario_macro '0', area, pozitie_x, pozitie_y
	add pozitie_x, 4
	make_mario_macro '4', area, pozitie_x, pozitie_y
	inc faza
	
faza_1:
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	add eax, 12
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne e_jos
	
	call make_teren
	call make_flag
	add pozitie_y, 4
	make_mario_macro '4', area, pozitie_x, pozitie_y
	jmp afisare_litere
e_jos:
	inc faza
	call make_teren
	call make_flag
	add pozitie_x, 24
	make_mario_macro '5', area, pozitie_x, pozitie_y
	
faza_2:
	mov eax, pozitie_steag_y
	add eax, 40
	mov ebx, area_width
	mul ebx
	add eax, pozitie_steag_x
	add eax, 18
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	jne e_jos2
	
	call make_teren
	add pozitie_steag_y, 12
	call make_flag
	make_mario_macro '5', area, pozitie_x, pozitie_y
	jmp afisare_litere
	
e_jos2:
	inc faza
	
faza_3:
	mov eax, pozitie_y
	add eax, 32
	mov ebx, area_width
	mul ebx
	add eax, pozitie_x
	shl eax, 2
	add eax, area
	cmp dword ptr[eax], 08d8ff5h
	je cadere_final

	cmp pozitie_x, 580
	jl nu_e_in_castel
	call make_teren
	call make_flag
	mov faza, 4
	mov ebx, 10
	mov eax, counter
	mov edx, 0
	div ebx
	sub counter, edx
	jmp afisare_litere
nu_e_in_castel:
	
	cmp index_miscare, 0
	je miscare2
	
	dec index_miscare
	call make_teren
	call make_flag
	add pozitie_x, 4
	make_mario_macro '1', area, pozitie_x, pozitie_y
	jmp afisare_litere
	
miscare2:
	inc index_miscare
	call make_teren
	call make_flag
	add pozitie_x, 4
	make_mario_macro '3', area, pozitie_x, pozitie_y
	jmp afisare_litere

cadere_final:
	call make_teren
	call make_flag
	add pozitie_y, 4
	add pozitie_x, 4
	make_mario_macro '2', area, pozitie_x, pozitie_y
	jmp afisare_litere
	
faza_4:		
	cmp counter, 0
	je counter_0
	sub counter, 10
	add score, 50
	jmp afisare_litere
counter_0:
	inc faza
	jmp afisare_litere
	
faza_5:
	cmp pozitie_steag_2_y, 216
	jle final_draw
	
	sub pozitie_steag_2_y, 4
	
	call make_teren
	call make_flag
	call make_flag_2
	call make_cover_flag_2
	jmp afisare_litere
	

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
