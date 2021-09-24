#!/bin/bash

echo Hello ${{ inputs.who-to-greet }}.

echo "::set-output name=random-id::$(echo $RANDOM)"

echo "Goodbye"
