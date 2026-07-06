#!/usr/bin/env bash
set -e
source "$HOME/.rvm/scripts/rvm"
rvm use 3.3.8 >/dev/null
cd "$(dirname "$0")/.."
exec bundle exec rails server -p "${PORT:-3000}" -b 127.0.0.1
