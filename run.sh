#!/bin/bash

if [[ $1 == "debug" ]]; then
    flask --app py3 --debug run -p ${2:-5000}
else
    flask --app py3 run -p ${2:-5000}
fi