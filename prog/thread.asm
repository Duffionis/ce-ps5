; guest con un thread: il figlio ha stack e TLS propri, avvisa il padre con _umtx_op (WAKE), il padre dorme con _umtx_op (WAIT).
; Output atteso: "Tfiglio\npadre\n"
global _start
section .text
%macro sys 1
  mov eax,%1
  syscall
%endmacro
scrivi:                   ; rsi=testo, edx=lunghezza
  mov edi,1
  sys 4
  ret

figlio:                   ; rdi = argomento (puntatore al blocco comune)
  mov rbx,rdi
  mov rax,[fs:0]          ; il TLS del figlio deve puntare a se stesso
  lea rcx,[rbx+0x300]
  mov al,'T'
  cmp [fs:0],rcx
  je .ok
  mov al,'t'
.ok:
  mov [rbx+0x20],al
  lea rsi,[rbx+0x20]
  mov edx,1
  call scrivi
  lea rsi,[rel testo_figlio]
  mov edx,testo_figlio_len
  call scrivi
  mov dword [rbx+0x40],1      ; flag
  lea rdi,[rbx+0x40]
  mov esi,16                  ; UMTX_OP_WAKE_PRIVATE
  mov edx,1
  sys 454
  ret                         ; lo stub chiude il thread

_start:
  xor edi,edi
  mov esi,0x20000
  mov edx,3
  mov r10d,0x1002
  mov r8,-1
  xor r9d,r9d
  sys 477
  mov rbx,rax                 ; blocco: stack del figlio in alto, TLS a +0x300, flag a +0x40
  lea rax,[rbx+0x300]
  mov [rbx+0x300],rax         ; TLS che punta a se stesso
  mov qword [rbx+0x40],0
  ; struct thr_param
  lea rdi,[rbx+0x1F000]
  lea rax,[rel figlio]
  mov [rdi+0],rax             ; start_func
  mov [rdi+8],rbx             ; arg
  lea rax,[rbx+0x1000]
  mov [rdi+16],rax            ; stack_base
  mov qword [rdi+24],0x1E000  ; stack_size
  lea rax,[rbx+0x300]
  mov [rdi+32],rax            ; tls_base
  mov qword [rdi+40],0x100
  lea rax,[rbx+0x50]
  mov [rdi+48],rax            ; child_tid
  lea rax,[rbx+0x58]
  mov [rdi+56],rax            ; parent_tid
  mov esi,104
  sys 455
  jc fallito
attendi:
  cmp dword [rbx+0x40],0
  jne fatto
  lea rdi,[rbx+0x40]
  mov esi,15                  ; UMTX_OP_WAIT_UINT_PRIVATE
  xor edx,edx                 ; finche' vale 0
  sys 454
  jmp attendi
fatto:
  lea rsi,[rel testo_padre]
  mov edx,testo_padre_len
  call scrivi
  xor edi,edi
  sys 1
fallito:
  mov edi,9
  sys 1
testo_figlio db 'figlio',10
testo_figlio_len equ $-testo_figlio
testo_padre db 'padre',10
testo_padre_len equ $-testo_padre
