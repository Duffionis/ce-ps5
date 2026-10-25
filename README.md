# ce-ps5

Le fondamenta di un emulatore PS5/PS4 scritto in **Ce++** (https://github.com/Duffionis/Ce-): il codice del gioco gira
*nativamente* sul processore x86-64 (come fa shadPS4), e noi forniamo il "sistema operativo".

## Cosa c'e' (e funziona)
- `src/elf.ce`: parser e caricatore ELF64 x86-64, con controlli su ogni lettura (un file corrotto da' un errore, mai un crash):
  segmenti, mappatura, rilocazioni `RELATIVE`, permessi di pagina.
- `src/sistema.ce`: intercetta le `syscall` del programma ospite con *syscall user dispatch* di Linux (kernel >= 5.11) e le serve in Ce++,
  con la convenzione FreeBSD di PS4/PS5 (numero in rax; argomenti in rdi, rsi, rdx, r10, r8, r9). Per ora: `exit`, `read`, `write`, `open` (flag tradotti), `close`, `getpid`, `mmap` (flag tradotti), `munmap`, `mprotect`, `lseek`,
  `clock_gettime`, `nanosleep`, `sysarch` (base di FS = TLS del guest), il resto da' ENOSYS. Gli errori seguono la convenzione BSD (CF=1, rax=errno).
  Thread del guest: `thr_new` crea un thread vero con lo stack e il TLS scelti dal guest, `thr_exit`, `thr_self`, `_umtx_op` (WAIT/WAKE tradotti in futex di Linux), `sched_yield`.
  Ogni thread ha un blocco di controllo (nel registro GS) con il proprio selettore e le due basi di FS.
  Un piccolo stub in linguaggio macchina scambia il registro FS fra guest e ospite a ogni syscall, cosi' il TLS del guest non rovina quello di libc.
- `src/hle.ce` + il ponte in `sistema.ce`: il guest puo' *importare funzioni per nome* (rilocazioni GLOB_DAT/JUMP_SLOT/64): le risolviamo
  verso funzioni Ce++ nostre (per ora `ce_scrivi`, `ce_numero`, `ce_uscita`: un mini libkernel). Un "ponte" in linguaggio macchina cambia FS e il selettore
  prima di chiamare l'ospite e li rimette dopo. Questo e' il meccanismo con cui un programma PS5 chiamerebbe la libreria di sistema.
- `prog/`: programmi di prova scritti in assembly (sorgente `.asm` e `.elf` pronto).

## Uso
    ./ce compila src/principale.ce -o ceps5
    ./ceps5 info prog/pie.elf       # struttura del file
    ./ceps5 esegui prog/pie.elf     # carica e salta all'entrata
    ./ceps5 ospite prog/bsd.elf     # idem, con le syscall FreeBSD servite da noi
    python3 tests/prova.py

## Cosa NON c'e' (ancora)
Formato SELF/PRX di Sony, i nomi hash (NID) delle funzioni di Sony, un libkernel/libc vero, la GPU (traduzione dei comandi AMD e degli shader in Vulkan),
audio, input. E' una base, non un emulatore che esegue giochi.

## Legalita'
Solo programmi homebrew liberi o tuoi. Questo progetto non contiene ne' richiede chiavi, firmware o giochi commerciali.
