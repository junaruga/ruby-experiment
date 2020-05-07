## Summary

Benchmark the following cases for Ruby 2.7.1.

1. Ruby 2.7.1 (tag: v2_7_1) with gcc.
2. Ruby 2.7.1 (tag: v2_7_1 + 1 commit to disable PCH explictly) with gcc. See `junaruga/ruby` repository `feature/jit-disable-making-pch-on-v2_7_1`branch.
3. Ruby 2.7.1 clang(tag: v2_7_1) with clang.

## How?

### How to disable PCH explicitly

For the 2nd case, here is the way to disable PCH explicitly.

Diable making PCH by the following patch.

```
$ diff --git a/mjit_worker.c b/mjit_worker.c
index ce8133ac7d..109f584c27 100644
--- a/mjit_worker.c
+++ b/mjit_worker.c
@@ -1195,7 +1195,10 @@ mjit_worker(void)
 {
 #ifndef _MSC_VER
     if (pch_status == PCH_NOT_READY) {
-        make_pch();
+        /* Disable making PCH explicitly. */
+        /* make_pch(); */
+        verbose(2, "Disabling making PCH explicitly");
+        pch_status = PCH_FAILED;
     }
 #endif
     if (pch_status == PCH_FAILED) {
```

Then bulid.

```
$ autoconf
$ ./configure \
  --prefix=/home/root/local/ruby-2.7.1-jit-disable-making-pch \
  --enable-shared
$ make
$ sudo make install
```

### How to build with clang

```
$ autoconf
$ CC=clang ./configure \
  --prefix=/home/root/local/ruby-2.7.1-clang \
  --enable-shared
$ make
$ sudo make install
```

## Result

### Fedora 31

Test with the following packages.

```
$ rpm -q gcc
gcc-9.3.1-2.fc31.x86_64

$ rpm -q clang
clang-9.0.1-2.fc31.x86_64

$ gem list benchmark-ips

*** LOCAL GEMS ***

benchmark-ips (2.7.2)
```

#### Case 1: Ruby 2.7.1 with gcc

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    11.000  i/100ms
Calculating -------------------------------------
           calculate      1.354k (± 5.7%) i/s -      6.743k in   5.002005s
           calculate      1.381k (± 4.1%) i/s -      6.897k in   5.004051s
           calculate      1.397k (± 1.4%) i/s -      6.985k in   5.000408s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.500k (± 2.8%) i/s -      7.500k in   5.004419s
           calculate      1.481k (± 3.6%) i/s -      7.392k in   5.000023s
           calculate      1.473k (± 3.1%) i/s -      7.368k in   5.007235s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate    10.000  i/100ms
           calculate    23.000  i/100ms
           calculate    57.000  i/100ms
Calculating -------------------------------------
           calculate     33.912k (± 7.4%) i/s -    167.979k in   4.997344s
           calculate     33.561k (± 8.7%) i/s -    165.699k in   4.997015s
           calculate     33.208k (± 8.9%) i/s -    163.932k in   4.996438s
```

#### Case 2: Ruby 2.7.1 disabling making PCH with gcc

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.507k (± 2.7%) i/s -      7.536k in   5.006438s
           calculate      1.496k (± 1.7%) i/s -      7.488k in   5.006530s
           calculate      1.483k (± 2.6%) i/s -      7.416k in   5.003868s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.507k (± 2.1%) i/s -      7.536k in   5.001838s
           calculate      1.491k (± 1.2%) i/s -      7.464k in   5.006098s
           calculate      1.486k (± 2.3%) i/s -      7.428k in   5.001601s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.463k (± 2.0%) i/s -      7.320k in   5.007380s
           calculate      1.457k (± 2.5%) i/s -      7.284k in   5.003420s
           calculate      1.462k (± 2.0%) i/s -      7.308k in   5.000452s
```

#### Case 3: Ruby 2.7.1 with clang

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.542k (± 2.8%) i/s -      7.704k in   5.002345s
           calculate      1.508k (± 2.7%) i/s -      7.536k in   5.001676s
           calculate      1.507k (± 2.4%) i/s -      7.536k in   5.003805s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
           calculate    12.000  i/100ms
Calculating -------------------------------------
           calculate      1.514k (± 3.2%) i/s -      7.560k in   5.000305s
           calculate      1.529k (± 1.5%) i/s -      7.644k in   4.999730s
           calculate      1.526k (± 1.5%) i/s -      7.632k in   5.002867s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate    11.000  i/100ms
           calculate    33.000  i/100ms
           calculate    60.000  i/100ms
