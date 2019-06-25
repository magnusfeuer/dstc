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
#include <errno.h>

// Generate deserializer for multicast packets sent by the client
// The deserializer decodes the incoming data and calls the
// set_value() function in this file.
//
DSTC_SERVER(set_value, int,)

//
// Receive a value and check its integrity
// Invoked by deserilisation code generated by DSTC_SERVER() above.
// Please note that the arguments must match between the function below
// and the macro above.
//
void set_value(int value)
{
    static int integrity_check_val = -1;
    static int last_value = 0;
    static usec_timestamp_t last_ts = 0;
    usec_timestamp_t now = rmc_usec_monotonic_timestamp();

    if (value == -1) {
        int ret = 0;
        puts("Got exit trigger from client.");
        while((ret = dstc_process_single_event(0)) != ETIME)
            ;
        printf("Exiting: %s\n", strerror(errno));
        exit(0);
    }

    if (now - last_ts > 1000000) {
        float cps = (value - last_value) / ((now - last_ts) / 1000000.0);

        printf("Value: %d - %.2f calls per sec\n", value, cps);
        last_ts = now;
        last_value = value;
    }

    // Check that we got the expected value.
    if (integrity_check_val != -1 && value != integrity_check_val + 1 ) {
        printf("Integrity failure!  Want value %d Got value %d\n",
               integrity_check_val +1 , value);
        exit(255);
    }
    integrity_check_val = value;
}


int main(int argc, char* argv[])
{
    // Process incoming events forever
    dstc_process_events(-1);
}
