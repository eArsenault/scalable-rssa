using LinearAlgebra, Random, Distributions

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

    println(size(x))
    println(x[:,1])
end