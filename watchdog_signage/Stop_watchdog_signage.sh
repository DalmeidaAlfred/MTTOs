#!/bin/bash
for KILLPID in $(ps ax | grep watchdog_signage | awk '{print $1;}'); do
kill -9 $KILLPID;
done