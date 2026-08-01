TARGET  = calculator
SOURCE  = src/calculator.s
BUILD   = build
GENSRC  = $(BUILD)/calculator.gen.s

CC      = gcc
CROSS   = aarch64-linux-gnu-gcc
RUNNER  = qemu-aarch64-static
CFLAGS  = -static
LDLIBS  = -lm

.PHONY: all native cross run clean

all: native

# On an aarch64 machine the system compiler is the right one.
native: $(GENSRC)
	$(CC) $(CFLAGS) $(GENSRC) -o $(TARGET) $(LDLIBS)

# From an x86 host: cross-assemble, then run it under qemu.
cross: $(GENSRC)
	$(CROSS) $(CFLAGS) $(GENSRC) -o $(TARGET) $(LDLIBS)

run: $(TARGET)
	@if [ "$$(uname -m)" = "aarch64" ]; then ./$(TARGET); else $(RUNNER) ./$(TARGET); fi

$(GENSRC): $(SOURCE) | $(BUILD)
	m4 $(SOURCE) > $(GENSRC)

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(TARGET) $(BUILD)
