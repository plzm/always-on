#!/bin/bash

# Shell to a pod
pod=ao-fe-787f74fc7c-2qzvc
kubectl exec --stdin --tty $pod -- /bin/bash
