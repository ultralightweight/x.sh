#!/bin/bash
# -----------------------------------------------------------------------------
# package: X.sh - eXtended baSH
# author: Daniel Kovacs <mondomhogynincsen@gmail.com>
# licence: MIT <https://opensource.org/licenses/MIT>
# url: https://github.com/ultralightweight/x.sh
# description: 
# version: 2.0
# -----------------------------------------------------------------------------

# Copyright (c) 2020 Daniel Kovacs

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# ------------------------------------------------
# enable strict mode
# ------------------------------------------------
# Read more about strict mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/

set -E -uo pipefail
IFS=$'\n    '    


# -----------------------------------------------------------
# provisioner.sh version
# -----------------------------------------------------------

_XSH_VERSION=2.0


# -----------------------------------------------------------
# Debugging
# -----------------------------------------------------------
#
# Uncomment the following line to debug the provisioner script
#

export XSH_DEBUG=${XSH_DEBUG:-}

# -----------------------------------------------------------
# Library mode control variables
# -----------------------------------------------------------

# XSH_LIBRARY=${XSH_LIBRARY:-}
XSH_LOG_BASE=${XSH_LOG_BASE:-}


# ------------------------------------------------
# x_print_traceback()
# ------------------------------------------------

function x_print_traceback() {
  local i=0
  local FRAMES=${#BASH_LINENO[@]}
  echo "-----------------------------------------------------" >&2
  echo "Traceback (most recent call last):" >&2
  for ((i=FRAMES-2; i>=1; i--)); do
    source=$(sed "${BASH_LINENO[i]}q;d" "${BASH_SOURCE[i+1]}" | sed 's/^ *//g')
    lineno=${BASH_LINENO[i]}
    echo "  File \"${BASH_SOURCE[i+1]}\", line ${lineno}, in ${FUNCNAME[i+1]}" >&2
    echo "    ${source}" >&2
  done
}


# ------------------------------------------------
# x_exception_trap
# ------------------------------------------------

function x_exception_trap() {
    local exit_code=$1
    local line_no=$2
    local signal_name=$3
    if (( $exit_code != 0 && $exit_code != 177 )); then 
        x_print_traceback
        echo "   " >&2
        echo "error in ${BASH_SOURCE[1]} line $line_no, command \`${BASH_COMMAND}\` returned $exit_code" >&2
        echo "   " >&2
        # We need to do this to be able to handle nested errors
    fi
    [[ "$exit_code" == "0" ]] && exit 0
    if [[ "$signal_name" == "ERR" && "$exit_code" == "177" ]]; then
        exit 178
    else
        exit 177
    fi
}


# ------------------------------------------------
# activate exception trap
# ------------------------------------------------

trap 'x_exception_trap $? ${LINENO} ERR' ERR
trap 'x_exception_trap $? ??? EXIT' EXIT   # we loose line number info in EXIT trap for some godforsaken reason. :-/


# -----------------------------------------------------------
# x_get_caller()
# -----------------------------------------------------------

function x_get_caller() {
    local i=${1:-1}
    if [ -z $XSH_DEBUG ]; then
        local source="${XSH_LOG_BASE}$(basename ${BASH_SOURCE[i+1]}):${FUNCNAME[i+1]}"
    else
        local source="${XSH_LOG_BASE}${BASH_SOURCE[i+1]}:${FUNCNAME[i+1]}:${BASH_LINENO[i]}"
    fi
    echo $source
}


# -----------------------------------------------------------
# x-log-to-fd()
# -----------------------------------------------------------

function x-log-to-fd() {
    local timestamp=$(date "+%F %T.%3N")
    local source=$(x_get_caller 2)
    local level=$1
    local message=$2
    local to_stderr=${3:-}
    local log_line="${timestamp}\t${level}\t${source}\t${message}"
    if [ -z $to_stderr ]; then
        echo -e "${log_line}"
    else
        echo -e ${log_line} >&2
    fi
}


# -----------------------------------------------------------
# x-log-debug()
# -----------------------------------------------------------

function x-log-debug() {
    if [ -z $XSH_DEBUG ]; then
        return
    fi
    x-log-to-fd "DEBUG" "$1"
}


# -----------------------------------------------------------
# x-log-info()
# -----------------------------------------------------------

function x-log-info() {
    x-log-to-fd "INFO" "$1"
}


# -----------------------------------------------------------
# x-log-notice()
# -----------------------------------------------------------

function x-log-notice() {
    x-log-to-fd "NOTICE" "$1"
}


# -----------------------------------------------------------
# x-log-warning()
# -----------------------------------------------------------

function x-log-warning() {
    x-log-to-fd "WARNING" "$1" 1
}


# -----------------------------------------------------------
# x-log-error()
# -----------------------------------------------------------

function x-log-error() {
    x-log-to-fd "ERROR" "$1" 1
}


# -----------------------------------------------------------
# enabling command echo
# -----------------------------------------------------------

# if [[ -n ${XSH_DEBUG} ]]; then
#     set -x -v
# fi


