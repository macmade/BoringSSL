#-------------------------------------------------------------------------------
# The MIT License (MIT)
# 
# Copyright (c) 2024 Jean-David Gadina - www.xs-labs.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Variables
#-------------------------------------------------------------------------------

DIR_SRC             := ./boringssl/
DIR_BUILD           := ./build/
DIR_BUILD_INTEL     := $(DIR_BUILD)x86-64/
DIR_BUILD_ARM       := $(DIR_BUILD)arm64/
DIR_LIB             := ./lib/macOS/
DIR_INC             := ./include/

FLAGS_C_INTEL       := -target x86_64-apple-macos10.11
FLAGS_C_ARM         := -target arm64-apple-macos11
FLAGS_STDLIB        := -stdlib=libc++
FLAGS_CMAKE_INTEL   := -DCMAKE_OSX_ARCHITECTURES="x86_64" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.11 -DCMAKE_C_FLAGS="$(FLAGS_C_INTEL)" -DCMAKE_CXX_FLAGS="$(FLAGS_C_INTEL) $(FLAGS_STDLIB)" -DCMAKE_CPP_FLAGS="$(FLAGS_C_INTEL) $(FLAGS_STDLIB)"
FLAGS_CMAKE_ARM     := -DCMAKE_OSX_ARCHITECTURES="arm64"  -DCMAKE_OSX_DEPLOYMENT_TARGET=11    -DCMAKE_C_FLAGS="$(FLAGS_C_ARM)"   -DCMAKE_CXX_FLAGS="$(FLAGS_C_ARM) $(FLAGS_STDLIB)"   -DCMAKE_CPP_FLAGS="$(FLAGS_C_ARM) $(FLAGS_STDLIB)"

#-------------------------------------------------------------------------------
# Targets
#-------------------------------------------------------------------------------

# Phony targets
.PHONY: clean update build all install

all: update build install

clean:
	@echo "    *** Cleaning all build files"
	@rm -rf $(DIR_BUILD_INTEL)*
	@rm -rf $(DIR_BUILD_ARM)*

update:
	@echo "    *** Updating boringssl"
	@cd $(DIR_SRC) && git checkout master > /dev/null 2>&1
	@cd $(DIR_SRC) && git pull > /dev/null 2>&1

build: 
	@echo "    *** Building boringssl"
	@cd $(DIR_BUILD_INTEL) && cmake $(FLAGS_CMAKE_INTEL) -DCMAKE_BUILD_TYPE=Release -DOPENSSL_NO_ASM=On ../../$(DIR_SRC)
	@cd $(DIR_BUILD_ARM)   && cmake $(FLAGS_CMAKE_ARM)   -DCMAKE_BUILD_TYPE=Release -DOPENSSL_NO_ASM=On ../../$(DIR_SRC)
	@cd $(DIR_BUILD_INTEL) && make CFLAGS="$(FLAGS_C_INTEL)" CXXFLAGS="$(FLAGS_C_INTEL) $(FLAGS_STDLIB)" CPPFLAGS="$(FLAGS_C_INTEL) $(FLAGS_STDLIB)" LDFLAGS="$(FLAGS_STDLIB)"
	@cd $(DIR_BUILD_ARM)   && make CFLAGS="$(FLAGS_C_ARM)"   CXXFLAGS="$(FLAGS_C_ARM) $(FLAGS_STDLIB)"   CPPFLAGS="$(FLAGS_C_ARM) $(FLAGS_STDLIB)"   LDFLAGS="$(FLAGS_STDLIB)"

install:
	@echo "    *** Installing boringssl (macOS)"
	@lipo -create -output $(DIR_LIB)libcrypto.a   $(DIR_BUILD_INTEL)crypto/libcrypto.a     $(DIR_BUILD_ARM)crypto/libcrypto.a
	@lipo -create -output $(DIR_LIB)libdecrepit.a $(DIR_BUILD_INTEL)decrepit/libdecrepit.a $(DIR_BUILD_ARM)decrepit/libdecrepit.a
	@lipo -create -output $(DIR_LIB)libssl.a      $(DIR_BUILD_INTEL)ssl/libssl.a           $(DIR_BUILD_ARM)ssl/libssl.a
	@rm -rf $(DIR_INC)*
	@cp -rf $(DIR_SRC)include/* $(DIR_INC)
