include("ReadWrite.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")
include("Validation/ValidateSolution.jl")
include("MIPModels.jl")

data = readInstance("dataset/test/100_0_0.txt")

sol = randomInitial(data)

params, sol = ALNS_final(data, sol, 120, "extended")

drawTVSchedule(data, sol, "theatest/empty", 1, true)

drawHeatmap(data, sol, "theatest/emptyheat", true)

insert!(data, sol, 11, 1)

drawHeatmap(data, sol, "theatest/insertedheat", true)
drawTVSchedule(data, sol, "theatest/inserted", 1, true)

insert!(data, sol, 11, 1)

drawHeatmap(data, sol, "theatest/inserted2heat", true)
drawTVSchedule(data, sol, "theatest/inserted2", 1, true)

sol = randomInitial(data)
sol, params = ALNS_final_methodinput(data, sol, 60, "extended", [1,1,0,1,0,0,0], [1,1,1,0,0,1])

probabilityTracking(params, "test")

sol1 = readSolution("Experiments/MIP/results/25_0_5_extended", data)

sol2 = readSolution("Experiments/MIP/results/25_0_5_baseline", data)

drawTVSchedule(data, sol1, "extendedDR1", 1, true)
drawTVSchedule(data, sol2, "baselineDR1", 1, true)

drawRadioSchedule(data, sol1, "extendedP4", 7, true)
drawRadioSchedule(data, sol2, "baselineP4", 7, true)


for i in collect(StepRange(6, -1, 1))
    println(i)
end


prio = 15
sol = Sol(data)
insert!(data, sol, data.start, prio)
insert!(data, sol, data.stop, prio)


t, p = bestInsertion(data, sol, prio, "extended")
insert!(data,sol,t,p)
t, p = bestInsertion(data, sol, prio, "extended")
insert!(data,sol,t,p)

drawTVSchedule(data, sol, "best_insersion", 4, true)

sol = Sol(data)
insert!(data, sol, data.start, prio)
insert!(data, sol, data.stop, prio)
t1, t2, p = regretInsertion(data, sol, prio, "extended")
insert!(data,sol,t1,p)
insert!(data,sol,t2,p)

drawTVSchedule(data, sol, "regret_insertion", 4, true)


for p =1:data.P
    sol = Sol(data)
    insert!(data, sol, data.stop, p)
    println(checkSolution(data, sol))
end

sol, params = ALNS(data, sol, 300, "extended")

drawHeatmap(data,sol,"hej1",1)

drawTVSchedule(data, sol, "hej2",1)
drawRadioSchedule(data, sol, "hej")

x = MIPBaseline(data, "Gurobi", 1, 13*60)

sol = randomInitial(data)

randomDestroy!(data, sol, 0.4)
println(sol.exp_obj)
horizontalModelRepair!(data,sol,"extended")
println(sol.exp_obj)


regretRepair!(data,sol,"extended")



time_limit = 60*2 #Seconds




x1 = MIPExtended(data, "Gurobi", 1, time_limit) 

sol1 = MIPtoSol(data,x)
sol2 = MIPtoSol(data, x1)

prefix = "theaplot2/Onlybest_25"
sol, params = ALNS(data, sol, time_limit, "extended")
probabilityTracking(params, prefix * "_probability")
solutionTracking(params, prefix * "_solution")
solutionTracking_all(params, prefix * "_solution_all")
temperatureTracking(params, prefix * "_temp")
drawTVSchedule(data, sol, prefix * "_TVschedule")
drawRadioSchedule(data, sol, prefix * "_Radioschedule")
writeParameters("output/" * prefix * "_parameters", params)

drawHeatmap(sol.I_cap, sol.H_cap, data, sol, prefix * "_heatmap")

writeSolution("output/" * prefix * "_Solution.txt", data, sol)

for p = 1:data.P 
    for t = data.start:data.stop
        if fits(data, sol, t, p)
            println("FITS")
            println(deltaInsert(data, sol, t, p))
            println("t: ", t)
            println("p: ", p)
            insert!(data,sol,t,p)
        end
    end
end

drawRadioSchedule(data, sol, "test")

checkSolution(data, sol)




x = MIPExtended(data, "Gurobi", 1, 60*2)
sol = MIPtoSol(data, x)
checkSolution(data, sol)

drawTVSchedule(data, sol, "MIP_newobj_TV")

drawRadioSchedule(data, sol, "MIP_newobj_Radio")

obj1 = zeros(Float64, data.P)
obj2 = zeros(Float64, data.P)
obj3 = zeros(Float64, data.P)
obj4 = zeros(Float64, data.P)
for p = 1:data.P 
    obj1[p] = data.penalty_S[p]*sol.k[p]
    obj2[p] = sum(data.penalty_g[p] * sol.g[t,p] for t=1:data.T)
    obj3[p] = - data.weight_idle[p] * sol.L[p] + data.weight_idle[p] * sol.y[p]
    obj4[p] = obj1[p] + obj2[p] + obj3[p]
end
















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