using BenchmarkTools

# preallocate arrays
A = rand(1000,1000)
B = rand(1000,1000)
C = rand(1000,1000)

# the inner loop is across columns, Row-Major
function row_major!(C,A,B)
    for i in 1:1000, j in 1:1000
    C[i,j] = A[i,j] + B[i,j]
    end
end
@btime row_major!(C,A,B) # 10s of

# the inner loop is down rows, Column-Major
function col_major!(C,A,B)
    for j in 1:1000, i in 1:1000
    C[i,j] = A[i,j] + B[i,j]
    end
end
@btime col_major!(C,A,B)

function col_major!(C,A,B)
    for j in 1:1000, i in 1:1000
    val = [A[i,j] + B[i,j]] # brackets create 1-element array
    C[i,j] = val[1]
    end
end
@btime col_major!(C,A,B)

function col_major!(C,A,B)
    for j in 1:1000, i in 1:1000
    val = A[i,j] + B[i,j] # omitting brackets
    C[i,j] = val
    end
end
@btime col_major!(C,A,B)

function no_prealloc(A,B)
    C = rand(1000,1000) # preallocate array inside of function
    for j in 1:1000, i in 1:1000
        val = A[i,j] + B[i,j]
        C[i,j] = val
    end
end
@btime no_prealloc(A,B)

C = rand(1000,1000) # preallocate array outside of function
function w_prealloc!(C,A,B)
    for j in 1:1000, i in 1:1000
    val = A[i,j] + B[i,j]
    C[i,j] = val
    end
end
@btime w_prealloc!(C,A,B)

function no_broadcast(A,B,C)
  tmp = A + B
  tmp + C
end
@btime no_broadcast(A,B,C)

function unfused(A,B,C)
  tmp = A .+ B
  tmp .+ C
end
@btime unfused(A,B,C)

function fused(A,B,C)
    A .+ B .+ C
end
@btime fused(A,B,C)

function basic()
    A = ones(1000,1000)
    B = A .- 2 # -1 matrix
    C = A + B # 0 matrix
    D = A - B # 2 matrix
end
basic()

function basic()
    A = zeros(10,10)
    B = A .- 2
    C = A + B
    D = A - B

    return B, D
end

β, δ = basic()

D = zeros(1000,1000)
function fused_1!(D,A,B,C)
    D = A .+ B .+ C
end
δ = fused_1!(D,A,B,C)

D = zeros(1000,1000)
function fused_2!(D,A,B,C)
    for j in 1:1000, i in 1:1000
        D[i,j] = A[i,j] + B[i,j] + C[i,j]
    end
end
δ = fused_2!(D,A,B,C)

D = zeros(1000,1000)
function fused_3!(D,A,B,C)
    D .= A .+ B .+ C
end
fused_3!(D,A,B,C)
δ = fused_1!(D,A,B,C)

@btime fused_1!(D,A,B,C)
@btime fused_2!(D,A,B,C)
@btime fused_3!(D,A,B,C)


a = [1,2,3]

function f!(a)
    a[1] = 10
end
f!(a)
a   # a = [10,2,3]

function g!(a)
    a[:] = [1,2]
end
g!(a)
a

a = 1
b = 1
a === b

a = [1,2,3]
b = [1,2,3]
a === b

@btime f!(a)
@btime g!(a)



function f_alloc(A)
    B = A[1:5,1:5]
end

function f_point(A)
    B = @view A[1:5,1:5]
end

@btime f_alloc(A) # allocate array, 80 ns
@btime f_point(A) # allocate pointer, 27 ns

A = rand(1000,1000)
B = f_alloc(A)
A .= zeros(1000,1000)
B # B is unchanged

A = rand(1000,1000) # Bind A to new 1000x1000 rand matrix
B = f_point(A) # Bind B to a pointer, which points at 5x5 slice of A
A .= zeros(1000,1000) # change contents of A
B # B changes
A = rand(1000,1000) # change what A is ''bound'' to
B # pts to old A's mem; we changed A's bindings; can't access mem B pts to?



ff(x,y) = 2x + 2y
ff(x::Int,y::Int) = 2x + y
ff(x::Float64,y::Float64) = x/y
@show ff(2,5)
@show ff(2.0,5.0)

ff(2.0,5)

ff(x::Number,y::Number) = 2x
ff(x::Union{Int,Float64},y::Union{Int,Float64}) = 10 + x

ff(2.0,5)

function h()
    a = ["1.0",2,3.0]
end
@btime h()

function hh()
    a = [1,2,3]
end
@btime hh()
