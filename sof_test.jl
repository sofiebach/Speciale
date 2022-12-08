include("ReadWrite.jl")
include("MIPModels.jl")
include("ConstructionHeuristics.jl")
include("ALNS.jl")
include("Validation/PlotSolution.jl")

data = readInstance("dataset/25_0_0.txt")

sol = randomInitial(data)
println("L: ", sol.L')
println("sum L: ", sum(sol.L))
println(sum(sol.x,dims=1))
println(sol.num_campaigns)
println("Initial objective: ", sol.exp_obj)
worstIdleDestroy!(data, sol, 0.4)
println("Destroy objective: ", sol.exp_obj)

drawRadioSchedule(data, sol, "radio_destroy")
drawTVSchedule(data, sol, "tv_destroy")

regretRepair!(data, sol, "expanded")
println("L: ", sol.L')
println("sum L: ", sum(sol.L))
println(sum(sol.x,dims=1))
println(sol.num_campaigns)
println("Repair objective: ", sol.exp_obj)


total = 0
for p = 1:data.P
    for t = data.start:data.stop
        if fits(data,sol,t,p)
            println("p: ", p, " t: ", t)
            total += 1
        end
    end
end
