AS=wla-65816
LD=wlalink

all: demo.smc

link.list:
	echo "[objects]" > link.list
	echo "demo.o" >> link.list

demo.o: demo.asm init.asm header.asm
	$(AS) -o demo.o demo.asm

demo.smc: link.list demo.o
	$(LD) -v -r link.list demo.smc
