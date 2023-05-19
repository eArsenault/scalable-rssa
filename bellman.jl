using Interpolations
#=
(i) This code contains the Bellman operators to be used in value_iteration.jl.
(ii) All functions must have the same signature.
(iii) pars gives the setup for the data structures used, scenario_code defines the environment via scenarios.jl
=#

#used in value_iteration.jl for testing
function bellman_test(J, scenario_code, pars)
    return J .+ 1.0
end

function bellman_exact(J, scenario_code, pars)
    #read data from pars
    (Xl, Ul, Zl) = (pars["Xlim"], pars["Ulim"], pars["Zlim"])
    dimS = size(Xl)[2] + 1 #plus one for dimension Z
    dimC = size(Ul)[2]
    subdimC = round(Int, pars["size_C"] ^ (1/dimC)) #how many interpolants for each dimension of C

    #generate memory-efficient representation of X, C
    #we'll use this in linear interpolation
    nJ = size(J) #number of grid points along each dim
    X = [[collect(range(Xl[1,i], Xl[2,i], nJ[i])) for i=1:(dimS - 1)]; [collect(range(Zl[1], Zl[2], nJ[dimS]))]]
    C = [collect(range(Ul[1,i], Ul[2,i], subdimC)) for i=1:dimC] 
    
    #get the environment function
    #exp_code tells us whether the environment also returns the noise distribution (can make expectation faster)
    #=
    (environment, exp_code) = get_environment(scenario_code)
    if exp_code == 0
        itp = interpolate(X, J, Gridded(Linear()));
    end
    =#

    #iterator for C
    inds_C = collect(Iterators.product([1:subdimC for i=1:dimC]...))
    
    #iterate over S (equivalently, indices of J)
    for xc in CartesianIndices(J)
        #convert index into corresponding x-value
        coords = Tuple(xc)
        x = [X[i][coords[i]] for i=1:dimS]
        min_u = Zl[2] #Zl[2] = \bar{c}, maximum cost value

        #iterate over C
        for ind_C in inds_C
            u = [C[i][ind_C[i]] for i=1:dimC]

            #=
            #compute expected value
            if exp_code == 0
                #get samples, interpolate on J, take sample mean
            else
                #get samples + distribution, take inner product
            end
            =#
            val = 1
            min_u = min(val, min_u)
        end

        J[xc] = J[xc] + min_u #for now - this should return same value as the test
    end

    return J
end
