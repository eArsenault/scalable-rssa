#=
(i) This code contains the Bellman operators to be used in value_iteration.jl.
(ii) All functions must have the same signature.
=#

function bellman_test(J, pars)
    #to start, we define a collection of ranges over X for our grid

    return J .+ 1.0
end

dimS = 4
size_C = 125
J = zeros((5,5,5,5))
Xlim = hcat([0.0, 10.0], [0.0, 10.0], [0.0, 10.0])
Ulim = hcat([0.0, 1.0], [0.0, 1.0], [0.0, 1.0])
Zlim = [0.0, 5.0]

#generate memory-efficient representation of X
#we'll use this in linear interpolation
X = [[collect(range(Xlim[1,i], Xlim[2,i], 5)) for i=1:(dimS - 1)];
     [collect(range(Zlim[1], Zlim[2], 5))]]

#iterate over indices of J
for i in CartesianIndices(J)
    #convert index into corresponding x-value
    coords = Tuple(i)
    xval = [X[i][coords[i]] for i=1:dimS]
end

dimC = size(Ulim)[2]
subdimC = round(Int, size_C ^ (1/dimC))
println(dimC, subdimC)

#generate memory-efficient representation of C
C = [collect(range(Ulim[1,i], Ulim[2,i], subdimC)) for i=1:dimC]

#iterate over C
for ind_C in collect(Iterators.product([1:subdimC for i=1:dimC]...))
    uval = [C[i][ind_C[i]] for i=1:dimC]
    println(uval)
end