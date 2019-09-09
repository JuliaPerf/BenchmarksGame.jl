# BenchmarksGame

Repo to optimize the benchmarkrs for the Benchmark game "competition".

Run benchmarks with:

```
julia --project --color=yes run_benchmarks.jl
```

to verify correctness add an argument `verify`

## Results

Running on a quiet machine with the cpu `Intel(R) Core(TM) i5-3470 CPU @ 3.20GHz`:

```
────────────────────────────────────────────────
 Section                   ncalls     time   %tot
 ────────────────────────────────────────────────
 knucleotide                    1     152s  43.3%
   knucleotide.jl               1     142s  40.5%
   knucleotide-fast.jl          1    9.87s  2.81%
 binarytrees                    1    44.1s  12.6%
   binarytrees.jl               1    41.7s  11.9%
   binarytree-fast.jl           1    2.36s  0.67%
 fannkuchredux                  1    36.3s  10.3%
   fannkuchredux.jl             1    29.0s  8.28%
   fannkuchredux-fast.jl        1    7.22s  2.06%
 nbody                          1    30.6s  8.73%
   nbody-2.jl                   1    18.4s  5.24%
   nbody.jl                     1    6.27s  1.79%
   nbody-fast.jl                1    5.96s  1.70%
 fasta                          1    26.4s  7.52%
   fasta.jl                     1    20.4s  5.80%
   fasta-fast.jl                1    6.02s  1.72%
 mandelbrot                     1    26.2s  7.47%
   mandelbrot.jl                1    24.2s  6.91%
   mandelbrot-fast.jl           1    1.95s  0.56%
 regexredux                     1    14.3s  4.06%
   regexredux.jl                1    14.3s  4.06%
 revcomp                        1    9.95s  2.84%
   revcomp.jl                   1    7.80s  2.22%
   revcomp-fast.jl              1    2.15s  0.61%
 spectralnorm                   1    8.36s  2.38%
   spectralnorm.jl              1    5.08s  1.45%
   spectralnorm-fast.jl         1    3.28s  0.93%
 pidigits                       1    2.59s  0.74%
   pidigits.jl                  1    1.53s  0.44%
   pidigits-fast.jl             1    1.06s  0.30%
 ────────────────────────────────────────────────
 ```
