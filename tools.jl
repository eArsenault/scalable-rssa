using LinearAlgebra, Random, Distributions, StatsBase

function environment(x, u, w, pars)
    return x + (pars["D"] - I) * (pars["r"] .* sqrt.(x) .* u) .+ (pars["B"] * w')
end

function base_setup()
    D = [0 1 0.5; 0 0 0.5; 0 0 0]
    r = [1; 1; 2]
    B = [1 0 0 0 0.2; 0 1 0 0.5 0; 0 0 1 0.5 0.8]

    mu = -1 * [1 1 1 1 1]
    sigma = 0.25 * [1 1 1 1 1]

    return Dict("D" => D, "B" => B, "r" => r, "mu" => mu, "sg" => sigma)
end

#this returns the number of times the grid interval (in each dimension), is multipled to reach the rounded version of x_bd
#hence the index of these values in the grid is just the return value + 1
function get_index(x, upp, low, n)
    x_bd = min.(max.(x, low), upp)

    nvals = n ./ (upp - low)
    return map(x -> round(Int,x), x_bd .* nvals) .+ 1
end

function main()
    Random.seed!(272542)
    d = Normal()

    pars = base_setup()

    #10 is number of samples, 5 is fixed dimension of noise
    w = exp.(pars["mu"] .+ pars["sg"] .* rand(d,10,5))

    println(size(w))
    x_0 = [1; 1; 1]
    u = [0; 0; 0]

    x = environment(x_0, u, w, pars)

    upp = [2.0, 2.0, 2.0]
    low = [0.0, 0.0, 0.0]
    n = [20, 20, 20]

    return get_index(x, upp, low, n)
end