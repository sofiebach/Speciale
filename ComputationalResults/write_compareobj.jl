include("../ReadWrite.jl")

filepath = joinpath.("ComputationalResults/ALNS/results/config1/", readdir("ComputationalResults/ALNS/results/config1/"))


out = open("ComputationalResults/bestobj_table", "w")
lambda = 3/4
N = 4
for file in filepath
    instance = split(file, "/")[5]
    paths = ["ComputationalResults/ALNS/results/config1/" * instance * "/solution_15",
    "ComputationalResults/ALNS/results/config2/" * instance * "/solution_6",
    "ComputationalResults/ALNS/results/config5/" * instance * "/solution_2",
    "ComputationalResults/MIP/results/1thread/" * instance * "_extended1thread"]

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