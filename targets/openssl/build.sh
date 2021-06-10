#!/bin/bash
set -e

##
# Pre-requirements:
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env CC, CXX, FLAGS, LIBS, etc...
##

if [ ! -d "$TARGET/repo" ]; then
    echo "fetch.sh must be executed first."
    exit 1
fi

# build the libpng library
cd "$TARGET/repo"

#CONFIGURE_FLAGS=""
#if [[ $CFLAGS = *sanitize=memory* ]]; then
  CONFIGURE_FLAGS="no-asm"
#fi

# the config script supports env var LDLIBS instead of LIBS
export LDLIBS="$LIBS"

./config --debug enable-fuzz-libfuzzer enable-fuzz-afl disable-tests -DPEDANTIC \
    -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION no-shared no-module \
    enable-tls1_3 enable-rc5 enable-md2 enable-ec_nistp_64_gcc_128 enable-ssl3 \
    enable-ssl3-method enable-nextprotoneg enable-weak-ssl-ciphers \
    $CFLAGS -fno-sanitize=alignment $CONFIGURE_FLAGS

replacedCFLAG=$(grep -w "CFLAGS=" repo/Makefile | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')
replacedCXXFLAG=$(grep -w "CXXFLAGS=" repo/Makefile | awk '{for (i=1;i<=NF;i++) if (!a[$i]++) printf("%s%s",$i,FS)}{printf("\n")}')
sed -i '/CFLAGS=-include/c\'"$replacedCFLAG"'' Makefile
sed -i '/CXXFLAGS=-include/c\'"$replacedCXXFLAG"'' Makefile

make -j$(nproc) clean
make -j$(nproc) LDCMD="$CXX $CXXFLAGS"

fuzzers=$(find fuzz -executable -type f '!' -name \*.py '!' -name \*-test '!' -name \*.pl)
for f in $fuzzers; do
    fuzzer=$(basename $f)
    cp $f "$OUT/"
done
