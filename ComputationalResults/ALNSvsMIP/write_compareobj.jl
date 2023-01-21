include("../../ReadWrite.jl")

filepath = joinpath.("ComputationalResults/ALNS/results/config3/", readdir("ComputationalResults/ALNS/results/config3/"))



out = open("ComputationalResults/bestobj_table", "w")
lambda = 3/4
N = 4
for file in filepath
    instance = split(file, "/")[5]
    best1 = 0
    best2 = 0

    idx = 1
    best_obj1 = 1000
    filepath2 = joinpath.("ComputationalResults/ALNS/results/config3/" * instance * "/", readdir("ComputationalResults/ALNS/results/config3/" * instance * "/"))
    for file2 in filepath2
        if split(file2, "/")[6][1] == 's'
            f = open(file2)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            ext_obj = parse.(Float64, readline(f))
            readline(f)
            readline(f)
            obj = parse.(Float64,split(readline(f)))

            if best_obj1 > ext_obj
                best_obj1 = ext_obj
                best1 = split(file2, "/")[6]
            end
            idx += 1
        else
            continue
        end
    end

    idx = 1
    best_obj2 = 1000
    filepath2 = joinpath.("ComputationalResults/ALNS/results/config7/" * instance * "/", readdir("ComputationalResults/ALNS/results/config7/" * instance * "/"))
    for file2 in filepath2
        if split(file2, "/")[6][1] == 's'
            f = open(file2)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            readline(f)
            ext_obj = parse.(Float64, readline(f))
            readline(f)
            readline(f)
            obj = parse.(Float64,split(readline(f)))

            if best_obj2 > ext_obj
                best_obj2 = ext_obj
                best2 = split(file2, "/")[6]
            end
            idx += 1
        else
            continue
        end
    end
    println(instance)
    println("best1: ", best1)
    println("obj: ", best_obj1)
    println("best2: ", best2)
    println("obj: ", best_obj2)
    paths = ["ComputationalResults/ALNS/results/config3/" * instance * "/" * string(best1),
    "ComputationalResults/ALNS/results/config7/" * instance * "/" * string(best2),
    "ComputationalResults/MIP/results/" * instance * "_extended1thread"]

    write(out, "\$" * string(\) * "texttt{")
    write(out, replace(instance, "_" => "\\_") * "} \$")
    for file2 in paths
        f = open(file2)
        readline(f)
        readline(f)
        readline(f)
        readline(f)
        readline(f)
        readline(f)
        readline(f)
        ext_obj = parse.(Float64, readline(f))
        readline(f)
        readline(f)
        obj = parse.(Float64,split(readline(f)))
        
        write(out, " &  ")
        write(out, join(round(obj[1]*lambda, sigdigits = N)," "))
        write(out, " &  ")
        write(out, join(round((obj[2] + obj[3])*(1-lambda), sigdigits = N)," "))
        write(out, " &  ")
        write(out, join(round(ext_obj, sigdigits = N)," "))
    end
    write(out, " \\\\  \n")

end
close(out)