# Project: cmd_friend
# Author: João Peterson Scheffer
# Date of creation: 10.08.2020
# 
# Usage:
# - Compile and build as debug:                      			  	- "make" or "make build"
# - Clear then compile and build as debug:                      	- "make rebuild"
# - Compile and build as release:                    			  	- "make release"
# - Clear dependencie, compressed, object and executable files:   	- "make clear"
# - Compress and pack binaries and specified files:  			  	- "make pack"

# Main program
MAIN_EXE = main
VERSION = v1.2

# Compiler definitions :
CC = gcc
CFLAGS = -std=c11 $(HEADERS_PATH)
LFLAGS = -L$(LIB_PATH) $(LIBS)

# Directories :
HEADERS_PATH =
LIB_PATH = ./
MODULES_PATH = modules
RELEASE_DIR = releases/

# Libraries :
LIBS =
#LIBS += modules/cmd_friend/lib/libcmdf.a

# Tools :
TAR_UTILITY = tar
TAR_ARG = -c -v -z -f
TAR_NAME = $(RELEASE_DIR)$(MAIN_EXE)_Win_x86_64_$(VERSION).tar.gz
PACK_FILES = $(MAIN_EXE).exe


# END OF USER AREA --------------------------------------------------------------------------------------------

CC_AS =

# Recursive wildcard definition :
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) \
  $(filter $(subst *,%,$2),$d))


# Source files to find :
SOURCE_FILES += $(call rwildcard,./$(MODULES_PATH)/,*.c) # list the source files recursively in ./$(MODULES_PATH)
SOURCE_FILES += $(wildcard *.c) # list source files in main dir
OBJECT_FILES := $(SOURCE_FILES:.c=.o) # make object files list to compile later 
DEPENDENCE_FILES := $(OBJECT_FILES:.o=.d) # make dependencie files for each source file, necessary to track modification to header files includeded in each source 
DEP_FLAGS = -MMD -MF $(@:.o=.d) # Arguments to generate dependency files when compiling



# Rules -------------------------------------------------------------------------------------------------------


# Default
all: build

# Rebuild
rebuild: clear build

# Pack releaze file using $(TAR_UTILITY)
pack: clear release
	@echo Packing...
	mkdir releases/
	$(TAR_UTILITY) $(TAR_ARG) $(TAR_NAME) $(PACK_FILES)
	@echo Done packing.

# Compile as release, overloading $(MAIN_EXE) rule with -Ofast
release: CC_AS += -Ofast 
release: $(MAIN_EXE).exe

# Compile as debug (default), overloading $(MAIN_EXE) rule with -g
build: CC_AS += -g 
build: $(MAIN_EXE).exe

# Compile .exe
$(MAIN_EXE).exe : $(OBJECT_FILES) 
	@echo Building...
	$(CC) $^ $(LFLAGS) -o $@
	@echo Done Building.

# Clear dependencie, object and executable files
clear : 
	@echo Cleaning...
	rm -f $(SOURCE_FILES:.c=.o)
	rm -f $(SOURCE_FILES:.c=.d)
	rm -f $(MAIN_EXE).exe
	@echo Done cleaning.

# Clear dependencie, compressed, documentation, object and executable files
clearall : $(SOURCE_FILES)
	@echo Cleaning...
	rm -f $(SOURCE_FILES:.c=.o)
	rm -f $(SOURCE_FILES:.c=.d)
	rm -f $(TAR_NAME)
	rm -f -r doc/html
	rm -f $(MAIN_EXE).exe
	@echo Done cleaning.

# General rule for compiling source files found in $(OBJECT_FILES), derived from $(SOURCE_FILES) in %(MODULES_PATH)
%.o : %.c
	@echo Compiling... $<
	$(CC) $(CC_AS) $(CFLAGS) -c $< $(DEP_FLAGS) -o $@ 
-include $(DEPENDENCE_FILES)