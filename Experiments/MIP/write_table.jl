include("../../ReadWrite.jl")

filepath = joinpath.("Experiments/MIP/results/", readdir("Experiments/MIP/results/"))

outFilebase = open("Experiments/MIP/table_base", "w")
outFileext = open("Experiments/MIP/table_ext", "w")

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
    if nameandtype[2] == "baseline"
        write(outFilebase, "\$" * string(\) * "texttt{")
        write(outFilebase, replace(nameandtype[1], "_" => "\\_") * "} \$")
        write(outFilebase, " & ")
        write(outFilebase, join(baseline," "))
        write(outFilebase, " &  ")
        write(outFilebase, join(gap," "))
        write(outFilebase, " &  ")
        write(outFilebase, join(time," "))
        write(outFilebase, "\\\\")
        write(outFilebase, "\n")
    else
        write(outFileext, "\$" * string(\) * "texttt{")
        write(outFileext, replace(nameandtype[1], "_" => "\\_") * "} \$")
        write(outFileext, " & ")
        write(outFileext, join(extended," "))
        write(outFileext, " &  ")
        write(outFileext, join(gap," "))
        write(outFileext, " &  ")
        write(outFileext, join(time," "))
        write(outFileext, "\\\\")
        write(outFileext, "\n")
    end

end
close(outFilebase)
close(outFileext)
