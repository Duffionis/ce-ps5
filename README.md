# ce-ps5

Le fondamenta di un emulatore PS5/PS4 scritto in **Ce++** (https://github.com/Duffionis/Ce-): il codice del gioco gira
*nativamente* sul processore x86-64 (come fa shadPS4), e noi forniamo il "sistema operativo".

## Cosa c'e' (e funziona)
- `src/elf.ce`: parser e caricatore ELF64 x86-64, con controlli su ogni lettura (un file corrotto da' un errore, mai un crash):
  segmenti, mappatura, rilocazioni `RELATIVE`, permessi di pagina.
- `src/sistema.ce`: intercetta le `syscall` del programma ospite con *syscall user dispatch* di Linux (kernel >= 5.11) e le serve in Ce++,
  con la convenzione FreeBSD di PS4/PS5 (numero in rax; argomenti in rdi, rsi, rdx, r10, r8, r9). Per ora: `exit`, `write`, `getpid`, il resto da' ENOSYS.
- `prog/`: programmi di prova scritti in assembly (sorgente `.asm` e `.elf` pronto).

## Uso
    ./ce compila src/principale.ce -o ceps5
    ./ceps5 info prog/pie.elf       # struttura del file
    ./ceps5 esegui prog/pie.elf     # carica e salta all'entrata
    ./ceps5 ospite prog/bsd.elf     # idem, con le syscall FreeBSD servite da noi
    python3 tests/prova.py

## Cosa NON c'e' (ancora)
Formato SELF/PRX di Sony, moduli di sistema (libkernel ecc.), thread e TLS del guest, la GPU (traduzione dei comandi AMD e degli shader in Vulkan),
audio, input. E' una base, non un emulatore che esegue giochi.

## Legalita'
Solo programmi homebrew liberi o tuoi. Questo progetto non contiene ne' richiede chiavi, firmware o giochi commerciali.
