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
 knucleotide                    1     170s  45.8%
   knucleotide.jl               1     154s  41.4%   
   knucleotide-fast.jl          1    16.1s  4.33% 
 binarytrees                    1    46.1s  12.4%
   binarytrees.jl               1    43.0s  11.6%   
   binarytree-fast.jl           1    3.03s  0.82%
 fannkuchredux                  1    41.9s  11.3%
   fannkuchredux.jl             1    33.0s  8.88%   
   fannkuchredux-fast.jl        1    8.96s  2.41% 
 mandelbrot                     1    28.4s  7.66%   
   mandelbrot.jl                1    26.4s  7.10%   
   mandelbrot-fast.jl           1    2.08s  0.56%
 nbody                          1    27.7s  7.48%
   nbody-2.jl                   1    18.3s  4.94%
   nbody.jl                     1    5.53s  1.49%   
   nbody-fast.jl                1    3.90s  1.05%
 fasta                          1    24.3s  6.55%
   fasta.jl                     1    24.3s  6.55%
 regexredux                     1    15.7s  4.23%
   regexredux.jl                1    15.7s  4.23%
 revcomp                        1    10.0s  2.69%
   revcomp.jl                   1    7.07s  1.90%
   revcomp-fast.jl              1    2.90s  0.78%
 spectralnorm                   1    5.47s  1.47%
   spectralnorm.jl              1    4.31s  1.16%
   spectralnorm-fast.jl         1    1.16s  0.31%
 pidigits                       1    1.59s  0.43%
   pidigits.jl                  1    1.59s  0.43%
 ```
