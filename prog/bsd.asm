; programma "ospite" con la convenzione delle syscall FreeBSD (come PS4/PS5)
global _start
section .text
_start:
  mov eax,4            ; write
  mov edi,1
  lea rsi,[rel msg]
  mov edx,msglen
  syscall
  mov eax,20           ; getpid
  syscall
  mov eax,999          ; sconosciuta
  syscall
  mov eax,1            ; exit
  mov edi,5
  syscall
msg db 'Ciao dal guest FreeBSD-style!',10
msglen equ $-msg
