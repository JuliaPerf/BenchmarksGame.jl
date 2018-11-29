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
 knucleotide                    1     162s  43.9%
   knucleotide.jl               1     151s  41.0%
   knucleotide-fast.jl          1    10.9s  2.94%
 binarytrees                    1    46.5s  12.6%
   binarytrees.jl               1    43.3s  11.7%
   binarytree-fast.jl           1    3.06s  0.83%
 fannkuchredux                  1    41.9s  11.3%
   fannkuchredux.jl             1    33.1s  8.94%
   fannkuchredux-fast.jl        1    8.82s  2.38%
 fasta                          1    30.4s  8.23%
   fasta.jl                     1    24.4s  6.60%
   fasta-fast.jl                1    6.06s  1.64%
 mandelbrot                     1    28.4s  7.68%
   mandelbrot.jl                1    26.3s  7.12%
   mandelbrot-fast.jl           1    2.09s  0.57%
 nbody                          1    27.8s  7.51%
   nbody-2.jl                   1    18.4s  4.97%
   nbody.jl                     1    5.55s  1.50%
   nbody-fast.jl                1    3.84s  1.04%
 regexredux                     1    15.8s  4.27%
   regexredux.jl                1    15.8s  4.27%
 revcomp                        1    9.82s  2.66%
   revcomp.jl                   1    6.98s  1.89%
   revcomp-fast.jl              1    2.84s  0.77%
 spectralnorm                   1    5.20s  1.41%
   spectralnorm.jl              1    4.07s  1.10%
   spectralnorm-fast.jl         1    1.14s  0.31%
 pidigits                       1    1.57s  0.42%
   pidigits.jl                  1    1.57s  0.42%
 ────────────────────────────────────────────────
 ```
