
.. image:: https://gpf.readthedocs.io/en/latest/_images/gpf-logo.png

----

.. image:: https://img.shields.io/github/v/tag/ultralightweight/x.sh  
    :target: http://github.com/ultralightweight/x.sh
    :alt: GitHub tag (latest SemVer)


.. image:: https://img.shields.io/github/issues-raw/ultralightweight/x.sh
    :target: https://github.com/ultralightweight/x.sh/issues
    :alt: GitHub issues




=========
Overview
=========

`x.sh` - eXtended baSH - call stack and logging for Bash scripts

These utils makes debugging and running complex bash scripts (which nobody should have, 
but we all end up having anyway) easy and pretty.


Installation
=============

1. Download the latest version using your favourite CLI web client:
   
.. code-block:: bash

   wget https://raw.githubusercontent.com/ultralightweight/x.sh/master/src/x.sh

   curl https://raw.githubusercontent.com/ultralightweight/x.sh/master/src/x.sh > x.sh


2. Sourcing the file into your script
    

Source the file in your script to enable strict mode and call stack printing upon error.

.. code-block:: bash

    source x.sh



Usage
=====

Call stack
^^^^^^^^^^^

By sourcing the script it will automatically enable `bash strict mode <http://redsymbol.net/articles/unofficial-bash-strict-mode>`_ using::

    set -E -uo pipefail

and install the call stack exception trap.


Consider the following example:


.. code-block:: bash

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


There is an error in `some_func`, and it will be called indirectly. Running the above script with 
trigger an error, and the error trap in `x.sh` will print a python-like call-stack:


.. code-block:: bash

    $ ./test/callstack.test.sh 
    hello world, let's call some function
    hey!
    ./callstack_test.sh: line 7: non_exitent_command: command not found
    -----------------------------------------------------
    Traceback (most recent call last):
      File "./callstack.test.sh", line 16, in main
        some_other_func
      File "./callstack.test.sh", line 13, in some_other_func
        some_func
      File "./callstack.test.sh", line 7, in some_func
        non_exitent_command
       
    error in ./callstack.test.sh line 7, command `non_exitent_command` returned 127


Logging 
^^^^^^^^

Why logging in bash? 

Logging in bash is just as easy as calling `echo`, so why bother?

The logging functions in `x.sh` will create a python-like log record, with timestamp, log level, and
automatic inclusion of where the log came from. For example:


.. code-block:: bash

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


Running the test will generate the following log records.


.. code-block:: bash

    $ ./test/logger_test.sh 
    2020-07-08 08:33:10.202 INFO    logger_test.sh:some_other_func  Starting something...
    2020-07-08 08:33:10.206 INFO    logger_test.sh:some_func    Hello from here!
    2020-07-08 08:33:10.209 ERROR   logger_test.sh:some_func    Huston, we got trouble!
    2020-07-08 08:33:10.213 WARNING logger_test.sh:some_other_func  Thing might have not gone well...



Notice that debug logs are not visible. Debug log lines are hidden unless debug mode is enabled 
by setting the `XSH_DEBUG` environment variable to a non-empty value. For example:


.. code-block:: bash

    [dev@uldevbox test]$ export XSH_DEBUG=1; ./logger_test.sh 
    2020-07-08 08:36:25.377 INFO    ./logger_test.sh:some_other_func:15 Starting something...
    2020-07-08 08:36:25.380 INFO    ./logger_test.sh:some_func:6    Hello from here!
    2020-07-08 08:36:25.382 DEBUG   ./logger_test.sh:some_func:8    Doing step 1
    2020-07-08 08:36:25.384 DEBUG   ./logger_test.sh:some_func:8    Doing step 2
    2020-07-08 08:36:25.386 DEBUG   ./logger_test.sh:some_func:8    Doing step 3
    2020-07-08 08:36:25.388 DEBUG   ./logger_test.sh:some_func:8    Doing step 4
    2020-07-08 08:36:25.390 DEBUG   ./logger_test.sh:some_func:8    Doing step 5
    2020-07-08 08:36:25.392 ERROR   ./logger_test.sh:some_func:10   Huston, we got trouble!
    2020-07-08 08:36:25.395 WARNING ./logger_test.sh:some_other_func:17 Thing might have not gone well...


The `ERROR` and `WARNING` records are written to `stderr`, all other lines are written `stdout`. For
example, redirecting `stdout` to `/dev/null` would only display us errors::


.. code-block:: bash

    [dev@uldevbox test]$ export XSH_DEBUG=1; ./logger_test.sh > /dev/null 
    2020-07-08 08:37:20.053 ERROR   ./logger_test.sh:some_func:10   Huston, we got trouble!
    2020-07-08 08:37:20.055 WARNING ./logger_test.sh:some_other_func:17 Thing might have not gone well...




=============
Contributing
=============

Feedback and pull requests are always welcome! 


========
Licence
========

This library is available under `MIT Licence <https://opensource.org/licenses/MIT>`_.





