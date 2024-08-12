#!/bin/bash

for KILLPID in $(ps ax | grep optisigns | grep -v grep | awk '{print $1}'); do
            kill $KILLPID
        done