; guest "alla FreeBSD": memoria, TLS, file, orologio, errori. Scrive "ATHELLOCE\n" e esce con 0.
global _start
section .text
%macro sys 1
  mov eax,%1
  syscall
%endmacro
stampa1:                  ; rsi = carattere puntato, scrive 1 byte
  mov edi,1
  mov edx,1
  sys 4
  ret
_start:
  ; mmap(0, 4096, PROT_READ|WRITE, MAP_ANON|MAP_PRIVATE, -1, 0)
  xor edi,edi
  mov esi,4096
  mov edx,3
  mov r10d,0x1002
  mov r8,-1
  xor r9d,r9d
  sys 477
  jc fallito
  mov rbx,rax
  mov byte [rbx],'A'
  mov rsi,rbx
  call stampa1
  ; TLS: la base di FS punta a rbx+0x100 e li' c'e' il puntatore a se' stesso (come vuole il TLS di x86-64)
  lea rax,[rbx+0x100]
  mov [rbx+0x100],rax
  mov [rbx+0x200],rax
  mov edi,129
  lea rsi,[rbx+0x200]
  sys 165
  jc fallito
  mov rax,[fs:0]
  lea rcx,[rbx+0x100]
  mov byte [rbx+8],'T'
  cmp rax,rcx
  je tls_ok
  mov byte [rbx+8],'t'
tls_ok:
  lea rsi,[rbx+8]
  call stampa1
  ; open("/tmp/ce_ps5_prova.txt", O_RDONLY), read 5, write, close
  lea rdi,[rel nome]
  xor esi,esi
  xor edx,edx
  sys 5
  jc fallito
  mov r12,rax
  mov rdi,r12
  lea rsi,[rbx+16]
  mov edx,5
  sys 3
  mov edi,1
  lea rsi,[rbx+16]
  mov edx,5
  sys 4
  mov rdi,r12
  sys 6
  ; clock_gettime(CLOCK_REALTIME, [rbx+32]): tv_sec > 1.5e9
  xor edi,edi
  lea rsi,[rbx+32]
  sys 232
  mov rax,[rbx+32]
  mov byte [rbx+48],'C'
  mov rcx,1500000000
  cmp rax,rcx
  jg orologio_ok
  mov byte [rbx+48],'c'
orologio_ok:
  lea rsi,[rbx+48]
  call stampa1
  ; open di un file che non c'e': CF=1 e rax=2 (ENOENT)
  lea rdi,[rel inesistente]
  xor esi,esi
  xor edx,edx
  sys 5
  mov byte [rbx+56],'E'
  jnc errore_mancato
  cmp rax,2
  je errore_ok
errore_mancato:
  mov byte [rbx+56],'e'
errore_ok:
  lea rsi,[rbx+56]
  call stampa1
  mov byte [rbx+64],10
  lea rsi,[rbx+64]
  call stampa1
  xor edi,edi
  sys 1
fallito:
  mov edi,9
  sys 1
nome db '/tmp/ce_ps5_prova.txt',0
inesistente db '/nessun/file/qui',0
