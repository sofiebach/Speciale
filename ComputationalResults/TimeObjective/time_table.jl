include("../../ReadWrite.jl")

using PyCall

py"""
import matplotlib.pyplot as plt 
def timeplot(time_limits, MIPobjs, ALNSobjs, title, filename):
    plt.figure()
    plt.plot(time_limits, MIPobjs,'o',color='tab:blue',markersize = 6)
    plt.plot(time_limits, ALNSobjs,'o',color='darkorange',markersize = 6)
    plt.plot(time_limits, MIPobjs,'-',color='tab:blue')
    plt.plot(time_limits, ALNSobjs,'-',color='darkorange')
    plt.xlabel("Time (s)",fontsize="15")
    plt.ylabel("Objective value",fontsize="15")
    plt.title(title, fontsize="15")
    plt.tick_params(axis='x', labelsize=15)
    plt.tick_params(axis='y', labelsize=15)
    plt.legend(["Solver", "ALNS"], fontsize="15")
    plt.show()
    #plt.savefig(filename)
    plt.close()
"""

folder = "ComputationalResults/TimeObjective/results/"
filepath = joinpath.(folder, readdir(folder))

MIP_table = open("ComputationalResults/TimeObjective/MIP_table", "w")
ALNS_table = open("ComputationalResults/TimeObjective/ALNS_table", "w")

write(MIP_table, "& \\multicolumn{6}{c}{\\textbf{Time (s)}} \\\\ \n")
write(ALNS_table, "& \\multicolumn{6}{c}{\\textbf{Time (s)}} \\\\ \n")

counter = 0
sum_objs_MIP = zeros(Float64, 6)
sum_objs_ALNS = zeros(Float64, 6)
for file in filepath 
    counter += 1
    name = split(file, "/")[end]
    f = open(file)
    readline(f)
    time_limits = parse.(Int64,split(readline(f)))
    if counter == 1
        write(MIP_table, "Instance & "*join(time_limits, " & ")*"\\\\ \n")
        write(MIP_table, "\\midrule \n")
        write(ALNS_table, "Instance & "*join(time_limits, " & ")*"\\\\ \n")
        write(ALNS_table, "\\midrule \n")
    end
    readline(f)
    MIP_objs = parse.(Float64,split(readline(f)))
    readline(f)
    ALNS_avg_objs = parse.(Float64,split(readline(f)))
    close(f)

    sum_objs_MIP += MIP_objs
    sum_objs_ALNS += ALNS_avg_objs

    write(MIP_table, "\\texttt{"*replace(name, "_" => "\\_")*"} & "*join(MIP_objs, " & "))
    write(MIP_table, "\\\\ \n")
    write(ALNS_table, "\\texttt{"*replace(name, "_" => "\\_")*"} & "*join(ALNS_avg_objs, " & "))
    write(ALNS_table, "\\\\ \n")

    if counter % 3 == 0
        title = split(name, "_")[1] * "-instances"
        avg_objs_MIP = round.(sum_objs_MIP/3, digits=2)
        avg_objs_ALNS = round.(sum_objs_ALNS/3, digits=2)
        py"timeplot"(time_limits, avg_objs_MIP, avg_objs_ALNS, title, title*".pdf")
        write(MIP_table, "\\midrule \n")
        write(MIP_table, "Average & "*join(avg_objs_MIP, " & ")*"\\\\ \n")
        write(MIP_table, "\\midrule \n")
        write(ALNS_table, "\\midrule \n")
        write(ALNS_table, "Average & "*join(avg_objs_ALNS, " & ")*"\\\\ \n")
        write(ALNS_table, "\\midrule \n")
        sum_objs_MIP = zeros(Float64, length(time_limits))
        sum_objs_ALNS = zeros(Float64, length(time_limits))
    end
end
close(MIP_table)
close(ALNS_table)

