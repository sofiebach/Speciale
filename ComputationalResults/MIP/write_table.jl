include("../../ReadWrite.jl")

filepath = joinpath.("ComputationalResults/MIP/results/", readdir("ComputationalResults/MIP/results/"))

outFilebase4 = open("ComputationalResults/MIP/table_base4", "w")
outFileext4 = open("ComputationalResults/MIP/table_ext4", "w")
outFilebase1 = open("ComputationalResults/MIP/table_base1", "w")
outFileext1 = open("ComputationalResults/MIP/table_ext1", "w")

N = 4
for file in filepath
    f = open(file)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    baseline = parse.(Float64, readline(f))
    readline(f)
    readline(f)
    extended = parse.(Float64, readline(f))
    dummy_lines = 1
    while dummy_lines < (8 + 37 + 11 + 5 + 2 + 4 + 37 + 14 + 4)
        readline(f)
        dummy_lines += 1
    end
    gap = parse.(Float64, readline(f))
    readline(f)
    readline(f)
    time = parse.(Float64, readline(f))
    
    nameandtype = rsplit(split(file, "/")[4], "_", limit = 2)
    if nameandtype[2][1] == 'b'
        if nameandtype[2][9] == '1'
            write(outFilebase1, "\$" * string(\) * "texttt{")
            write(outFilebase1, replace(nameandtype[1], "_" => "\\_") * "} \$")
            write(outFilebase1, " & ")
            write(outFilebase1, join(round(baseline, sigdigits = N)," "))
            write(outFilebase1, " &  ")
            write(outFilebase1, join(round(gap*100, sigdigits = N)," "))
            write(outFilebase1, " &  ")
            write(outFilebase1, join(round(time, sigdigits = N)," "))
            write(outFilebase1, "\n")
        else
            write(outFilebase4, " &  ")
            write(outFilebase4, join(round(baseline, sigdigits = N)," "))
            write(outFilebase4, " &  ")
            write(outFilebase4, join(round(gap*100, sigdigits = N)," "))
            write(outFilebase4, " &  ")
            write(outFilebase4, join(round(time, sigdigits = N)," "))
            write(outFilebase4, "\\\\")
            write(outFilebase4, "\n")
        end
    else
        if nameandtype[2][9] == '1'
            write(outFileext1, "\$" * string(\) * "texttt{")
            write(outFileext1, replace(nameandtype[1], "_" => "\\_") * "} \$")
            write(outFileext1, " & ")
            write(outFileext1, join(round(extended, sigdigits = N)," "))
            write(outFileext1, " &  ")
            write(outFileext1, join(round(gap*100, sigdigits = N)," "))
            write(outFileext1, " &  ")
            write(outFileext1, join(round(time, sigdigits = N)," "))
            write(outFileext1, "\n")
        else
            write(outFileext4, " & ")
            write(outFileext4, join(round(extended, sigdigits = N)," "))
            write(outFileext4, " &  ")
            write(outFileext4, join(round(gap*100, sigdigits = N)," "))
            write(outFileext4, " &  ")
            write(outFileext4, join(round(time, sigdigits = N)," "))
            write(outFileext4, "\\\\")
            write(outFileext4, "\n")
        end
    end
end
close(outFilebase1)
close(outFileext1)
close(outFilebase4)
close(outFileext4)
