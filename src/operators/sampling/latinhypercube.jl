"""
    LatinHypercubeSampling(nsamples, dim; iterations)

Create `N` solutions within a Latin Hypercube sample in bounds with dim.

### Example 

```julia-repl
julia> sample(LatinHypercubeSampling(10,2))
10×2 Matrix{Float64}:
 0.0705631  0.795046
 0.7127     0.0443734
 0.118018   0.114347
 0.48839    0.903396
 0.342403   0.470998
 0.606461   0.275709
 0.880482   0.89515
 0.206142   0.321041
 0.963978   0.527518
 0.525742   0.600209

julia> sample(LatinHypercubeSampling(10,2), [-10 -10;10 10.0])
10×2 Matrix{Float64}:
 -7.81644   -2.34461
  0.505902   0.749366
  3.90738   -8.57816
 -2.05837    9.803
  5.62434    6.82463
 -9.34437    2.72363
  6.43987   -1.74596
 -1.3162    -4.50273
  9.45114   -7.13632
 -4.71696    5.0381
```
"""
struct LatinHypercubeSampling <: AbstractInitializer
    N::Int
    dim::Int
    iterations::Int
    LatinHypercubeSampling(nsamples, dim;iterations=25) = new(nsamples,dim,iterations)
end

"""
    sample(method, [bounds])

Return a matrix with data by rows generated by using `method` (real representation) in
inclusive interval [0, 1].
Here, `method` can be [`LatinHypercubeSampling`](@ref), [`Grid`](@ref) or [`RandomInBounds`](@ref).

### Example 

```julia-repl
julia> sample(LatinHypercubeSampling(10,2))
10×2 Matrix{Float64}:
 0.0705631  0.795046
 0.7127     0.0443734
 0.118018   0.114347
 0.48839    0.903396
 0.342403   0.470998
 0.606461   0.275709
 0.880482   0.89515
 0.206142   0.321041
 0.963978   0.527518
 0.525742   0.600209

julia> sample(LatinHypercubeSampling(10,2), [-10 -10;10 10.0])
10×2 Matrix{Float64}:
 -7.81644   -2.34461
  0.505902   0.749366
  3.90738   -8.57816
 -2.05837    9.803
  5.62434    6.82463
 -9.34437    2.72363
  6.43987   -1.74596
 -1.3162    -4.50273
  9.45114   -7.13632
 -4.71696    5.0381
```
"""
function sample(method::LatinHypercubeSampling, bounds = zeros(0,0))
    X = _lhs(method.N, method.dim)
    score = _score_lhs(X)
    # sample improving
    for i in 1:method.iterations
        XX = _lhs(method.N, method.dim)
        sc = _score_lhs(XX)
        sc < score && continue
        X = XX
        score = sc
    end
    isempty(bounds) && (return X)
    _scale_sample(X, bounds)
end

function _lhs(nsamples, dim)
    # initial sample
    X = reshape([v for i in 1:dim for v in shuffle(1.0:nsamples)], nsamples, dim)
    # smooth and normalize sample
    (X - rand(nsamples, dim)) / nsamples
end

_score_lhs(M) = minimum(pairwise_distances(M))
function _scale_sample(X, bounds)
    a = view(bounds, 1,:)'
    b = view(bounds, 2,:)'
    @assert length(a) == size(X,2)
    # scale sample
    a .+ (b - a) .* X
end
