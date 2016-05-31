#!/bin/bash

fold () {
    funct = "$@"
    read acc 
    while read elem; do
        acc = "$(printf "%d$acc\n$elem" | $funct)"
    done
    echo $acc
}

list () {
    for i in "$@"; do 
        echo "$i"
    done
}

rlist () {
    i = "$#"
    while [ $i -gt 0 ]; do
        eval "f=\${$i}"
        echo "$f"
        i=$((i-1))
    done
}

filter () {
    funct = "$@"
    resp =
    while read elem; do
        acc = "$(printf "${elem}" | $funct)"
        if [$acc -eq 1]; then
            resp+=" $elem"
        fi
    done
    echo $resp
}

match () {
    funct = "$@"
    while read elem; do 
        acc = "$(printf "${elem}" | $funct)"
        if [$acc -eq 1]; then
            echo $elem
            break
        fi
    done
}

position () {
    funct = "$@"
    pos = 0 
    while read elem; do 
        acc = "$(printf "${elem}" | $funct)"
        if [$acc -eq 1]; then
            echo $pos
            break
        fi
        pos=$((pos+1))
    done
}

lambda () {
    lam() {
        unset last

        for last; do
            shift
            if [[ $last = ":" ]]; then
                echo "$@"
                return
            else
                echo "read $last;"
            fi
        }
    done
    if [["$y"="stdin"]];then
        read funct
        eval $(lam "$@ : $funct")
    else
        eval $(lam "$@")
    fi
    unset y
    unset i
    unset funct
}

partial () {
    exportfun=$1; shift
    fun = $1; shift
    params = $*
    eval "$exportfun() {
        more_param=\$*;
        $fun $params \$more_params;
    }"
}
    
compose () {
    exportfun=$1; shift
    f1=$1; shift
    f2=$2; shift
    eval "$exportfun() {
            $f1 \$($f2 \$*);
        }"
}





