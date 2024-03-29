include("../ReadWrite.jl")
include("../ALNS.jl")
include("DR_output.jl")

data = readInstance("DR_stuff/DRcapacitiesData.txt")

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

for i = 1:10

    sol = randomInitial(data)
    timelimit = 30*60

    sol = randomInitial(data)
    sol, params = ALNS_final(data, sol, timelimit, "extended", [false, false, false, true, true, false, false],[false, true, true, false, false, true])

    writeSolution("DR_stuff/ALNS_sol_" * string(i), data, sol)
    writeParameters("DR_stuff/ALNS_params_" * string(i), params)
end