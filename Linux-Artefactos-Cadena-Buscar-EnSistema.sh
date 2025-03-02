#!/bin/bash

find / -type f -exec sh -c 'strings "$1" | grep -q "Uk17" && echo "Coincidencia de Uk17 en: $1"' _ {} \; 2>/dev/null
echo ""
find / -type f -exec sh -c 'strings "$1" | grep -q "RM{" && echo "Coincidencia de RM{ en: $1"' _ {} \; 2>/dev/null
echo ""
