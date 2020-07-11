#!/bin/bash

source ../src/x.sh

function some_func() {
    echo "hey!"
    non_exitent_command
}


function some_other_func() {
    echo "hello world, let's call some function"
    some_func
}

some_other_func


