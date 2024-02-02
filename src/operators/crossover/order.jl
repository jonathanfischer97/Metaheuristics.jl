"""
    OrderCrossover()
Order crossover for representation where order is important. Suitable for permutation
representation.
"""
struct OrderCrossover
    rng
end

OrderCrossover(;rng = default_rng_mh()) = OrderCrossover(rng)

function crossover(population, parameters::OrderCrossover)
    O = positions(population)
    D, N = size(O)
    s = rand(parameters.rng, 1:D, N) # slash points
    for i = 1:2:N
        PA = O[:, i]   # parent A
        PB = O[:, i+1] # parent B
        O[s[i]+1:D, i] = setdiff(PB, PA[1:s[i]]);
        O[s[i]+1:D, i+1] = setdiff(PA, PB[1:s[i]]);
    end
    O
end
