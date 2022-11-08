include("ReadWrite.jl")
include("../Validation/PlotSolution.jl")

data = read_DR_data(37)

solALNS_w = readSolution("results/ALNSExpanded_with_3600_2022-11-07")
paramsALNS_w = readParameters("results/ALNSExpanded_with_3600_2022-11-07_parameters")

solALNS_wo = readSolution("results/ALNSExpanded_without_3600_2022-11-07")
paramsALNS_wo = readParameters("results/ALNSExpanded_without_3600_2022-11-07_parameters")

solMIP = readSolution("results/MIPExpanded_3600_2022-11-07")

solutionTracking(paramsALNS_w, "Expanded_params_ALNS_with")
probabilityTracking(paramsALNS_w, "Expanded_params_ALNS_with_prob")

solutionTracking(paramsALNS_wo, "Expanded_params_ALNS_without")
probabilityTracking(paramsALNS_wo, "Expanded_params_ALNS_without_prob")

drawTVSchedule(data, solALNS_w, "Expanded_TVschedule_ALNS_with")
drawTVSchedule(data, solALNS_wo, "Expanded_TVschedule_ALNS_without")
drawTVSchedule(data, solMIP, "ExpandedTVschedule_MIP")

# Number of campaigns
sum(solALNS_w.x)
sum(solALNS_wo.x)
sum(solMIP.x)

length(paramsALNS_w.status)
length(paramsALNS_wo.status)

println("--- ALNS with model repair ---")
println(paramsALNS_w.repair_names)
println("Repair times: ", paramsALNS_w.time_repair)
avg_time_repair1 = paramsALNS_w.time_repair ./ paramsALNS_w.num_repair
println("Average repair times: ", avg_time_repair1)
println(paramsALNS_w.destroy_names)
avg_time_destroy1 = paramsALNS_w.time_destroy ./ paramsALNS_w.num_destroy
println("Average destroy times: ", avg_time_destroy1)


println("--- ALNS with model repair ---")
println(paramsALNS_wo.repair_names)
println("Repair times: ", paramsALNS_wo.time_repair)
avg_time_repair1 = paramsALNS_wo.time_repair ./ paramsALNS_wo.num_repair
println("Average repair times: ", avg_time_repair1)
println(paramsALNS_wo.destroy_names)
avg_time_destroy1 = paramsALNS_wo.time_destroy ./ paramsALNS_wo.num_destroy
println("Average destroy times: ", avg_time_destroy1)