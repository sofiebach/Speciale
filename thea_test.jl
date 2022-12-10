include("ReadWrite.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("MIPModels.jl")

data = readInstance("dataset/25_0_0.txt")

x = MIPExtended(data, "Gurobi", 1, 60*5, 0, 0)

sol = MIPtoSol(data, x)

drawRadioSchedule(data, sol, "hej")



















sol = randomInitial(data)

time_limit = 60*3 #Seconds

prefix = "theaplot2/test100"
sol, params = ALNS(data, sol, time_limit, "extended")
probabilityTracking(params, prefix * "_probability")
solutionTracking(params, prefix * "_solution")
solutionTracking_all(params, prefix * "_solution_all")
temperatureTracking(params, prefix * "_temp")
drawTVSchedule(data, sol, prefix * "_TVschedule")
drawRadioSchedule(data, sol, prefix * "_Radioschedule")
writeParameters("output/" * prefix * "_parameters", params)


filename = "_performancetable.txt"
outFile = open("output/" * prefix * filename, "w")
    write(outFile, "Obj baseline\n")
    write(outFile, join(sol.base_obj," ")*"\n\n")
    
    write(outFile, "Obj Exp\n")
    write(outFile, join(sol.exp_obj," ")*"\n\n")

    write(outFile, "Repairs\n")
    for i = 1:length(params.num_repair)
        write(outFile, join(params.w_repair[i,:]," ")*"\n")
    end
    write(outFile, "\n")

    write(outFile, "Destroys\n")
    for i = 1:length(params.num_destroy)
        write(outFile, join(params.w_destroy[i,:]," ")*"\n")
    end
    close(outFile)

plot(params.status[8001:12000])

plot(params.current_obj[8000:9500])

plot(params.prob_repair_it[1,8001:12000])

params.repairs[8530]
params.status[8530]


rho_repair_it = reshape(params.rho_repair_it, length(params.num_repair),:)
rho_repair_it[:,8525:8535]

stackDestroy!(data,sol,0.3)
clusterDestroy!(data,sol,0.3)

drawTVSchedule(data,sol,"hej")
drawRadioSchedule(data,sol,"hej1")
regretRepair!(data,sol,"extended")


p = 16
stop_time1 = 0
stop_time2 = 0
for p = 1:data.P
    for t1 = data.start:data.stop
        if fits(data,sol,t1,p)
            for t2 = data.start:data.stop
                println("--------------")
                start_time1 = time_ns()
                println(fits2times(data,sol,t1,t2,p))
                stop_time1 += elapsedTime(start_time1)
                start_time2 = time_ns()
                println(testfits2(data,sol,t1,t2,p))
                stop_time2 += elapsedTime(start_time2)
                if fits2times(data,sol,t1,t2,p) != testfits2(data,sol,t1,t2,p)
                    println("--------------")
                    println("t1: ", t1, " t2: ", t2)
                end
            end
        end
    end
end
println("Hej")

function testfits2(data,sol,t1,t2,p)
    sol_temp = deepcopy(sol)
    if fits(data,sol,t1,p)
        insert!(data,sol_temp, t1, p)
        return fits(data,sol_temp,t2,p)
    else
        return false
    end
end

data = readInstance("dataset/100_0_0.txt")
sol = randomInitial(data)

time_limit = 60*10
sol, params = ALNS(data,sol,time_limit,"extended")

probabilityTracking(params,"hej_test")


println(sol.exp_obj)
randomDestroy!(data,sol,0.2)
println(sol.exp_obj)
flexibilityRepair!(data,sol,"extended")
println(sol.exp_obj)