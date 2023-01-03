include("../../ReadWrite.jl")

folder = "Experiments/InputSolution/"
filepath = joinpath.(folder*"results/", readdir(folder*"results/"))

outFile = open(folder*"table", "w")

for file in filepath
    f = open(file)
    readline(f) # empty 	 bad 	 good 
    readline(f) # average objectives
    objs = parse.(Float64, split(readline(f)," "))
    readline(f) # blank
    readline(f) # standard deviations
    stds = parse.(Float64, split(readline(f)," "))
    
    nameandtype = rsplit(split(file, "/")[4], "_", limit = 2)
    if nameandtype[2] == "baseline"
        write(outFile, "\$" * string(\) * "texttt{")
        write(outFile, replace(nameandtype[1], "_" => "\\_") * "} \$")
        for i = 1:length(objs)
            write(outFile, " & ")
            write(outFile, join(round(objs[i],sigdigits = 4)," "))
            write(outFile, " & ")
            write(outFile, join(round(stds[i], sigdigits = 2)," "))
        end
    else
        for i = 1:length(objs)
            write(outFile, " & ")
            write(outFile, join(round(objs[i], sigdigits = 4)," "))
            write(outFile, " & ")
            write(outFile, join(round(stds[i], sigdigits = 2)," "))
        end
        write(outFile, "\\\\")
        write(outFile, "\n")
    end

end
close(outFile)
