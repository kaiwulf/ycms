#!/bin/bash

if [[ $1 == "debug" ]]; then
    flask --app app --debug run -p ${2:-5000}
else
    flask --app app run -p ${2:-5000}
fi
