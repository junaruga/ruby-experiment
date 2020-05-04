## Summary

Benchmark the following cases for Ruby 2.7.1.

1. Ruby 2.7.1 (tag: v2_7_1) with gcc.
2. Ruby 2.7.1 (tag: v2_7_1 + 1 commit to disable PCH explictly) with gcc. See `junaruga/ruby` repository `feature/jit-disable-making-pch-on-v2_7_1`branch.
3. Ruby 2.7.1 clang(tag: v2_7_1) with clang.

## How to disable PCH explicitly

For the 2nd case, here is the way to disable PCH explicitly.

Diable making PCH by the following patch.

```
diff --git a/mjit_worker.c b/mjit_worker.c
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
autoconf
./configure \
  --prefix=/home/root/local/ruby-2.7.1-jit-disable-making-pch \
  --enable-shared
make
sudo make install
```

## Result

### Fedora 31

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


