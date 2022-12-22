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
        write(outFile, " & ")
        for i = 1:length(objs)
            write(outFile, join(objs[i]," "))
            write(outFile, " & ")
            write(outFile, join(stds[i]," "))
            write(outFile, " & ")
        end
    else
        for i = 1:length(objs)
            write(outFile, join(objs[i]," "))
            write(outFile, " & ")
            write(outFile, join(stds[i]," "))
        end
        write(outFile, "\\\\")
        write(outFile, "\n")
    end

end
close(outFile)
