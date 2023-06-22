#=
(i) get_environment takes a scenario code and returns the corresponding environment function
(ii) the second return variable distinguishes whether the noise has a defined pmf
=#

function get_environment(scenario_code)
    if scenario_code == "water3x3"
        return (environment_water3d, 1)
    elseif scenario_code == "water3x3_pmf"
        return (environment_water3d, 0)
    elseif scenario_code == "water10x10"
        return (environment_water10d, 1)
    else
        return (environment_test, 1)
    end
end

function get_pmf(scenario_code)
    if scenario_code == "water3x3_pmf"
        #here, connect to a datasourcce/csv for the pmf
        #we want a vector of values
        return (w, pmf)
    else
        #if no pmf exists, returns a variable with value==nothing
        return
    end
end

function get_cost(scenario_code)
    if scenario_code == "water3x3"
        return cost_water3d
    elseif scenario_code == "water10x10"
        return cost_water10d
    else
        return cost_test
    end
end

function environment_test(x, u, w=nothing, m=100)
    return map(v -> x, 1:m)
end

#this ones a WIP
function environment_3d(chi, u, w=[[1.0, 1.0, 1.0, 1.0, 1.0]], m=100)
    #relevant parameters for dynamics, cost
    D = [0 1 0.5; 0 0 0.5; 0 0 0]
    r = [1; 1; 2]
    B = [1 0 0 0 0.2; 0 1 0 0.5 0; 0 0 1 0.5 0.8]

    #maximum cost in this config == 4.5
    xl = [7.0, 7.0, 7.0]

    x, z = (chi[1:(end-1)], chi[end])
    c = cost_water3d(x,u)
    if m == 0
        return map(v -> [min.(x + (D - I) * min.((r .* sqrt.(x) .* u), x) + (B * v), xl); max(z, c)], w)
    else
        return map(v -> [min.(x + (D - I) * min.((r .* sqrt.(x) .* u), x) + (B * v), xl); max(z, c)], rand(w, m))
    end
end

function cost_water3d(x, u)
    op = [5.0, 5.0, 5.0]
    eps = [0.5, 0.5, 0.5]
    return maximum([abs.(x - op) - eps; 0])
end

function cost_test(x,u)
    return 1
end