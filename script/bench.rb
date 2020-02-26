# https://k0kubun.hatenablog.com/entry/ruby26-jit

require 'benchmark/ips'

def calculate(a, b, n = 40_000_000)
  i = 0
  c = 0
  while i < n
    a = a * 16807 % 2147483647
    b = b * 48271 % 2147483647
    c += 1 if (a & 0xffff) == (b & 0xffff)
    i += 1
  end
  c
end

Benchmark.ips do |x|
  x.iterations = 3
  x.report("calculate") do |times|
    calculate(65, 8921, 100_000)
  end
end
