export TARBALL_BASENAME="ball"

echo_time() {
    date "+[%F %R] $*"
}
export -f echo_time

contains_element () {
    local e match="$1"
    shift
    for e; do [[ "$e" == "$match" ]] && return 0; done
    return 1
}
export -f contains_element

get_var_or_default() {
    ##
    # Pre-requirements:
    # - $1..N: placeholders
    ##
    function join_by { local IFS="$1"; shift; echo "$*"; }
    pattern=$(join_by _ "${@}")

    name="$(eval echo ${pattern})"
    name="${name}[@]"
    value="${!name}"
    if [ -z "$value" ] || [ ${#value[@]} -eq 0 ]; then
        set -- "DEFAULT" "${@:2}"
        pattern=$(join_by _ "${@}")
        name="$(eval echo ${pattern})"
        name="${name}[@]"
        value="${!name}"
        if [ -z "$value" ] || [ ${#value[@]} -eq 0 ]; then
            set -- "${@:2}"
            pattern=$(join_by _ "${@}")
            name="$(eval echo ${pattern})"
            name="${name}[@]"
            value="${!name}"
        fi
    fi
    echo "${value[@]}"
}
export -f get_var_or_default

if [ ! -z "$MAGMA" ]; then
    # initialize default parameters
    pushd "$MAGMA/targets" &> /dev/null
    shopt -s nullglob
    DEFAULT_TARGETS=(*)
    shopt -u nullglob

    for ITARGET in "${DEFAULT_TARGETS[@]}"; do
        source "$MAGMA/targets/$ITARGET/configrc"
        PROGRAMS_str="${PROGRAMS[@]}"
        declare -a DEFAULT_${ITARGET}_PROGRAMS="($PROGRAMS_str)"

        for IPROGRAM in "${PROGRAMS[@]}"; do
            varname="${IPROGRAM}_ARGS"
            declare DEFAULT_${ITARGET}_${IPROGRAM}_ARGS="${!varname}"
        done

		# Declare another sets, with TARGET_BUG_PROGRAM_ARGS
        BUGS_str="$(ls $MAGMA/targets/$ITARGET/patches/bugs/ | sed 's/.patch//g')"
		BUGS=($BUGS_str)
        declare -a DEFAULT_${ITARGET}_BUGS="($BUGS_str)"

        for IBUG in "${BUGS[@]}"; do
			# Set programs to [bug_PROGRAMS] if assigned
			# Otherwise use original program lists [PROGRAMS]
			bugprograms="${IBUG}_PROGRAMS"
			if [ ! -z "${!bugprograms}" ]; then
				vars=$bugprograms[@]
				PROGRAMS_str="${!vars}"
			else
        		PROGRAMS_str="${PROGRAMS[@]}"
			fi
        	declare -a DEFAULT_${ITARGET}_${IBUG}_PROGRAMS="($PROGRAMS_str)"

			# Set program args to bug_program_ARGS if assigned
			# Otherwise use original program args program_ARGS
			for IPROGRAM in "${PROGRAMS[@]}"; do
				dvarname="${IBUG}_${IPROGRAM}_ARGS"
				if [ ! -z "${!dvarname}" ];then
            		varname=$dvarname
				else
            		varname="${IPROGRAM}_ARGS"
				fi
				declare DEFAULT_${ITARGET}_${IBUG}_${IPROGRAM}_ARGS="${!varname}"
			done
        done
    done
    popd &> /dev/null
else
    echo 'The $MAGMA environment variable must be set before sourcing common.sh'
    exit 1
fi
