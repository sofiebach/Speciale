include("../../ReadWrite.jl")
include("../../ALNS.jl")

idx = parse(Int64, ENV["LSB_JOBINDEX"])

filepath = joinpath.("dataset/test/", readdir("dataset/test/"))[idx]
filename = split(split(filepath, ".")[1],"/")[3]

data = readInstance(filepath)

digit = 2
N = 20
time_limits = [10, 30, 60, 120, 300, 600]
T = length(time_limits)
average_objs = zeros(Float64, T)
mip_objs = zeros(Float64, T)
for i = 1:T
    time_limit = time_limits[i]
    x, gap, solve_time = MIPExtended(data, "Gurobi",1,time_limit,0,1)
    MIPsol = MIPtoSol(data, x)
    mip_objs[i] = MIPsol.exp_obj
    ALNS_objs = 0
    for n = 1:N 
        start_time = time_ns()
        sol = randomInitial(data)
        remaining_time = time_limit - elapsedTime(start_time)
        if remaining_time > 0
            if data.timeperiod < 30
                sol, params = ALNS_final(data, sol, remaining_time, "extended", [false, false, false, false, true, false, false],[false, false, true, false, false, false])
            else
                sol, params = ALNS_final(data, sol, remaining_time, "extended", [false, false, false, true, true, false, false], [false, true, true, false, false, true])
            end
        end
        ALNS_objs += sol.exp_obj
    end
    average_objs[i] = ALNS_objs / N
end
mip_objs = round.(mip_objs, digits=digit)
average_objs = round.(average_objs, digits=digit)

folder = "ComputationalResults/TimeObjective/results/"
outFile = open(folder*filename, "w")
write(outFile, "time limits \n")
write(outFile, join(time_limits, " ")*"\n")
write(outFile, "MIP objs \n")
write(outFile, join(mip_objs, " ")*"\n")
write(outFile, "ALNS objs \n")
write(outFile, join(average_objs, " ")*"\n")
close(outFile)


