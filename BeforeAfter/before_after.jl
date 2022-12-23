include("../ReadWrite.jl")
include("../ConstructionHeuristics.jl")
include("../ALNS.jl")
include("../Validation/PlotSolution.jl")

data = readInstance("dataset/train/25_0_0.txt")
sol1 = randomInitial(data)
sol1, params = ALNS(data, sol1, 60, "extended")

# Vertical removal
sol = deepcopy(sol1)
drawHeatmap(data, sol, "BeforeAfter/before_vertical")
verticalDestroy!(data, sol, 0.4)
drawHeatmap(data, sol, "BeforeAfter/after_vertical")


# drawTVSchedule(data, sol, "before", 1)
# drawTVSchedule(data, sol, "after", 1)
