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