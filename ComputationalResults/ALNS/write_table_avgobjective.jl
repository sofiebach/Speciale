include("../../ReadWrite.jl")

config = "config2"

filepath = joinpath.("ComputationalResults/ALNS/results/"*config * "/", readdir("ComputationalResults/ALNS/results/"*config * "/"))

out = open("ComputationalResults/ALNS/avgobjectives", "w")
lambda = 3/4
N = 4
for file in filepath
    instance = split(file, "/")[5]
    filepath2 = joinpath.("ComputationalResults/ALNS/results/"*config * "/" * instance * "/", readdir("ComputationalResults/ALNS/results/"*config * "/"* instance * "/"))

    objectives = []
    idx = 0

    write(out, "\$" * string(\) * "texttt{")
    write(out, replace(instance, "_" => "\\_") * "} \$")

    for file2 in filepath2
        idx += 1
        type = split(file2, "/")[6]
        if type[1] == 's'
            f = open(file2)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            push!(objectives, parse.(Float64,split(readline(f))))
        end
    end
    scope = 0
    dist = 0
    obj = 0
    L = length(objectives)
    for i = 1:L
        scope += objectives[i][1]*lambda
        dist += (objectives[i][2] + objectives[i][3])*(1-lambda)
    end


    write(out, " &  ")
    write(out, join(round(scope/L, sigdigits = N)," "))
    write(out, " &  ")
    write(out, join(round(dist/L, sigdigits = N)," "))
    write(out, " &  ")
    write(out, join(round(scope/L + dist/L, sigdigits = N)," "))

    write(out, " \\\\  \n")
end

close(out)