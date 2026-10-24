global _start
section .text
_start:
  lea rax,[rel _start]
  mov rbx,[rel puntatore]   ; riempito dalla rilocazione
  cmp rax,rbx
  jne male
  mov eax,7
  ret
male:
  mov eax,1
  ret
section .data
puntatore dq _start
