#!/bin/bash

### TODO: Check cmd line params ###

while true; do \
    grep --text $*; echo '----------'; date; echo '----------'; grep --text $* | wc -l; sleep 3; \
done
