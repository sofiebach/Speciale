include("DR_output.jl")
include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../Validation/PlotSolution.jl")

data = readInstance("DR_stuff/DRcapacitiesdata.txt")

x = read_DR_solution()
DRsol = Sol(data)
for t = 1:data.T 
    for p = 1:data.P 
        for n = 1:x[t,p]
            insert!(data, DRsol, t, p)
        end
    end
end

ALNSsol = readSolution("DR_stuff/ALNS_sol", data)

drawHeatmap(data, DRsol, "new_DR_heatmap.pdf")
drawHeatmap(data, ALNSsol, "new_ALNS_heatmap.pdf")
