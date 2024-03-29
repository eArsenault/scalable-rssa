using DelimitedFiles, StatsBase

#=
(i) get_environment takes a scenario code and returns the corresponding environment function
(ii) the second return variable distinguishes whether the noise has a defined pmf
=#

#Will tweak parameters of 2x2 environment so that it makes sense

function get_environment(scenario_code)
    if scenario_code == "water2"
        return (environment_water2d, 1)
    elseif scenario_code == "water2_pmf"
        return (environment_water2d, 0)
    elseif scenario_code == "water10"
        return (environment_water10d, 1)
    else
        return (environment_test, 1)
    end
end

function get_pmf(scenario_code)
    if (scenario_code == "water2_pmf" || scenario_code == "water2")
        #here, connect to a csv for the pmf
        #we want a vector of values
        src = "data/data_normalized.csv"
        d = readdlm(src, ',', Float64)
        #assumes realizations are first column, probabilities are second
        return (d[:,1], d[:,2])
    else 
        ##LATER: implement a null noise variable, i.e., something as a backup

        src = "data/data_normalized.csv"
        d = readdlm(src, ',', Float64)
        #assumes realizations are first column, probabilities are second
        return (d[:,1], d[:,2])
    end
end

function get_cost(scenario_code)
    if scenario_code == "water2" || scenario_code == "water2_pmf"
        return cost_water2d
    elseif scenario_code == "water10"
        return cost_water10d
    else
        return cost_test
    end
end

function environment_test(x, u, w=nothing, m=100)
    return map(v -> x, 1:m)
end

#this ones a WIP
function environment_water2d(chi, u, w, p, m=100)
    #relevant parameters for dynamics, cost
    D = [0 0.8; 0 0] #reservoir 1 receives half the outflow from reservoir 2
    r = [1; 1]
    B = [3; 3]

    #maximum cost in this config == 4.5
    xl = [10.0, 10.0]

    x, z = (chi[1:(end-1)], chi[end])
    c = cost_water2d(x,u)
    if m == 0
        return map(v -> [min.(x + (D - I) * min.((r .* sqrt.(x) .* u), x) + (B * v), xl); max(z, c)], w)
    else
        w_samp = sample(w, Weights(p), m)
        return map(v -> [min.(x + (D - I) * min.((r .* sqrt.(x) .* u), x) + (B * v), xl); max(z, c)], w_samp)
    end
end

function cost_water2d(chi, u)
    x = chi[1:2]
    op = [5.0, 5.0]
    eps = [0.5, 0.5]
    return maximum([abs.(x - op) - eps; 0])
end

function cost_test(x,u)
    return 1
end