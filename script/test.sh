#!/bin/bash

set -euxo pipefail

function clear_tmp {
    rm -rf tmp
    mkdir tmp
}

# Show the environment
rpm -q gcc
rpm -q redhat-rpm-config
rpm -qf "$(command -v ruby)"
ruby -v
gem -v

# Install dependencies
# An iterations per second (i/s) enhancement to Benchmark.
# https://github.com/evanphx/benchmark-ips
gem install --user-install benchmark-ips

# 1: Basic tests
echo "=== Basic tests ==="
ruby --jit --disable-gems -e 'puts "Hello"'
ruby --jit -e 'puts "Hello"'
ruby --jit --jit-verbose=2 -e 'puts "Hello"'

clear_tmp
TMP="$(pwd)/tmp" ruby --jit --jit-verbose=2 --jit-save-temps -e 'puts "Hello"'
ls -1 "$(pwd)/tmp"
ls "$(pwd)/tmp" | grep '^_ruby_mjit_.*\.gch$'

# 2: Benchmark tests
echo "=== Benchmark tests ==="
ruby script/bench.rb
ruby --jit script/bench.rb
# On Ruby 2.7, the default values of
# --jit-min-calls is changed from 5 to 10000.
# --jit-max-cache is changed from 1000 to 100.
# This test is to do benchmark by Ruby 2.6's default values.
# https://github.com/ruby/ruby/commit/0fa4a6a618295d42eb039c65f0609fdb71255355
ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/bench.rb

clear_tmp
TMP="$(pwd)/tmp" ruby --jit --jit-verbose=2 --jit-save-temps --jit-min-calls=5 --jit-max-cache=1000 script/bench.rb
ls "$(pwd)/tmp"
ls "$(pwd)/tmp" | grep '^_ruby_mjit_.*\.gch$'
ls "$(pwd)/tmp" | grep '^_ruby_mjit_.*\.so$'

exit 0
