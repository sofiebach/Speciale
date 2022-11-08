include("ReadWrite.jl")
include("MIPModel.jl")
include("HeuristicFunctions.jl")

data = read_DR_data(37)

sol1 = MIPBaseline(data, 60, 0, 1)

sol2 = ExpandedSol(data)
for t = 1:data.T, p = 1:data.P
    for n = 1:sol1.x[t,p]
        insert!(data, sol2, t, p)
    end
end

println(sol1.obj)
println(sol2.obj)

println(sol1.num_campaigns)
println(sol2.num_campaigns)

println(sum(sol1.f))
println(sum(sol2.f))
println(sum(sol1.f .- sol2.f))

println(sum(sol1.k))
println(sum(sol2.k))
println(sum(sol1.k .- sol2.k))

println(sum(sol1.g))
println(sum(sol2.g))



