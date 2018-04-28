# AAS Example Makefile

# Tools and flags.
CROSS = arm-elf-
CC = $(CROSS)gcc
CCPP = $(CROSS)g++

CFLAGS = -mthumb-interwork -fomit-frame-pointer -mapcs-32 -mcpu=arm7tdmi -ffast-math -fno-exceptions -fno-rtti
# added "-ffixed-r14" and "-mlong-calls" below to work around compiler bugs

THUMB = -mthumb -O3 -ffixed-r14 -funroll-loops
#THUMB = -mthumb -O3 -ffixed-r14 -funroll-loops -mlong-calls
#THUMB = -mthumb -O3 -ffixed-r14 
ARM = -marm -Os -mlong-calls
DEFAULT = $(THUMB)

AS = $(CROSS)as
ASFLAGS = -mthumb-interwork

# LD = $(CROSS)ld  # this doesn't work
LD = $(CROSS)g++
MAP = map.out
LDFLAGS = -mthumb-interwork -nostartfiles -Tlnkscript  # this works too
# LDFLAGS = -mthumb-interwork -Xlinker -Map $(MAP) -nostartfiles -Tlnkscript

# Library and include paths.
LIBS = -LLibAAS -lAAS
INCLUDES = -ILibAAS -I../tonclib

# Name of output targets.
SHORTNAME = mattproj
NAME = $(SHORTNAME).tmp
TARGET = $(SHORTNAME).gba

# Files you want to go in IWRAM.
IWRAM =	

# Files you want to go in ROM (AAS_Data.o must go first)
# Pictures using BMP2o must be before main.o
SRC =	AAS_Data.o main.o palls.o affine.o sinlut.o divlut.o starbig.o ../tonclib/core.o ../tonclib/bg.o ../tonclib/keypad.o numbers.o grey.o bullets.o starscale1.o starrot1.o cursorp.o fragment.o collect.o sparkle.o sparkle2.o gameovertiles.o largenum.o bigtarg.o swooshd.o bigtime.o retrytext.o mattlogo.o blastarenaletters.o blastarenatitlescreen.o advancehalves.o presstaletters.o finalbars.o menuletters.o blankline.o BGbackg.o BGsprites.o texttiles.o hislide.o hiarrow.o hiscoretexts.o speedyglowbox.o appearbox.o blinkbar.o enteryourname.o warningbox.o cheatarrows.o yourranknos.o snakeblocks.o lcdskybackdrop.o spritelight.o secondfont.o velvet.o blastbonus.o messages.o detected.o disclaimer.o

# Graphics related raw input files (e.g. sprites, palettes).
GFX =

# Sound related o input files.
SOUND =


# Here follow the generic build rules.
all:  clean $(TARGET)

release:
	make clean all
#	rm -f *.o $(NAME) $(GFX) $(SOUND) $(SYMBOLS) $(MAP)

clean:
#	rm -f *.o $(TARGET) $(NAME) $(GFX) $(SOUND) $(SYMBOLS) $(MAP)

AAS_Data.o:
	conv2aas AAS_Data
	$(AS) $(ASFLAGS) -o $@ AAS_Data.s

crt0.o: crt0.S
	$(AS) -o $@ $<

%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

%.o: %.thumb.c
	$(CC) $(THUMB) $(INCLUDES) $(CFLAGS) -c $< -o $@

%.o: %.arm.c
	$(CC) $(ARM) $(INCLUDES) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(DEFAULT) $(INCLUDES) $(CFLAGS) -c $< -o $@

%.o: %.bmp
	bmp2o $<
	
%.o: %.thumb.cpp
	$(CCPP) $(THUMB) $(INCLUDES) $(CFLAGS) -c $< -o $@

%.o: %.arm.cpp
	$(CCPP) $(ARM) $(INCLUDES) $(CFLAGS) -c $< -o $@

main.o: main.cpp
	$(CCPP) $(DEFAULT) $(INCLUDES) $(CFLAGS) -E main.cpp -o mainprep.txt 
	$(CCPP) $(DEFAULT) $(INCLUDES) $(CFLAGS) -c main.cpp -o main.o 

%.o: %.cpp
	$(CCPP) $(DEFAULT) $(INCLUDES) $(CFLAGS) -c $< -o $@

%.text.iwram.o: %.o
	cp $< $@

$(NAME): crt0.o $(IWRAM) $(GFX) $(SOUND) $(SRC)
#	touch $(MAP)
	$(LD) $(LDFLAGS) -o $@ crt0.o $(SRC) $(IWRAM) $(GFX) $(SOUND) $(LIBS)
	$(CROSS)size $@

$(TARGET): $(NAME)
	$(CROSS)objcopy -v -O binary $< $@
	gbafix $@ -t"BlastArena"

