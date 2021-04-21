# ruby-jit-test

[![Build Status](https://travis-ci.org/junaruga/ruby-jit-test.svg?branch=master)](https://travis-ci.org/junaruga/ruby-jit-test)

## Ruby 3.0.1

```
$ ruby -v
ruby 3.0.1p64 (2021-04-05 revision 0fb782ee38) [x86_64-linux]
```

```
$ ruby script/bench.rb

Warming up --------------------------------------
           calculate    15.000  i/100ms
           calculate    15.000  i/100ms
           calculate    15.000  i/100ms
Calculating -------------------------------------
           calculate      2.342k (± 1.1%) i/s -     11.715k in   5.001947s
           calculate      2.345k (± 0.8%) i/s -     11.730k in   5.002220s
           calculate      2.345k (± 0.8%) i/s -     11.730k in   5.001524s

$ ruby --jit script/bench.rb
Warming up --------------------------------------
           calculate    15.000  i/100ms 
           calculate    15.000  i/100ms
           calculate    15.000  i/100ms
Calculating -------------------------------------
           calculate      2.343k (± 0.8%) i/s -     11.730k in   5.006313s
           calculate      2.344k (± 0.6%) i/s -     11.730k in   5.003485s
           calculate      2.341k (± 1.0%) i/s -     11.715k in   5.004360s

$ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/bench.rb
Warming up --------------------------------------
           calculate    15.000  i/100ms
           calculate    15.000  i/100ms
           calculate    85.000  i/100ms
Calculating -------------------------------------
           calculate     70.734k (± 2.6%) i/s -    353.260k in   4.998053s
           calculate     69.529k (± 2.2%) i/s -    347.310k in   4.997561s
           calculate     65.637k (± 7.8%) i/s -    325.975k in   4.998899s

$ TMP=./tmp ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/bench.rb
Warming up --------------------------------------
           calculate    14.000  i/100ms
           calculate    15.000  i/100ms
           calculate    15.000  i/100ms
Calculating -------------------------------------
           calculate      2.342k (± 0.7%) i/s -     11.715k in   5.003436s
           calculate      2.338k (± 1.5%) i/s -     11.685k in   4.999835s
           calculate      2.341k (± 0.9%) i/s -     11.715k in   5.004408s
```
