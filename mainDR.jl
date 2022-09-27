include("DR_output.jl")
include("ReadWrite.jl")
include("PlotSolution.jl")

inventory_check, number_priorities, consumption_check, dr_sol = DR_plan()

data = read_DR_data(37)

inventory_used, staff_used = checkSolution(data, dr_sol)

drawTVSchedule(data, dr_sol, "dr_plan")

drawRadioSchedule(data, dr_sol, "dr_plan")

heatmapStaff(staff_used, data, "dr_plan")

inventory_used = inventory_check ./ data.I[data.start:data.stop,:]
heatmapInventory(inventory_used, data, "dr_plan")


#U = zeros(Float64, data.P, data.C)
#
#for p = 1:data.P 
#    for c = 1:data.C
#        U[p, c] = sum(data.u[:,p,c])
#    end
#end
#
#check = U - consumption[1:data.P,:]
#
## DER ER NOGET GALT MED c=11
#check[:,11] = zeros(Float64, data.P)



