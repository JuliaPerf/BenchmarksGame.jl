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
 knucleotide                    1     167s  44.5%
   knucleotide.jl               1     151s  40.2%
   knucleotide-fast.jl          1    16.0s  4.26%
 binarytrees                    1    46.6s  12.4%
   binarytrees.jl               1    43.5s  11.6%
   binarytree-fast.jl           1    3.01s  0.80%
 fannkuchredux                  1    42.1s  11.2%
   fannkuchredux.jl             1    33.1s  8.81%
   fannkuchredux-fast.jl        1    8.99s  2.39%
 fasta                          1    30.5s  8.12%
   fasta.jl                     1    24.4s  6.50%
   fasta-fast.jl                1    6.07s  1.62%
 mandelbrot                     1    28.6s  7.63%
   mandelbrot.jl                1    26.5s  7.06%
   mandelbrot-fast.jl           1    2.12s  0.57%
 nbody                          1    28.0s  7.44%
   nbody-2.jl                   1    18.3s  4.88%
   nbody.jl                     1    5.69s  1.52%
   nbody-fast.jl                1    3.92s  1.05%
 regexredux                     1    16.1s  4.28%
   regexredux.jl                1    16.1s  4.28%
 revcomp                        1    9.80s  2.61%
   revcomp.jl                   1    6.99s  1.86%
   revcomp-fast.jl              1    2.81s  0.75%
 spectralnorm                   1    5.11s  1.36%
   spectralnorm.jl              1    4.06s  1.08%
   spectralnorm-fast.jl         1    1.05s  0.28%
 pidigits                       1    1.60s  0.43%
   pidigits.jl                  1    1.60s  0.43%
 ```
