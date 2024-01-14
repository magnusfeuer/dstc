#!/bin/bash
#
# Run tests.
#

TESTS="print_name_and_age many_arguments callback print_struct dynamic_data string_data stress thread_stress no_argument"
TIMEOUT=30 # seconds
export DSTC_MCAST_IFACE_ADDR=127.0.0.1

# Make sure we are started with an absolute path
if [ "${0:0:1}" != '/' ]; then
   exec ${PWD}/${0}
fi

pushd "${0%/*}/examples"

for TEST in $TESTS
do
    echo "-------------------------"
    echo "Running test $TEST"
    echo "-------------------------"

    if [ -d "./$TEST" ]; then
      cd $TEST
    fi

    if [ ! -f ./${TEST}_server ]
    then
        echo "${PWD}/${TEST}_server: Not found"
        exit 1
    fi

    if [ ! -f ./${TEST}_client ]
    then
        echo "${PWD}/${TEST}_client: Not found"
        exit 1
    fi
    echo "Passed file check"
    
    timeout 15s ./${TEST}_server &
    timeout 15s ./${TEST}_client &
    wait %1
    RES=$?
    if [ ! $RES ]
    then
        echo "\nTest client ${TEST} FAILED with exit code $RES.\n"
        exit $RES
    fi
    wait %2

    RES=$?
    if [ ! $RES ]
    then
        echo "\nTest server ${TEST} FAILED with exit code $RES.\n"
        exit $RES
    fi

    if [ "$(basename $PWD)" ==  ${TEST} ]; then
      cd ..
    fi

    echo "------"
    echo "Test $TEST passed"
    echo
    echo

done

popd

exit 0
