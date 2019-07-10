// Copyright (C) 2018, Jaguar Land Rover
// This program is licensed under the terms and conditions of the
// Mozilla Public License, version 2.0.  The full text of the
// Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
//
// Author: Magnus Feuer (mfeuer1@jaguarlandrover.com)
//
// Running example code from README.md in https://github.com/PDXOSTC/dstc
//

#include <stdio.h>
#include <stdlib.h>
#include "dstc.h"
#include "rmc_log.h"


// Generate deserializer for multicast packets sent by dstc_message()
// above.
// The deserializer decodes the incoming data and calls the
// print_name_and_age() function in this file.
//
DSTC_SERVER(double_value, int,, DSTC_DECL_CALLBACK_ARG)

//
// Print out name and age.
// Invoked by deserilisation code generated by DSTC_SERVER() above.
// Please note that the arguments must match between the function
// below and the macro above.
//
// The funtiuon argument callback_ref is provided as the first
// argument to DSTC_CALLBACK().
// The DSTC_CALLBACK() macro generates a local function called
// dstc_[name] where name is the name of the callback reference,
// (callback_ref in the example below).
//
void double_value(int value, dstc_callback_t callback_ref)
{
    DSTC_SERVER_CALLBACK(callback_ref, int,);

    if (value == -1) {
        puts("double_value(-1): Got exit signal.");
        dstc_process_events(0);
        exit(0);
    }

    printf("double_value(%d) called with a callback\n", value);
    dstc_callback_ref(value + value);
    dstc_process_events(0);
    exit(0);
}

int main(int argc, char* argv[])
{
    // Process incoming events for ever
    while(1)
        dstc_process_events(-1);

    exit(0);
}
