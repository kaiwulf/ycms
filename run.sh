#!/bin/bash

if [[ $1 == "debug" ]]; then
    flask --app py3 --debug run
else
    flask --app py3 run
fi
