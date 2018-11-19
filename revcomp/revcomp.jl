# The Computer Language Benchmarks Game
# https://salsa.debian.org/benchmarksgame-team/benchmarksgame/
#
# contributed by David Campbell
# modified by Jarret Revels, Kristoffer Carlsson, Alex Arslan

const revcompdata = Dict(
   'A'=> 'T', 'a'=> 'T',
   'C'=> 'G', 'c'=> 'G',
   'G'=> 'C', 'g'=> 'C',
   'T'=> 'A', 't'=> 'A',
   'U'=> 'A', 'u'=> 'A',
   'M'=> 'K', 'm'=> 'K',
   'R'=> 'Y', 'r'=> 'Y',
   'W'=> 'W', 'w'=> 'W',
   'S'=> 'S', 's'=> 'S',
   'Y'=> 'R', 'y'=> 'R',
   'K'=> 'M', 'k'=> 'M',
   'V'=> 'B', 'v'=> 'B',
   'H'=> 'D', 'h'=> 'D',
   'D'=> 'H', 'd'=> 'H',
   'B'=> 'V', 'b'=> 'V',
   'N'=> 'N', 'n'=> 'N',
)

function print_buff(b)
    br = reverse(b)
    l = length(br)
    for i = 1:60:l
        if i+59 > l
            write(br[i:end]); println()
        else
            write(br[i:i+59]); println()
        end
    end
end

function perf_revcomp()
    buff = UInt8[]
    while true
        line = codeunits(readline())
        if isempty(line)
            print_buff(buff)
            return
        elseif line[1] == UInt8('>')
            print_buff(buff)
            buff = UInt8[]
            write(line)
        else
            l = length(line)-1
            let line = line # Workaround for julia#15276
                append!(buff, [UInt8(revcompdata[Char(line[i])]) for i=1:l])
            end
        end
    end
end

perf_revcomp()

