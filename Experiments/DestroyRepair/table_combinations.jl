include("../../ReadWrite.jl")

folder = "Experiments/DestroyRepair/results/combinations/"
filepath = joinpath.(folder, readdir(folder))
# change if num destroy and repair changes
num_destroys = 6
num_repairs = 7
num_files = 6

sigdigits = 2
total_table = zeros(Float64, num_files, num_destroys, num_repairs) 
destroy_names = 0
repair_names = 0

idx = 0
for file in filepath
    name = split(file,"/")[end]
    type = split(name,"_")[end]
    if type != "params"
        continue
    end
    println(name)
    idx += 1
    f = open(file)
    line = readline(f)
    while line != "destroys"
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

    table = zeros(Float64, length(destroy_names), length(repair_names))
    N = length(status)
    for iter = 1:N
        destroy = destroys[iter]
        repair = repairs[iter]
        table[destroy, repair] += status[iter]
    end
    total_table[idx,:,:] = table ./ sum(status) * 100

    # outname = rsplit(name,"_",limit=2)[1]
    # outFile = open(folder*outname*"_table", "w")
    # write(outFile, "& & \\multicolumn{"*string(length(destroy_names))*"}{c}{Destroys}" * "\\\\ \n")
    # write(outFile, "& ")
    # for i = 1:length(destroy_names)
    #     d = destroy_names[i]
    #     write(outFile, "& ")
    #     write(outFile, d[1:end-8])
    # end
    # write(outFile, "\\\\ \n")
    # write(outFile, "\\cmidrule(r){3-8} \n")
    # #write(outFile, join(destroy_names, " & ") * "\\\\ \n")
    # write(outFile, "\\multirow{"*string(length(repair_names))*"}{*}{\\rotatebox[origin=c]{90}{Repairs}}")
    # for i = 1:length(repair_names)
    #     r = repair_names[i]
    #     write(outFile, "& ")
    #     write(outFile, "\\multicolumn{1}{r|}{")
    #     write(outFile, r[1:end-7]*"} & ")
    #     write(outFile, join(table[:,i], " & ") * "\\\\ \n")
    # end
    # close(outFile)
end
total_table = mean(total_table, dims=1)[1,:,:]

outname = "combinations"
outFile = open(folder*outname*"_table", "w")
write(outFile, "& & \\multicolumn{"*string(length(destroy_names)+1)*"}{c}{\\textbf{Destroys}}" * "\\\\ \n")
write(outFile, "& ")
for i = 1:length(destroy_names)
    d = destroy_names[i]
    write(outFile, "& ")
    write(outFile, d[1:end-8])
end
write(outFile, "& \\textbf{Total} ")
write(outFile, "\\\\ \n")
write(outFile, "\\cline{3-8} \n")
#write(outFile, join(destroy_names, " & ") * "\\\\ \n")
write(outFile, "\\multirow{"*string(length(repair_names)+1)*"}{*}{\\rotatebox[origin=c]{90}{\\textbf{Repairs}}}")
for i = 1:(length(repair_names))
    r = repair_names[i]
    write(outFile, "& ")
    write(outFile, "\\multicolumn{1}{r|}{")
    write(outFile, r[1:end-7]*"} & ")
    write(outFile, join(round.(total_table[:,i], digits=sigdigits), " & "))
    write(outFile, "&" * string(round(sum(total_table[:,i]), digits=sigdigits)))
    write(outFile, "\\\\ \n")
end
write(outFile, "& ")
write(outFile, "\\textbf{Total} & ")
write(outFile, join(round.(sum(total_table, dims=2), digits=sigdigits), " & "))
close(outFile)

sum_destroy = sum(total_table[:,i] for i=1:num_repairs)
sum_repair = sum(total_table[i,:] for i=1:num_destroys)
sorted_destroy = sortperm(-sum_destroy)
sorted_repair = sortperm(-sum_repair)
destroy_names = destroy_names[sorted_destroy]
repair_names = repair_names[sorted_repair]

cumsum_destroy = zeros(Float64, num_destroys+1)
for i = 2:num_destroys+1
    cumsum_destroy[i] = cumsum_destroy[i-1] + sum_destroy[sorted_destroy[i-1]]
end
cumsum_repair = zeros(Float64, num_repairs+1)
for i = 2:num_repairs+1
    cumsum_repair[i] = cumsum_repair[i-1] + sum_repair[sorted_repair[i-1]]
end

using PyCall
py"""
import matplotlib.pyplot as plt
def cumsumplot(cumsum, method, filename):
    fig, ax = plt.subplots()
    fig.set_figheight(7)
    fig.set_figwidth(7)
    #plt.axhline(y = 80, color = 'gray', linestyle = '--', dashes=(5, 5))
    ax.plot(cumsum, '-', linewidth=2, color='tab:blue')
    ax.plot(cumsum, '.', markersize=20, color='tab:blue')
    ax.tick_params(axis='x', labelsize=15)
    ax.tick_params(axis='y', labelsize=15)
    plt.title(method, fontsize="20")
    plt.xlabel("Number of heuristics",fontsize="20")
    plt.ylabel("Contribution (%)",fontsize="20")
    plt.savefig(filename)
    plt.close()
"""
py"cumsumplot"(cumsum_destroy, "Destroy methods", "contribution_destroy.pdf")
py"cumsumplot"(cumsum_repair, "Repair methods", "contribution_repair.pdf")