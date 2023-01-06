include("../../ReadWrite.jl")
include("../../ALNS.jl")

configs = ["config1","config2","config3","config4","config5","config6","config7"]
stddigit = 2
impdigit = 4
outFile = open("Experiments/DestroyRepair/table_config", "w")

for config in configs 
    folder = "Experiments/DestroyRepair/results/"*config
    filepath = joinpath.(folder, readdir(folder))
    imps = 0
    stds = 0
    count = 0
    for file in filepath
        f = open(file)
        readline(f) # imp
        imps += parse.(Float64, readline(f))
        readline(f) # blank
        readline(f) # std
        stds += parse.(Float64, readline(f))
        count += 1
    end
    write(outFile, join(round(imps/count, sigdigits=impdigit)))
    write(outFile, " ")
    write(outFile, join(round(stds/count, sigdigits=stddigit)))
    write(outFile, " ")
end

close(outFile)
