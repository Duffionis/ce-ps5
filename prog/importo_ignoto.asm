global _start
extern simbolo_che_non_esiste
section .text
_start:
  sub rsp,8
  call [rel simbolo_che_non_esiste wrt ..got]
  ret
