include("../../ReadWrite.jl")
include("../../ALNS.jl")

method = "repair"
# methods = [horizontalDestroy!,verticalDestroy!,randomDestroy!,similarityDestroy!,worstIdleDestroy!,concurrentDestroy!]
methods = [greedyRepair!, firstRepair!,flexibilityRepair!,bestRepair!,horizontalModelRepair!,regretRepair!,modelRepair!]
   
folder = "Experiments/DestroyRepair/results/"*method*"/"
filepath = joinpath.(folder, readdir(folder))

stddigit = 2
impdigit = 4

stds = zeros(Float64, length(filepath), length(methods)+1)
imps = zeros(Float64, length(filepath), length(methods)+1)

outFile = open("Experiments/DestroyRepair/table_"*method, "w")
write(outFile, "Without & Avg. imp. (\\%) & Std. \\\\ \n")
write(outFile, "\\midrule \n")

index = 0
for file in filepath
    index += 1
    f = open(file)
    readline(f) # average imps
    imp = parse.(Float64, split(readline(f)," "))
    readline(f) # blank
    readline(f) # standard deviations
    st = parse.(Float64, split(readline(f)," "))
    stds[index, :] = st
    imps[index, :] = imp
end

for i = 1:size(stds)[2]
    if i > 1
        write(outFile, string(methods[i-1]) * " & ")
    else
        write(outFile, "Nothing & ")
    end
    write(outFile, join(round.(mean(imps[:,i]), sigdigits=impdigit)," "))
    write(outFile, " & ")
    write(outFile, join(round.(mean(stds[:,i]), sigdigits=stddigit)," "))
    write(outFile, " \\\\ \n")
end

close(outFile)
