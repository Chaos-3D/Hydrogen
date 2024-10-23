CROSS_PREFIX=or1k-linux-musl-
dirs-y += src/generic src/ar100 lib/ar100

CFLAGS		+= -O3
CFLAGS		+= -fno-builtin
CFLAGS		+= -fno-pie
CFLAGS		+= -ffreestanding
CFLAGS		+= -msfimm -mshftimm -msoft-div -msoft-mul
CFLAGS		+= -Ilib/ar100
CFLAGS_hydrogen.elf := $(CFLAGS) -T src/ar100/ar100.ld
CFLAGS_hydrogen.elf += -Wl,--gc-sections -static
CFLAGS_hydrogen.elf += -Wl,--no-dynamic-linker

SFLAGS		 = -nostdinc -MMD
SFLAGS		+= -Ilib/ar100

# Add source files
src-y += ar100/main.c ar100/gpio.c ar100/serial.c
src-y += ar100/util.c ar100/timer.c
src-y += generic/crc16_ccitt.c generic/timer_irq.c

OBJS_hydrogen.elf += $(OUT)lib/ar100/start.o
OBJS_hydrogen.elf += $(OUT)lib/ar100/runtime.o

# Build the AR100 binary
target-y += $(OUT)ar100.bin

$(OUT)lib/ar100/start.o:
	@echo "  Compiling $@"
	$(Q)$(CC) $(SFLAGS) -c $(PWD)/lib/ar100/start.S -o $@

$(OUT)lib/ar100/runtime.o:
	@echo "  Compiling $@"
	$(Q)$(CC) $(SFLAGS) -c $(PWD)/lib/ar100/runtime.S -o $@

$(OUT)ar100.bin: $(OUT)hydrogen.elf
	@echo "  Object copy $@"
	$(OBJCOPY) -O binary -S --reverse-bytes 4 $(OUT)hydrogen.elf $@
	truncate -s %8 $@
