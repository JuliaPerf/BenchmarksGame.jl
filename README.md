# BenchmarksGame

Repo to optimize the benchmarkrs for the Benchmark game "competition".

Run benchmarks with:

```
julia --project --color=yes run_benchmarks.jl
```

to verify correctness add an argument `verify`

## Results

```
 Section                   ncalls     time   %tot
 ────────────────────────────────────────────────
 knucleotide                    1     222s  49.4%
   knucleotide.jl               1     152s  33.9%
   knucleotide-fast.jl          1    69.6s  15.5%
 binarytrees                    1    71.7s  15.9%
   binarytrees.jl               1    43.0s  9.57%
   binarytree-fast.jl           1    28.6s  6.36%
 fannkuchredux                  1    42.8s  9.52%
   fannkuchredux.jl             1    33.0s  7.34%
   fannkuchredux-fast.jl        1    9.82s  2.18%
 nbody                          1    28.9s  6.44%
   nbody-2.jl                   1    18.3s  4.06%
   nbody.jl                     1    5.57s  1.24%
   nbody-fast.jl                1    5.10s  1.13%
 mandelbrot                     1    28.6s  6.35%
   mandelbrot.jl                1    26.4s  5.87%
   mandelbrot-fast.jl           1    2.18s  0.49%
 fasta                          1    24.4s  5.43%
   fasta.jl                     1    24.4s  5.43%
 regexredux                     1    15.9s  3.53%
   regexredux.jl                1    15.9s  3.53%
 revcomp                        1    9.67s  2.15%
   revcomp.jl                   1    6.81s  1.51%
   revcomp-fast.jl              1    2.86s  0.64%
 spectralnorm                   1    5.43s  1.21%
   spectralnorm.jl              1    4.04s  0.90%
   spectralnorm-fast.jl         1    1.39s  0.31%
 pidigits                       1    332ms  0.07%
   pidigits.jl                  1    332ms  0.07%
 ────────────────────────────────────────────────
 ```
