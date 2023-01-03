include("../../ReadWrite.jl")

filepath = joinpath.("ComputationalResults/MIP/results/4thread/", readdir("ComputationalResults/MIP/results/4thread/"))

outFile = open("ComputationalResults/MIP/table_comparison", "w")
N = 4

base_obj = 0
base_scope = 0
base_spread = 0
base_count = 0
ext_obj = 0
ext_scope = 0
ext_spread = 0
ext_count = 0

for file in filepath
    f = open(file)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    readline(f)
    obj = round(parse.(Float64, readline(f)),sigdigits=N)
    readline(f)
    readline(f)
    objective = parse.(Float64, split(readline(f)," "))
    close(f)

    name, type = rsplit(split(file, "/")[5], "_", limit = 2)
    data = readInstance("dataset/test/"*name*".txt")
    scope = round(data.lambda * objective[1], sigdigits=N)
    spread = round((1-data.lambda) * (objective[2] + objective[3]), sigdigits=N)

    if type[1] == 'b'
        base_scope += scope
        base_spread += spread 
        base_obj += obj
        base_count += 1
        write(outFile, "\$" * string(\) * "texttt{")
        write(outFile, replace(name, "_" => "\\_") * "} \$")
        write(outFile, " & ")
        write(outFile, join(scope," "))
        write(outFile, " & ")
        write(outFile, join(spread," "))
        write(outFile, " & ")
        write(outFile, join(obj," "))
        write(outFile, " & ")
    else
        ext_scope += scope
        ext_spread += spread 
        ext_obj += obj
        ext_count += 1
        write(outFile, join(scope," "))
        write(outFile, " & ")
        write(outFile, join(spread," "))
        write(outFile, " & ")
        write(outFile, join(obj," "))
        write(outFile, "\\\\")
        write(outFile, "\n")
    end 
end
write(outFile, "\\midrule \n")
write(outFile, "Averages & ")
write(outFile, join(round(base_scope/base_count, sigdigits=N), " "))
write(outFile, " & ")
write(outFile, join(round(base_spread/base_count, sigdigits=N), " "))
write(outFile, " & ")
write(outFile, join(round(base_obj/base_count, sigdigits=N), " "))
write(outFile, " & ")
write(outFile, join(round(ext_scope/ext_count, sigdigits=N), " "))
write(outFile, " & ")
write(outFile, join(round(ext_spread/ext_count, sigdigits=N), " "))
write(outFile, " & ")
write(outFile, join(round(ext_obj/ext_count, sigdigits=N), " "))
write(outFile, "\\\\")
write(outFile, "\n")

close(outFile)
