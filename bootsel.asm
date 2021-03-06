;------------------------------
; BootSel - Boot Seletor para Master Boot Record
; Versao 1 - Dorival AC - Outono/2003
; Versao 2 - Dorival AC - Outono/2013
; Assembly Intel x86 / amd64
;------------------------------
; Versao 2.0
;------------------------------
; Inserir este boot em 0
; Original no disco vai em: B3F

codigo SEGMENT
       ASSUME CS:codigo,DS:codigo

     ORG  100h
inicio:

     jmp  inicCodigo
     db   'BootS2.0'

     dw    512  ; bytes por setor 
     db    1    ; Setor por cluster
     dw    1    ; Reservado        
     db    002h,0E0h,00h,40h,0Bh,0F0h,09h,000h,12h,00h,02h,00h,34h,00h,9Bh,14h  
     db    000h,000h,00h,00h,00h,000h,29h,0E6h,14h,54h,3Ah,4Eh,20h,20h,20h,20h    
     db    020h,020h,20h,20h,20h,020h,46h,041h,54h,31h,32h,20h,20h,20h                         

dados:
endBoot dd 00007C00h
int8    LABEL dword
int8a   dw 0
int8b   dw 0
        db	'https://github.com/dorivalac/BootSel'

inicCodigo:
     ;; Configurando Stack
     xor  ax,ax
     mov  ss,ax
     mov  sp,7B00h
     mov  es,ax
     mov  ds,ax

     mov  si,7c00h
     mov  di,7000h
     mov  cx,200h
     cld
     repz movsb
     nop

     push cs
     mov  ax,707Bh  ; *** VARIAVEL *** Pulo para novoSeg
     push ax
     retf

;; Processamento Pesado
novoSeg:

     mov  si,offset (alo  + 7C00h - 100h)
exibindo:
     mov  ah,0Eh
     mov  bh,0
     mov  bl,7
     mov  al,cs:[si]
     int  10h
     inc  si
     cmp  al,0
     jnz  exibindo
     ; chegou ao fim da exibicao do alo

pontinhos:
; Setar pontinhos

     ;; Guardar original do int8 (0:20h)
     xor  ax,ax
     mov  es,ax
     mov  ax,es:[20h]
     mov  bx,es:[22h]
     mov  [int8a + 7000h - 100h],ax
     mov  [int8b + 7000h - 100h],bx 

     ;es = 0
     mov  si,offset (PontinhosBios + 7000h - 100h)
     push cs
     pop  ax
     ;; Novo valor para int8 (bios:20h)
     cli
     mov  es:[20h], si
     mov  es:[22h], ax
     sti
lerTecla:
     ; es=0

     ; Leitura da versao 1.0, tipo abandonado
     ;xor  ax,ax
     ;int  16h
     ;cmp  al,0Dh
     ;jz   bootHd
     ;cmp  al,20h
     ;jz   bootCd
     ;jmp  lerTecla

     in    al,60h
     cmp   al, 39h  ; scan=39h asc=20h = barra espaco
     jz    bootCD
     cmp   al, 1Ch  ; scan=1Ch asc=0Dh = ENTER
     jz    bootHD

     cmp   cs:[final + 7000h - 100h],40
     jnz   naoFimEspera
     ;; Acabou o tempo e o usuario nao presisonou nada
     jmp   bootHD

naoFimEspera:
     jmp   lerTecla
     
bootHd:
     ; voltar valor original para int8
     cli
     mov ax,cs:[int8a + 7000h - 100h]
     mov bx,cs:[int8b + 7000h - 100h]
     mov es:[20h],ax
     mov es:[22h],bx
     sti

     mov  cx,0001h
     mov  dx,0080h
     jz   lerBoot

bootCd:
     ; voltar valor original para int8
     cli
     mov ax,cs:[int8a + 7000h - 100h]
     mov bx,cs:[int8b + 7000h - 100h]
     mov es:[20h],ax
     mov es:[22h],bx
     sti

     mov  cx,4f12h
     mov  dx,0100h
     jz   lerBoot

lerBoot:
     mov  ax, 0201h
     mov  bx, 7c00h
     int  13h

     push cs
     mov  ax, 7c00h
     push ax
     retf

PontinhosBIOS:
     push ax
     push bx
     push cx
     push dx
     push es
     push ds
     push ss
     push sp
     pushf

     inc  cs:[flage + 7000h - 100h]
     cmp  cs:[flage + 7000h - 100h], 6
     jnz  naoExibe
     mov  cs:[flage + 7000h - 100h], 0
     inc  cs:[final + 7000h - 100h]

     mov  ax,0E2Eh
     mov  bx,0007
     int  10h

naoExibe:
     popf
     pop  sp
     pop  ss 
     pop  ds
     pop  es
     pop  dx
     pop  cx
     pop  bx
     pop  ax
     jmp  [int8 + 7000h - 100h]
    

;Textos
alo   
      db 'BootSelect',13,10
      db 'Pressione BARRA DE ESPA�O para entrar no CD',13,10
      db 0
      db 274 dup(0)
      db 55h,0AAh

; flag de exibicao, sera exibindo pontinha a cada 3 ticks
flage db 0
final db 0

codigo ENDS
END inicio
