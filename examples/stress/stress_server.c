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

usec_timestamp_t start_ts = 0;

//
// Receive a value and check its integrity
// Invoked by deserilisation code generated by DSTC_SERVER() above.
// Please note that the arguments must match between the function below
// and the macro above.
//
void set_value(int value)
{
    static int last_value = -1;
    int ret;

    if (start_ts == 0)
        start_ts = rmc_usec_monotonic_timestamp();


    if (value == -1) {
        usec_timestamp_t stop_ts = rmc_usec_monotonic_timestamp();
        printf("Processed %d calls in %.2f sec -> %.2f calls/sec\n",
               last_value,
               (stop_ts - start_ts) / 1000000.0,
               last_value / ((stop_ts - start_ts) / 1000000.0));

        while((ret = dstc_process_single_event(0)) != ETIME)
            ;
        printf("Exiting: %s\n", strerror(errno));
        exit(0);
    }

    if (value % 100000 == 0)
        printf("Value: %d\n", value);


    // Check that we got the expected value.
    if (last_value != -1 && value != last_value + 1 ) {
        printf("Integrity failure!  Want value %d Got value %d\n",
               last_value +1 , value);
        exit(255);
    }
    last_value = value;
}


int main(int argc, char* argv[])
{
    // Process incoming events forever
    dstc_process_events(-1);
}
