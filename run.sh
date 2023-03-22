#!/bin/bash

if [[ $1 == "test" ]]; then
    flask --app py3 --debug run
else
    flask --app py3 run
fi