"""
    Grid(npartitions, dim)

Parameters to generate a grid with `npartitions` in a space with `dim` dimensions.

## Example 

```julia-repl
julia> sample(Grid(5,2))
2×25 Matrix{Float64}:
0.0 0.25 0.5 0.75 1.0 0.0 0.25 0.5 0.75 1.0 
0.0 0.0 0.0 0.0 0.0 0.25 0.25 0.25 0.25 0.25 


julia> sample(Grid(5,2), [-1 -1; 1 1.])
2×25 Matrix{Float64}:
-1.0 -0.5 0.0 0.5 1.0 -1.0 -0.5 0.0 0.5 1.0 
-1.0 -1.0 -1.0 -1.0 -1.0 -0.5 -0.5 -0.5 -0.5 -0.5 
```


Note that the sample is with size `dim` x `npartitions^(dim)`, where each column represents an individual in the grid.
"""
struct Grid <: AbstractInitializer
    npartitions::Int
    dim::Int
end

function sample(method::Grid, bounds = zeros(0,0))
    # Create a range from 0 to 1 with the number of points equal to npartitions
    v = range(0, 1, length = method.npartitions)
    
    # Generate all possible combinations of points in the grid
    vals = Iterators.product((v for _ in 1:method.dim)...)
    
    # Reshape the generated points into a 2D array with length(vals) rows and dim columns
    # Each column of the matrix represents an individual in the grid
    _X = reshape([x for val in vals for x in val], length(vals), method.dim)
    X = Array(_X)

    # If bounds is empty, return the generated grid
    # Otherwise, scale the grid according to bounds
    isempty(bounds) && (return X)
    _scale_sample(X, bounds)
end


