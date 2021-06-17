#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env BUG: bug patch name to be directed towards
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##

export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export AS="$FUZZER/repo/afl-as"

export LIBS="$LIBS -l:afl_driver.o -lstdc++"

"$MAGMA/build.sh"


# Setup directory containing all temporary files for AFLgo
export TMP_DIR=$OUT/temp
mkdir -p $TMP_DIR

# Set targets
# Download commit-analysis tool
wget -P $TMP_DIR/ https://raw.githubusercontent.com/jay/showlinenum/develop/showlinenum.awk
chmod +x $TMP_DIR/showlinenum.awk

# Generate BBtargets $BUG.patch
cat $TARGET/patches/bugs/$BUG.patch |  $TMP_DIR/showlinenum.awk show_header=0 path=1 | grep --color=never -e "\.[ch]:[0-9]*:+" -e "\.cpp:[0-9]*:+" -e "\.cc:[0-9]*:+" | cut -d+ -f1 | rev | cut -c2- | rev > $TMP_DIR/BBtargets.txt

# Set aflgo-instrumentation flags
export COPY_CFLAGS=$CFLAGS
export COPY_CXXFLAGS=$CXXFLAGS
export ADDITIONAL="-targets=$TMP_DIR/BBtargets.txt -outdir=$TMP_DIR -flto -fuse-ld=gold -Wl,-plugin-opt=save-temps"
export CFLAGS="$CFLAGS $ADDITIONAL"
export CXXFLAGS="$CXXFLAGS $ADDITIONAL"
export RANLIB="/usr/bin/llvm-ranlib"

# Build target in order to generate CG and CFGs
"$TARGET/build.sh"

# Test whether CG/CFG extraction was successful
echo "Dot-file number: $(ls $TMP_DIR/dot-files | wc | awk '{print $1}')" 
echo "Function targets"
cat $TMP_DIR/Ftargets.txt
if [[ ! -s $TMP_DIR/Ftargets.txt ]]; then
	echo "Empty Ftargets.txt"
	echo "Aborting..."
	exit 1
fi

# Clean up
cat $TMP_DIR/BBnames.txt | rev | cut -d: -f2- | rev | sort | uniq > $TMP_DIR/BBnames2.txt && mv $TMP_DIR/BBnames2.txt $TMP_DIR/BBnames.txt
cat $TMP_DIR/BBcalls.txt | sort | uniq > $TMP_DIR/BBcalls2.txt && mv $TMP_DIR/BBcalls2.txt $TMP_DIR/BBcalls.txt

# Generate distance
if [[ $TARGET = *poppler* ]]; then
	build_dir="$TARGET/work/poppler"
else
	build_dir="$TARGET/repo"
fi
# $AFLGO/scripts/genDistance.sh is the original, but significantly slower, version
#$FUZZER/repo/scripts/genDistance.sh $build_dir $TMP_DIR $PROGRAM
$FUZZER/repo/scripts/gen_distance_fast.py $build_dir $TMP_DIR $PROGRAM

# Check distance file
echo "Distance values:"
head -n5 $TMP_DIR/distance.cfg.txt
echo "..."
tail -n5 $TMP_DIR/distance.cfg.txt


# Instrument subject
export CFLAGS="$COPY_CFLAGS -distance=$TMP_DIR/distance.cfg.txt"
export CXXFLAGS="$COPY_CXXFLAGS -distance=$TMP_DIR/distance.cfg.txt"

# Clean and build subject with distance instrumentation 
"$TARGET/build.sh"
