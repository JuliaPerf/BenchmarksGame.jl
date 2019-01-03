# BenchmarksGame

Repo to optimize the benchmarkrs for the Benchmark game "competition".

Run benchmarks with:

```
julia --project --color=yes run_benchmarks.jl
```

to verify correctness add an argument `verify`

## Results

```
 ────────────────────────────────────────────────
 Section                   ncalls     time   %tot
 ────────────────────────────────────────────────
 knucleotide                    1     161s  43.3%
   knucleotide.jl               1     149s  40.1%
   knucleotide-fast.jl          1    11.7s  3.15%
 binarytrees                    1    46.1s  12.4%
   binarytrees.jl               1    42.9s  11.5%
   binarytree-fast.jl           1    2.99s  0.80%
 fannkuchredux                  1    41.3s  11.1%
   fannkuchredux.jl             1    32.8s  8.82%
   fannkuchredux-fast.jl        1    8.43s  2.27%
 fasta                          1    30.8s  8.28%
   fasta.jl                     1    24.7s  6.63%
   fasta-fast.jl                1    6.17s  1.66%
 mandelbrot                     1    29.3s  7.86%
   mandelbrot.jl                1    26.5s  7.11%
   mandelbrot-fast.jl           1    2.81s  0.75%
 nbody                          1    28.3s  7.61%
   nbody-2.jl                   1    17.9s  4.82%
   nbody.jl                     1    6.07s  1.63%
   nbody-fast.jl                1    4.31s  1.16%
 regexredux                     1    16.4s  4.41%
   regexredux.jl                1    16.4s  4.41%
 revcomp                        1    10.2s  2.74%
   revcomp.jl                   1    7.30s  1.96%
   revcomp-fast.jl              1    2.91s  0.78%
 spectralnorm                   1    5.65s  1.52%
   spectralnorm.jl              1    4.22s  1.13%
   spectralnorm-fast.jl         1    1.43s  0.38%
 pidigits                       1    3.13s  0.84%
   pidigits.jl                  1    1.95s  0.52%
   pidigits-fast.jl             1    1.18s  0.32%
 ────────────────────────────────────────────────
 ```
