#!/bin/bash
set -x

##
# Pre-requirements:
# - env FUZZER: path to fuzzer work dir
# - env TARGET: path to target work dir
# - env OUT: path to directory where artifacts are stored
# - env SHARED: path to directory shared with host (to store results)
# - env PROGRAM: name of program to run (should be found in $OUT)
# - env ARGS: extra arguments to pass to the program
# - env FUZZARGS: extra arguments to pass to the fuzzer
##

# Test if #trimmed-blocks == 0
export count="$(cat $OUT/tmp/$BUG.trim)"
if [[ $count = 0 ]]; then
	echo "Trimmed-blocks = 0 for $BUG"
	echo "Terminating..."
	exit
else
	echo "Trimmed-blocks = $count for $BUG"
fi


mkdir -p "$SHARED/findings"

export AFL_SKIP_CPUFREQ=1
export AFL_NO_AFFINITY=1
"$FUZZER/repo/afl-fuzz" -m 100M -i "$TARGET/corpus/$PROGRAM" -o "$SHARED/findings" \
    $FUZZARGS -- "$OUT/$PROGRAM" $ARGS 2>&1
