include("DR_output.jl")
include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../Validation/PlotSolution.jl")

data = readInstance("DR_stuff/DRdata.txt")
x = read_DR_solution()
DRsol = Sol(data)

for t = 1:data.T 
    for p = 1:data.P 
        for n = 1:x[t,p]
            insert!(data, DRsol, t, p)
        end
    end
end

drawHeatmap(data,DRsol,"DRheatmap.png", 1, true)

data1 = readInstance("DR_stuff/DRcapacitiesdata.txt")

x = read_DR_solution()
DRsol = Sol(data1)

for t = 1:data1.T 
    for p = 1:data1.P 
        for n = 1:x[t,p]
            insert!(data1, DRsol, t, p)
        end
    end
end

drawHeatmap(data1,DRsol,"DRCapacitiesheatmap3.png", 1, true)



data = readInstance("DR_stuff/DRcapacitiesdata.txt")


used = deepcopy(DRsol.H_cap)

for i = 1:4
    for j = 1:59
        if used[j,i] > 0
            used[j,i] = 0
        end
    end
end

