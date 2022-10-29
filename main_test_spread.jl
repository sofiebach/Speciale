include("ReadWrite.jl")

include("MIPModelSpreading.jl")
include("MetaSpreading/ALNS_expanded.jl")
include("MetaSpreading/ConstructionHeuristics_expanded.jl")
using Dates
P = 37
data = read_DR_data(P)

for n = 1:1000
    sol = randomInitial(data)
end
findObjective(data,sol)

t = 10 
p = 10
println(delta_insert(data,sol,t,p))
insert(data,sol,t,p)
println(findObjective(data,sol))
println(delta_remove(data,sol,t,p))
remove(data,sol,t,p)
println(findObjective(data,sol))

t = 33
p = 1
println(sol.x[t,p])
println(delta_insert(data,sol,t,p))
insert(data,sol,t,p)
println(findObjective(data,sol))
println(sol.x[t,p])

t = 53
p = 8
println(sol.x[t,p])
println(delta_insert(data,sol,t,p))
insert(data,sol,t,p)
println(findObjective(data,sol))
println(sol.x[t,p])

println(delta_remove(data,sol,t,p))
remove(data,sol,t,p)
println(findObjective(data,sol))

t = 33
p = 1

println(delta_remove(data,sol,t,p))
remove(data,sol,t,p)
println(findObjective(data,sol))