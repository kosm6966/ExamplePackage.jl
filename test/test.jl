using BenchmarkTools

# preallocate arrays
A = rand(100,100)
B = rand(100,100)

function inner_rows(A,B)
    for i in 1:100, j in 1:100
    C[i,j] = A[i,j] + B[i,j]
    end
end
@btime inner_rows(A,B)

function inner_cols(A,B)
    for j in 1:100, i in 1:100
    C[i,j] = A[i,j] + B[i,j]
    end
end
@btime inner_cols(A,B)






function inner_cols(A,B)
    for j in 1:100, i in 1:100
    val = [A[i,j] + B[i,j]]
    C[i,j] = val[1]
    end
end
@btime inner_cols(A,B)

function inner_cols(A,B)
    for j in 1:100, i in 1:100
    val = A[i,j] + B[i,j]
    C[i,j] = val
    end
end
@btime inner_cols(A,B)

using StaticArrays
val = SVector{3,Float64}(1.0,2.0,3.0)
typeof(val)

function static_inner_alloc(A,B)
  for j in 1:100, i in 1:100
    val = @SVector [A[i,j] + B[i,j]]
    C[i,j] = val[1]
  end
end
@btime static_inner_alloc(A,B)


function no_prealloc(A,B)
    C = rand(100,100)
    for j in 1:100, i in 1:100
    val = A[i,j] + B[i,j]
    C[i,j] = val
    end
end
@btime no_prealloc(A,B)

C = rand(100,100)
function w_prealloc!(C,A,B)
    for j in 1:100, i in 1:100
    val = A[i,j] + B[i,j]
    C[i,j] = val
    end
end
@btime w_prealloc!(C,A,B)

function no_prealloc(A,B)
    C = rand(100,100)
    for j in 1:100, i in 1:100
    val = A[i,j] + B[i,j]
    C[i,j] = val
    end
end
@btime no_prealloc(A,B)


function f(A,B)
    # 10*(A+B)
    sum([A + B for k in 1:10]) # calculate 10 arrays and sum them
end
@btime f(A,B)

function h(A,B)
    # 10*(A+B)
    C = similar(A) # create array for output
    for k in 1:10
        C .+= (A + B) # add all of A+B first then add this temp array to C
    end
end
@btime h(A,B)

function g(A,B)
    # 10*(A+B)
    C = similar(A) # create array for output
    for k in 1:10
        C .+= A.+ B # reuse memory in each iteration
    end
end
@btime g(A,B)

function g!(C,A,B)
    # 10*(A+B)
    for k in 1:10
        C .+= A.+ B # reuse memory in each iteration
    end
end
@btime g!(C,A,B)

function g!(C,A,B)
    # 10*(A+B)
    for k in 1:10
        C .+= A.+ B # reuse memory in each iteration
    end
    return nothing
end
C = zeros(100,100)
g!(C,A,B)
C

D = Matrix{Float64}(undef, 100, 100)
function f_vector!(D,C,A,B)
    D .*= A .* B.* C
end
@btime f_vector!(D,C,A,B)

function f_loop!(D,C,A,B)
    for i in 1:length(D)
        @inbounds D[i] = A[i] * B[i] * C[i]
    end
end
@btime f_loop!(D,C,A,B)

function f_alloc(A)
    B = A[1:5,1:5]
end

function f_point(A)
    B = @view A[1:5,1:5]
end

@btime f_alloc(A)
@btime f_point(A)

f_alloc(A)
B = f_alloc(A)

function basic()
    A = zeros(10,10)
    B = A .- 2
    C = A + B
    D = A - B

    return B, D
end

B, D = basic()

ff(x,y) = 2x + 2y
ff(x::Int,y::Int) = 2x + y
ff(x::Float64,y::Float64) = x/y

@show ff(2,5)
@show ff(2.0,5.0)

ff(2.0,5)

ff(x::Float64,y::Number) = 2x


ff(2.0,5)

ff(x::Float64,y::Number) = 5x + 2y
ff(x::Number,y::Int) = x - y
ff(2.0,5)



f(x,y) = x + y
x = Number[1.0,3]
function q(x)
  a = 4
  b = 2
  c = f(x[1],a)
  d = f(b,c)
  f(d,x[2])
  return nothing
end

using BenchmarkTools
@btime q(x)

x = [1.0,3.0]
@btime q(x)


x = Number[1.0,3]
function r(x)
  a = 4
  b = 2
  for i in 1:100
    c = f(x[1],a)
    d = f(b,c)
    a = f(d,x[2])
  end
  a
end
@btime r(x)

s(x) = _s(x[1],x[2])
function _s(x1,x2)
  a = 4
  b = 2
  for i in 1:100
    c = f(x1,a)
    d = f(b,c)
    a = f(d,x2)
  end
  a
end
@btime s(x)

typeof(x)
typeof([x[1],x[2]])

A = rand(100,100)
B = rand(100,100)
C = rand(100,100)
@btime for j in 1:100, i in 1:100
  global A,B,C
  C[i,j] = A[i,j] + B[i,j]
end

function f(A,B,C)
    for j in 1:100, i in 1:100
        C[i,j] = A[i,j] + B[i,j]
    end
end
@btime f(A,B,C)
