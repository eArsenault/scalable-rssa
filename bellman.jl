using Interpolations, LinearAlgebra, LinearSolve
include("scenarios.jl")
#=
(i) This code contains the Bellman operators to be used in value_iteration.jl.
(ii) All functions must have the same signature.
(iii) pars gives the setup for the data structures used, scenario_code defines the environment via scenarios.jl
=#

#Must finish approximate Bellman operator#

function kernel(x1, x2)
    sgm = 1
    return exp(-sum(abs.(x1 - x2).^2)/(2*sgm^2))
end

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
    m = pars["m"]

    #generate a linear interpolator object on X using values in J
    nJ = size(J) #number of grid points along each dim
    X = [[collect(range(Xl[1,i], Xl[2,i], nJ[i])) for i=1:(dimS - 1)]; [collect(range(Zl[1], Zl[2], nJ[dimS]))]]
    itp = interpolate(tuple(X...), J, Gridded(Linear()));

    #generate memory-efficient representation of C, iterator for C
    C = [collect(range(Ul[1,i], Ul[2,i], subdimC)) for i=1:dimC] 
    inds_C = collect(Iterators.product([1:subdimC for i=1:dimC]...))

    #get the environment function
    #exp_code tells us whether the environment also returns the noise distribution (to make expectation faster)
    (environment, exp_code) = get_environment(scenario_code)
    (w, pmf) = get_pmf(scenario_code)
    
    #iterate over S (equivalently, indices of J)
    for xc in CartesianIndices(J)
        #convert index into corresponding x-value
        coords = Tuple(xc)
        x = [X[i][coords[i]] for i=1:dimS]
        min_u = Zl[2] #Zl[2] = \bar{c}, maximum cost value

        #iterate over C
        for ind_C in inds_C
            u = [C[i][ind_C[i]] for i=1:dimC]

            #compute expected value using...
            if exp_code == 1
                #sample average!
                xp = environment(x,u,w,m)
                val = sum(map(v -> itp(v...), xp)) / length(xp)
            elseif exp_code == 0
                #inner product with pmf!
                xp = environment(x,u,w,0)
                val = dot(map(v -> itp(v...), xp), pmf)
            else 
                #test values!
                val = 1
            end
            
            #keep a running minimum over C
            min_u = min(val, min_u)
        end

        J[xc] = min_u
    end

    return J
end

function bellman_approximate(J, scenario_code, pars)
    #read data from pars
    (Xl, Ul, Zl) = (pars["Xlim"], pars["Ulim"], pars["Zlim"])
    n, m = (pars["n"], pars["m"])
    dimS = size(Xl)[2] + 1 #plus one for dimension Z
    dimC = size(Ul)[2]
    subdimC = round(Int, pars["size_C"] ^ (1/dimC)) #how many interpolants for each dimension of C

    #generate a linear interpolator object on X using values in J
    nJ = size(J) #number of grid points along each dim
    X = [[collect(range(Xl[1,i], Xl[2,i], nJ[i])) for i=1:(dimS - 1)]; [collect(range(Zl[1], Zl[2], nJ[dimS]))]]
    itp = interpolate(X, J, Gridded(Linear()));

    #generate memory-efficient representation of C, iterator for C
    C = [collect(range(Ul[1,i], Ul[2,i], subdimC)) for i=1:dimC] 
    inds_C = collect(Iterators.product([1:subdimC for i=1:dimC]...))

    #get the environment function
    #exp_code tells us whether the environment also returns the noise distribution (to make expectation faster)
    (environment, exp_code) = get_environment(scenario_code)
    (w, pmf) = get_pmf(scenario_code)
    
    #draw samples from X
    #get dimS uniform values between 0 and 1, then scale appropriately - returns a dimS x n matrix
    al = hcat(Xl, Zl)
    x_mu = rand(Float64, (dimS, n)) .* (al[2,:] - al[1,:]) .+ al[1,:] 

    #compute regressor y
    y = zeros(n)
    for i = 1:n
        x = x_mu[:,i]

        #convert index into corresponding x-value
        coords = Tuple(xc)
        x = [X[i][coords[i]] for i=1:dimS]
        min_u = Zl[2] #Zl[2] = \bar{c}, maximum cost value

        #iterate over C
        for ind_C in inds_C
            u = [C[i][ind_C[i]] for i=1:dimC]

            xp = environment(x,u,w)
            val = sum(map(v -> itp(v...), xp)) / length(xp) #what is our J function now?

            #keep a running minimum over C
            min_u = min(val, min_u)
        end

        y[i] = min_u
    end

    #compute the gram Matrix K
    K = zeros(n, n)
    for i = 1:n
        for j = 1:n
            K[i,j] = kernel(x_mu[:,i], x_mu[:,j])
        end
    end

    #solve the regression problem
    lambda = 1/cbrt(n)
    prob = LinearProblem(K + lambda * n * I, y)
    sol = solve(prob, KrylovJL_CG())
    beta = sol.u
    
    #store data

end