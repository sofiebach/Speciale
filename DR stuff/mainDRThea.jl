include("DR_output.jl")
include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../Validation/PlotSolution.jl")

data = readInstance("DR stuff/DRdata.txt")
x = read_DR_solution()
DRsol = Sol(data)

for t = 1:data.T 
    for p = 1:data.P 
        for n = 1:x[t,p]
            insert!(data, DRsol, t, p)
        end
    end
end

drawHeatmap(data,DRsol,"DRheatmap.pdf", 1, true)

used = deepcopy(DRsol.H_cap)

for i = 1:4
    for j = 1:59
        if used[j,i] > 0
            used[j,i] = 0
        end
    end
end

