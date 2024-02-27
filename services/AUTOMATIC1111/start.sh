#!/bin/bash

set -Eeuo pipefail

chmod +x /docker/build.sh

bash /docker/build.sh

sleep infinity