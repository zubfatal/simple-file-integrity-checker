#!/bin/bash
_prog_name="Simple File Integrity Checker"
_prog_ver="1.0"

do_update=0
do_verify=0

# ----------
# Display error message and exit
# ----------
function error_exit()
{
    local msg=$1

    if [ ! -z "${msg}" ]; then
        echo "[ERR] ${msg}"
        exit 1;
    fi
}

# ----------
# Get absolute path of file (similar to readlink -f <file>)
# http://stackoverflow.com/a/17577143
# ----------
function myreadlink()
{
    (
        cd $(dirname $1)
        echo $PWD/$(basename $1)
    )
}

# ----------
# Display help
# ----------
function  show_help()
{
    cat << EOF

${_prog_name} v${_prog_ver}

    Update and verify checksums of filenames

USAGE: `basename $0` -f <file> <options>

OPTIONS:
    -f, --file <filename>       - Filename with list of files/paths
    -c, --check, --verify       - Verify checksums
    -u, --update                - Update checksums
    -h, --help                  - You're looking at it :)
    -V                          - Show program version.

EOF
    exit
}


# ---------
# Check "dependencies"
# ---------
[[ -z $( command -v md5sum ) ]] && error_exit "Command \"md5sum\" required, aborting.."

[[ $# -eq 0 ]] && show_help

# ----------
# Handle arguments
# ----------
while (( $# )); do
    case $1 in
        -h | --help)
            show_help
            ;;

        -u | --update)
            [[ ${do_verify:-0} -eq 1 ]] && error_exit "$1 cannot be used with -c|--check|--verify"
            do_update=1
            shift
            ;;

        -c | --check | --verify)
            [[ ${do_update:-0} -eq 1 ]] && error_exit "$1 cannot be used with -u|--update"
            do_verify=1
            shift
            ;;

        -f | --file)
            [[ -z "$2" ]] && error_exit "argument reguired for $1"
            [[ ! -f "$2" ]] && error_exit "invalid file: $2"
            infile=$2
            outfile="${infile}.md5"
            shift 2
            ;;

        -V)
            echo "${_prog_name} v${_prog_ver}"
            exit
            ;;

        -*)
            error_exit "Unrecognized option: $1"
            ;;

        *)
            break
    esac
done


# ----------
# Debug
# ----------
if [ 2 -eq 1 ]; then
    echo "--- DEBUG START ---"
    echo "do_update: ${do_update}"
    echo "do_verify: ${do_verify}"
    echo "infile: ${infile}"
    echo "outfile: ${outfile}"
    echo "--- DEBUG END ---"
fi

# ----------
# -f/--file is required for "update" or "verify"
# ----------
if [ ${do_update:-0} -eq 1 ] || [ ${do_verify:-0} -eq 1 ]; then
    [[ -z "${infile}" ]] && error_exit "-f <filename> or --file <filename> required."
fi

# ----------
# Update checksums
# ----------
if [ ${do_update:-0} -eq 1 ]; then
    outdir=$( dirname ${infile} )
    [[ ! -w "${outdir}" ]] && error_exit "Directory \"${outdir}\" is not writable."

    if [ -f "${infile}" ]; then
        #cat /dev/null > ${outfile}
        checkfile=$( myreadlink ${infile} )
        md5sum ${checkfile} > ${outfile}

        for filespec in $( egrep -v "^(#|;)" ${infile} ) ; do
                md5sum ${filespec} 2>/dev/null >> ${outfile}
        done
    fi
fi

# ----------
# Verify checksums
# ----------
if [ ${do_verify:-0} -eq 1 ]; then
    [[ ! -f ${outfile} ]] && error_exit "${outfile} missing, you might want to use \"--update\" first."
    md5sum -c ${outfile}
fi

# ----------
# No action? (-u/-c) - show help
# ----------
[[ ${do_update:-0} -eq 0 && ${do_verify:-0} -eq 0 ]] && show_help
