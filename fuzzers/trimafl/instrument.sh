#!/bin/bash
set -e

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env MAGMA: path to Magma support files
# - env OUT: path to directory where artifacts are stored
# - env CFLAGS and CXXFLAGS must be set to link against Magma instrumentation
##

export CC="$FUZZER/repo/afl-clang-fast"
export CXX="$FUZZER/repo/afl-clang-fast++"
export AS="$FUZZER/repo/afl-as"

export LIBS="$LIBS -l:afl_driver.o -lstdc++"

"$MAGMA/build.sh"
"$TARGET/build.sh"

# NOTE: We pass $OUT directly to the target build.sh script, since the artifact
#       itself is the fuzz target. In the case of Angora, we might need to
#       replace $OUT by $OUT/fast and $OUT/track, for instance.

source "$TARGET/configrc"
export TMP_DIR="$OUT/tmp"
mkdir -p $TMP_DIR
# Trimming blocks
for IPROGRAM in "${PROGRAMS[@]}"; do
	python3 -m trimAFL -f -r "$OUT/$IPROGRAM" "$TARGET/bug_functions/$BUG" 2>&1 | tee /dev/stderr | grep 'Trim-number' | awk '{print $NF}' > "$TMP_DIR/$BUG.trim"
	echo "$(cat $TMP_DIR/$BUG.trim) blocks trimmed for $BUG in $IPROGRAM"
done
