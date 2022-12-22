include("../../ReadWrite.jl")

folder = "Experiments/DestroyRepair/"
filepath = joinpath.(folder*"results/destroy/", readdir(folder*"results/destroy/"))

outFile = open(folder*"table_destroy1", "w")

for file in filepath
    f = open(file)
    readline(f) # functions
    names = split(readline(f), " ")
    readline(f) # blank
    readline(f) # average imps
    imps = parse.(Float64, split(readline(f)," "))
    readline(f) # blank
    readline(f) # standard deviations
    stds = parse.(Float64, split(readline(f)," "))
    
    write(outFile, "\$" * string(\) * "texttt{")
    write(outFile, replace(split(file,"/")[end], "_" => "\\_") * "} \$")
    for i = 1:length(names)
        write(outFile, " & ")
        write(outFile, join(imps[i]," "))
        write(outFile, " & ")
        write(outFile, join(stds[i]," "))
    end
    write(outFile, "\\\\")
    write(outFile, "\n")
end
close(outFile)
