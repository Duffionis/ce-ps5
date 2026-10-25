; guest che importa funzioni dell'ospite per nome (come un programma PS5 importa libkernel): ce_scrivi, ce_numero, ce_uscita
global _start
extern ce_scrivi, ce_numero, ce_uscita
section .text
_start:
  sub rsp,8
  lea rdi,[rel msg]
  mov esi,msglen
  call [rel ce_scrivi wrt ..got]
  mov edi,12345
  call [rel ce_numero wrt ..got]
  mov rax,[fs:0]              ; il TLS del guest e' intatto dopo le chiamate all'ospite?
  mov edi,3
  call [rel ce_uscita wrt ..got]
section .rodata
msg db 'importi risolti per nome',10
msglen equ $-msg
