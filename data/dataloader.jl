# Function for loading sample data

"""
    get_data(dataset, poollength, datalength, horizon)

Function for importing one of the sample datasets in the repository. `dataset` can be one of
`:solar`, `:traffic`, `:exchange_rate` or `:electricity`. `poollength` gives the number of
timesteps to pool for the model, `datalength` determines the batch size of the output data,
and `horizon` determines the number of time steps that should be forecasted by the model.
"""
function get_data(dataset, poollength, datalength, horizon)
    admissible = [:solar, :traffic, :exchange_rate, :electricity]
    dataset in admissible || error("Sample data not implemented")

    (dataset == :solar) && (BSON.@load "../data/solar_AL.bson" inp_raw)
    (dataset == :traffic) && (BSON.@load "../data/traffic.bson" inp_raw)
    (dataset == :exchange_rate) && (BSON.@load "../data/exchange_rate.bson" inp_raw)
    (dataset == :electricity) && (BSON.@load "../data/electricity.bson" inp_raw)

    lostIdx = horizon + poollength
    datalength = min(datalength,size(inp_raw,1) - lostIdx)
    out_ft = similar(inp_raw, size(inp_raw,2), poollength, 1, datalength)
    for i=1:poollength
        for j=1:datalength
            out_ft[:,i,1,j] = inp_raw[poollength + j - i,:]
        end
    end
    out_lb = inp_raw[(1 + lostIdx :datalength + lostIdx ),1]
    return out_ft, out_lb
end
