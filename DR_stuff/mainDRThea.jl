include("DR_output.jl")
include("../ReadWrite.jl")
include("../BasicFunctions.jl")
include("../Validation/PlotSolution.jl")
include("../Validation/ValidateSolution.jl")

data = readInstance("DR_stuff/DRdata.txt")



#x = read_DR_solution()
#DRsol = Sol(data)
#
#for t = 1:data.T 
#    for p = 1:data.P 
#        for n = 1:x[t,p]
#            insert!(data, DRsol, t, p)
#        end
#    end
#end

sum(data.I[data.start:data.stop,:], dims = 1)
sum(data.H[data.start:data.stop,:], dims = 1)

drawHeatmap(data,DRsol,"DRheatmap.png", 1, true)

data1 = readInstance("DR_stuff/DRcapacitiesdata.txt")

x = read_DR_solution()
DRsol1 = Sol(data1)

for t = 1:data1.T 
    for p = 1:data1.P 
        for n = 1:x[t,p]
            insert!(data1, DRsol1, t, p)
        end
    end
end

sum(data1.I[data1.start:data1.stop,:], dims = 1) .- sum(DRsol1.I_cap[data1.start:data1.stop,:], dims = 1)

sum(data1.H[data1.start:data1.stop,:], dims = 1) - sum(DRsol1.H_cap[data1.start:data1.stop,:], dims = 1)

sum(data1.I) - sum(DRsol1.I_cap)

sum(data.I[data.start:data.stop,:], dims = 1) .- (sum(data1.I[data1.start:data1.stop,:], dims = 1) .- sum(DRsol1.I_cap[data1.start:data1.stop,:], dims = 1))
sum(data.H[data.start:data.stop,:], dims = 1) .- (sum(data1.H[data1.start:data1.stop,:], dims = 1) .- sum(DRsol1.H_cap[data1.start:data1.stop,:], dims = 1))

checkSolution(data1, DRsol)
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


data = readInstance("DR_stuff/DRcapacitiesdata.txt")
sol = readSolution("DR_stuff/ALNS_sol", data)
params = readParameters("DR_stuff/ALNS_params")

drawRadioSchedule(data, sol, "ALNSwithDRcap_radio.pdf", 4)