Calculating -------------------------------------
           calculate     36.245k (± 5.8%) i/s -    180.240k in   4.997412s
           calculate     36.213k (± 4.7%) i/s -    180.480k in   4.997622s
           calculate     34.513k (± 7.7%) i/s -    171.060k in   4.997318s
```

### RHEL 8.2 (mock environment)

Test with the following packages.

```
$ rpm -q gcc
gcc-8.3.1-5.el8.x86_64

$ rpm -q clang
clang-9.0.1-2.module+el8.2.0+5494+7b8075cf.x86_64

$ gem list benchmark-ips

*** LOCAL GEMS ***

benchmark-ips (2.7.2)
```

Install the following RPM packages in advance to the mock environment.

```
yum autoconf gdbm-devel libffi-devel openssl-devel libyaml-devel readline-devel procps multilib-rpm-config gcc zlib-devel clang ruby ruby-devel bison
```

#### Case 1: Ruby 2.7.1 with gcc

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
Calculating -------------------------------------
           calculate    282.461  (± 2.1%) i/s -      1.415k in   5.012423s
           calculate    283.816  (± 2.5%) i/s -      1.420k in   5.006874s
           calculate    288.650  (± 0.7%) i/s -      1.445k in   5.006260s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
Calculating -------------------------------------
           calculate    287.992  (± 0.7%) i/s -      1.440k in   5.000391s
           calculate    287.090  (± 1.4%) i/s -      1.440k in   5.016940s
           calculate    284.554  (± 2.1%) i/s -      1.425k in   5.010193s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate     4.000  i/100ms
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
Calculating -------------------------------------
           calculate    285.795  (± 0.7%) i/s -      1.430k in   5.003995s
           calculate    284.122  (± 2.5%) i/s -      1.420k in   5.001124s
           calculate    284.562  (± 1.4%) i/s -      1.425k in   5.008767s
```


#### Case 2: Ruby 2.7.1 disabling making PCH with gcc

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
Calculating -------------------------------------
           calculate    365.446  (± 1.6%) i/s -      1.830k in   5.008931s
           calculate    361.716  (± 1.1%) i/s -      1.812k in   5.009961s
           calculate    359.241  (± 0.8%) i/s -      1.800k in   5.010823s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
Calculating -------------------------------------
           calculate    362.450  (± 1.9%) i/s -      1.812k in   5.001645s
           calculate    358.972  (± 2.0%) i/s -      1.794k in   4.999507s
           calculate    359.031  (± 2.2%) i/s -      1.800k in   5.015893s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
           calculate     5.000  i/100ms
Calculating -------------------------------------
           calculate    295.370  (± 1.4%) i/s -      1.480k in   5.011644s
           calculate    295.359  (± 0.7%) i/s -      1.480k in   5.011172s
           calculate    294.600  (± 1.4%) i/s -      1.475k in   5.008024s
```

#### Case 3: Ruby 2.7.1 with clang

```
+ ruby script/../script/bench.rb
Warming up --------------------------------------
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
Calculating -------------------------------------
           calculate    402.690  (± 2.0%) i/s -      2.016k in   5.008176s
           calculate    397.647  (± 2.8%) i/s -      1.992k in   5.013852s
           calculate    403.281  (± 2.5%) i/s -      2.016k in   5.002705s
+ ruby --jit script/../script/bench.rb
Warming up --------------------------------------
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
           calculate     6.000  i/100ms
Calculating -------------------------------------
           calculate    404.065  (± 1.0%) i/s -      2.022k in   5.004813s
           calculate    402.804  (± 1.5%) i/s -      2.016k in   5.006360s
           calculate    402.548  (± 1.2%) i/s -      2.016k in   5.008849s
+ ruby --jit --jit-min-calls=5 --jit-max-cache=1000 script/../script/bench.rb
Warming up --------------------------------------
           calculate     6.000  i/100ms
           calculate    11.000  i/100ms
           calculate    56.000  i/100ms
Calculating -------------------------------------
           calculate     31.776k (± 4.0%) i/s -    158.424k in   4.996475s
           calculate     32.434k (± 4.7%) i/s -    161.616k in   4.997209s
           calculate     32.332k (± 4.3%) i/s -    161.224k in   4.997374s
```
