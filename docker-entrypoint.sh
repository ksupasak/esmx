#!/bin/bash
set -e

# Install gems into the volume cache if not present
bundle check || bundle install

exec "$@"
