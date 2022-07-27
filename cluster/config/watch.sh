#!/usr/bin/env bash
set -euo pipefail

app=$1
inotifywait -e modify -r -m $app |
    while read path action file; do
        echo $path$file

        # here so script survives over pod updates
        pod=$(kubectl get pods -l app.kubernetes.io/name=$app -o jsonpath='{.items[].metadata.name}')

        kubectl cp $path$file $pod:${path#$app/}${file#/}
    done
