#!/bin/bash

echo Hello $1.

echo "::set-output name=random-id::$(echo $RANDOM)"

echo "Goodbye"
