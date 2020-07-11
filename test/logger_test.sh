#!/bin/bash

source ../src/x.sh

function some_func() {
    x-log-info "Hello from here!"
    for i in 1 2 3 4 5; do
        x-log-debug "Doing step $i"
    done
    x-log-error "Huston, we got trouble!"
}


function some_other_func() {
    x-log-info "Starting something..."
    some_func
    x-log-warning "Thing might have not gone well..."
}


some_other_func

