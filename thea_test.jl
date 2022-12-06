include("ReadWrite.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/100_0_0.txt")

sol = randomInitial(data)
randomDestroy!(data,sol,0.2)
regretRepair!(data,sol,"expanded")



sol = ExpandedSol(data)
p = 7
insert!(data,sol,data.start, p)
insert!(data,sol,data.stop, p)
regretInsertion(data,sol,[p], "expanded")


stackDestroy!(data,sol,0.3)

clusterDestroy!(data,sol,0.3)

drawTVSchedule(data,sol,"hej")
drawRadioSchedule(data,sol,"hej1")
regretRepair!(data,sol,"expanded")


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
sol, params = ALNS(data,sol,time_limit,"expanded")

probabilityTracking(params,"hej_test")


println(sol.exp_obj)
randomDestroy!(data,sol,0.2)
println(sol.exp_obj)
flexibilityRepair!(data,sol,"expanded")
println(sol.exp_obj)