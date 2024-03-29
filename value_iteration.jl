using HDF5
include("bellman.jl")

#### ISSUE: progress is not updated within the hdf5 file, i.e., cannot restart easily after stopping

#=
(i) This code runs the value iteration algorithm.
(ii) Data is loaded and stored  in a corresponding HDF5 file, generated in init_experiment.jl.
(iii) Bellman operators are loaded from bellman.jl.
=#
function parse_prog(p)
    return map(s -> parse(Int64,s[2:end]), split(p,"/"))
end

function value_iteration(obj)
    name = obj["name"]*".h5"

    #if value iteration was half-way completed, start at the latest iterate
    #must ensure experiment file has been initialized, however
    if isfile("data/"*name)
        #open the file, access base attributes
        h5open("data/"*name,"r") do file
            global method = read_attribute(file, "method")
            global scenario_code = read_attribute(file, "scenario_code")
            global s_num = read_attribute(file, "s_num")
            global N = read_attribute(file, "N")
        end
    else
        error("Experiment not initialized.")
    end

    #read current progress, completion state
    global progress = h5read("data/"*name, "progress")
    complete = h5read("data/"*name, "complete")

    #set final condition
    final_cond = "s"*string(s_num)*"/J0"

    #read the most recent value function
    global J = h5read("data/"*name, progress)

    #choose which type of Bellman update to use, and identify relevant parameters
    if method == "exact"
        println("Exact method chosen.")
        bellman = bellman_exact
        parameters = h5read("data/"*name, "init")
    elseif method == "approx"
        println("Approximate method chosen.")
        bellman = bellman_approximate
        parameters = h5read("data/"*name, "init")
    else
        bellman = bellman_test
        parameters = h5read("data/"*name, "init")
    end

    #begin value iteration
    if complete == "yes"
        println("Experiment is complete.")
    else
        while complete == "no"
            if progress == final_cond
                #this means process is complete
                println("Saving iterate s"*string(s_num + 1)*"/J0.")
                h5write("data/"*name, "s"*string(s_num + 1)*"/J0", zeros(size(J)))
                println("Iteration complete for  s"*string(s_num + 1)*".")
                println("Experiment is complete.")
                break

            elseif progress[end-1:end] == "J0"
                #this means we've finished VI for particular s (not final)
                #move to next s-value
                local s, j = parse_prog(progress)
                println("Iteration complete for s"*string(s)*".")
                global progress = "s"*string(s+1)*"/J"*string(N)
                global J = h5read("data/"*name, progress)

            else
                #move to next iterate for same s
                local s, j = parse_prog(progress)
                J_new = bellman(J, scenario_code, parameters)
                global J = J_new
                println("Bellman Update complete.")
                global progress = "s"*string(s)*"/J"*string(j-1)
                println("Saving iterate "*progress)
                h5write("data/"*name, progress, J)
            end
        end
    end
end

