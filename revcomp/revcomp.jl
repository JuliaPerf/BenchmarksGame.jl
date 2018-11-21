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
    isempty(b) && return
    br = reverse(b)
    l = length(br)
    for i = 1:60:l
        if i+59 > l
            println(String(br[i:end]))
        else
            println(String(br[i:i+59]))
        end
    end
end

function perf_revcomp(io=stdin)
    buff = UInt8[]
    while true
        line = codeunits(readline(io))
        if isempty(line)
            print_buff(buff)
            return
        elseif line[1] == UInt8('>')
            print_buff(buff)
            buff = UInt8[]
            println(String(line))
        else
            l = length(line)
            let line = line # Workaround for julia#15276
                append!(buff, [UInt8(revcompdata[Char(line[i])]) for i=1:l])
            end
        end
    end
end

perf_revcomp()
