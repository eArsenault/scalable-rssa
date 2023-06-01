#=
(i) get_environment takes a scenario code and returns the corresponding environment function
(ii) the second return variable distinguishes whether the noise has a defined pmf
=#

function get_environment(scenario_code)
    if scenario_code == "water3x3"
        return (environment_water3d, 0)
    elseif scenario_code == "water3x3_pmf"
        return (environment_water3d, 1)
    elseif scenario_code == "water10x10"
        return (environment_water10d, 0)
    else
        return (environment_test, 0)
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

function environment_test(x, u, w=nothing, m=100)
    return map(v -> x, 1:m)
end