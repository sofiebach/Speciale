include("../../ReadWrite.jl")

folder = "Experiments/DestroyRepair/results/combinations/"
filepath = joinpath.(folder, readdir(folder))

for file in filepath
    name = split(file,"/")[end]
    type = split(name,"_")[end]
    if type == "sol"
        continue
    end
    f = open(file)
    line = readline(f)
    while line != "destroys"
        lines += 1
        line = readline(f)
    end
    destroys =  parse.(Int64, split(readline(f)," "))
    readline(f)
    readline(f)
    repairs =  parse.(Int64, split(readline(f)," "))
    line = readline(f)
    while line != "status"
        line = readline(f)
    end
    status = parse.(Int64, split(readline(f)," "))
    line = readline(f)
    while line != "destroy names"
        line = readline(f)
    end
    destroy_names = split(readline(f)," ")
    readline(f)
    readline(f)
    repair_names = split(readline(f)," ")
    line = readline(f)
    while line != "W"
        line = readline(f)
    end
    W = parse.(Int64, split(readline(f)," "))
    close(f)

    table = zeros(Int64, length(destroy_names), length(repair_names))
    N = length(status)
    for iter = 1:N
        destroy = destroys[iter]
        repair = repairs[iter]
        table[destroy, repair] += status[iter]
    end
    
    outname = rsplit(name,"_",limit=2)[1]
    outFile = open(folder*outname*"_table", "w")
    write(outFile, "& ")
    write(outFile, join(destroy_names, " & ") * "\\\\ \n")
    for i = 1:length(repair_names)
        write(outFile, repair_names[i]*" & ")
        write(outFile, join(table[:,i], " & ") * "\\\\ \n")
    end

    close(outFile)
end

