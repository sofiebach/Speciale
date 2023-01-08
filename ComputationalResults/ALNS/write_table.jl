include("../../ReadWrite.jl")

config = "config5"

filepath = joinpath.("ComputationalResults/ALNS/results/"*config * "/", readdir("ComputationalResults/ALNS/results/"*config * "/"))

for file in filepath
    instance = split(file, "/")[5]
    filepath2 = joinpath.("ComputationalResults/ALNS/results/"*config * "/" * instance * "/", readdir("ComputationalResults/ALNS/results/"*config * "/"* instance * "/"))

    best_obj = 1000
    best_i = 0
    objs = []
    times = []
    idx = 0

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
            obj = parse.(Float64, readline(f))
            append!(objs, obj)
            if obj < best_obj
                best_obj = obj
                best_i = idx
            end
        else
            append!(times, readParameters(file2).new_best_time)
        end
    end


    out = open("ComputationalResults/ALNS/" * config * "/table_" * instance, "w")
    write(out, instance)
    write(out, "\n")
    write(out, join(best_obj, " "))
    write(out, "\n")
    write(out, join(readParameters(filepath2[best_i-20]).new_best_time), " ")
    write(out, "\n")
    write(out, join(mean(objs)), " ")
    write(out, "\n")
    write(out, join(std(objs)), " ")
    write(out, "\n")
    write(out, join(mean(times)), " ")
    write(out, "\n")
    write(out, join(std(times)), " ")
    write(out, "\n")

    close(out)
end

filepath = joinpath.("ComputationalResults/ALNS/"*config * "/", readdir("ComputationalResults/ALNS/"*config * "/"))

out = open("ComputationalResults/ALNS/" * config * "_table", "w")
N = 4
for file in filepath
    f = open(file)
    name = readline(f)
    best = parse.(Float64, readline(f))
    best_time = parse.(Float64, readline(f))
    avg_obj = parse.(Float64, readline(f))
    std_obj = parse.(Float64, readline(f))
    avg_time = parse.(Float64, readline(f))
    std_time = parse.(Float64, readline(f))

    write(out, "\$" * string(\) * "texttt{")
    write(out, replace(name, "_" => "\\_") * "} \$")
    write(out, " &  ")
    write(out, join(round(best, sigdigits = N)," "))
    write(out, " &  ")
    write(out, join(Int64(round(best_time, digits = 0)), " "))
    write(out, " &  ")
    write(out, " &  ")
    write(out, join(round(avg_obj, sigdigits = N)," "))
    write(out, " &  ")
    write(out, join(round(std_obj, sigdigits = N)," "))
    write(out, " &  ")
    write(out, join(Int64(round(avg_time, digits = 0)), " "))
    write(out, " &  ")
    write(out, join(round(std_time, sigdigits = N)," "))
    write(out, " \\\\  \n")
end

close(out)