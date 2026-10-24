#!/usr/bin/env python3
"""Prove di ce-ps5: carica ELF veri (fisso, PIE con rilocazione), un ospite con syscall FreeBSD, e file malformati."""
import os, subprocess, sys
RADICE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
ok = ko = 0
def esito(nome, bene, extra=""):
    global ok, ko
    if bene: ok += 1; print("ok      ", nome)
    else: ko += 1; print("FALLITO ", nome, extra)
def lancia(*a, **k):
    return subprocess.run(list(a), cwd=RADICE, capture_output=True, text=True, **k)
r = lancia("./ce", "compila", "src/principale.ce", "-o", "ceps5")
esito("compilazione", r.returncode == 0, r.stderr[:400])
if r.returncode: sys.exit(1)
r = lancia("./ceps5", "esegui", "prog/fisso.elf"); esito("ELF statico (ET_EXEC a 0x400000)", r.returncode == 42, str(r.returncode))
r = lancia("./ceps5", "esegui", "prog/pie.elf"); esito("PIE con rilocazione RELATIVE", r.returncode == 7, str(r.returncode))
r = lancia("./ceps5", "ospite", "prog/bsd.elf")
esito("ospite: syscall FreeBSD intercettate (write, getpid, ENOSYS, exit)", r.stdout == "Ciao dal guest FreeBSD-style!\n" and r.returncode == 5, repr(r.stdout) + str(r.returncode))
open("/tmp/ce_ps5_prova.txt", "w").write("HELLOworld")
r = lancia("./ceps5", "ospite", "prog/kernel.elf")
esito("ospite: mmap, TLS (FS), file, orologio, errori CF/ENOENT", r.stdout == "ATHELLOCE\n" and r.returncode == 0, repr(r.stdout) + str(r.returncode))
r = lancia("./ceps5", "ospite", "prog/thread.elf")
esito("ospite: thread con stack e TLS propri + _umtx_op", r.stdout == "Tfiglio\npadre\n" and r.returncode == 0, repr(r.stdout) + str(r.returncode))
ripetuti = all(lancia("./ceps5", "ospite", "prog/thread.elf").stdout == "Tfiglio\npadre\n" for _ in range(20))
esito("thread: 20 esecuzioni di fila identiche (nessuna gara)", ripetuti)
r = lancia("./ceps5", "info", "prog/pie.elf"); esito("info", "segmenti 6" in r.stdout, r.stdout[:100])
open("/tmp/ce_ps5_x.bin", "wb").write(b"garbage")
r = lancia("./ceps5", "esegui", "/tmp/ce_ps5_x.bin"); esito("file non ELF: errore pulito", r.returncode == 2 and "ELF" in r.stdout)
dati = bytearray(open(os.path.join(RADICE, "prog", "pie.elf"), "rb").read())
dati[32:40] = (10 ** 12).to_bytes(8, "little")   # tabella dei segmenti fuori dal file
open("/tmp/ce_ps5_y.bin", "wb").write(dati)
r = lancia("./ceps5", "esegui", "/tmp/ce_ps5_y.bin"); esito("ELF corrotto: errore pulito, nessun crash", r.returncode == 2, str(r.returncode))
print(f"\n{ok} riusciti, {ko} falliti"); sys.exit(1 if ko else 0)
