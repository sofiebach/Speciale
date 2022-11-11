include("ReadWrite.jl")
include("MIPModel.jl")
include("../HeuristicFunctions.jl")


data = read_DR_data(37)

x = MIPBaseline(data, 60, 0, 1)
sol1 = MIPtoSol(data, x)



