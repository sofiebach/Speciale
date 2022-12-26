include("../ReadWrite.jl")
include("../ConstructionHeuristics.jl")
include("../ALNS.jl")
include("../Validation/PlotSolution.jl")

data = readInstance("dataset/train/25_0_0.txt")
data.I = 1000*ones(data.T, data.C)
data.H = 1000*ones(data.T, data.M)

sol1 = randomInitial(data)
sol1, params = ALNS(data, sol1, 10, "extended")

frac = 0.3
pdf = true

# Vertical removal
sol = deepcopy(sol1)
drawRadioSchedule(data, sol1, "BeforeAfter/before_vertical", 7, pdf)
verticalDestroy!(data, sol, frac)
drawRadioSchedule(data, sol, "BeforeAfter/after_vertical", 7, pdf)

# Horizontal removal
sol = deepcopy(sol1)
drawTVSchedule(data, sol1, "BeforeAfter/before_horizontal", 1, pdf)
horizontalDestroy!(data, sol, frac)
drawTVSchedule(data, sol, "BeforeAfter/after_horizontal", 1,pdf)

# Stack removal
sol = deepcopy(sol1)
insert!(data, sol, 5, 1)
insert!(data, sol, 5, 1)
insert!(data, sol, 5, 1)
insert!(data, sol, 5, 1)
insert!(data, sol, 9, 5)
insert!(data, sol, 9, 5)
insert!(data, sol, 9, 5)
insert!(data, sol, 9, 5)
frac = 0.1
pdf=true
drawTVSchedule(data, sol, "BeforeAfter/before_stack", 1, pdf)
stackDestroy!(data, sol, frac)
drawTVSchedule(data, sol, "BeforeAfter/after_stack", 1,pdf)
