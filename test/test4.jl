using BenchmarkTools

A = rand(1000,1000)
B = rand(1000,1000)
C = rand(1000,1000)

function fused(A,B,C)
    A .+ B .+ C
end
@btime fused(A,B,C)
δ = rand(10,10)
D = zeros(1000,1000)
function fused_1!(D,A,B,C)
    D = A .+ B .+ C # equiv to tmp = A .+ B .+ C; D = tmp
end
δ = fused_1!(D,A,B,C)
@btime fused_1!(D,A,B,C)

D = zeros(1000,1000)
function fused_2!(D,A,B,C)
    for j in 1:2000, i in 1:2000
        D[i,j] = A[i,j] + B[i,j] + C[i,j]
    end
    return D
end
δ = fused_2!(D,A,B,C)

D = zeros(1000,1000)
function fused_3!(D,A,B,C)
D .= A .+ B .+ C
end
fused_3!(D,A,B,C)
δ = fused_3!(D,A,B,C)
@btime fused_2!(D,A,B,C)
@btime fused_3!(D,A,B,C)

a = [1,2,3]
function f!(a)
a[1] = 10
end
f!(a)
a # a = [10,2,3]
function g!(a)
a = [1,2]
end
g!(a)
a # a = [10,2,3]

@btime f!(a) # a[1] = 10
@btime g!(a) # a = [1,2]

function g!(a)
    deleteat!(a, 3)
    a[:] = [1,2]
end
g!(a)
a # a = [10,2,3]

function f_alloc(A)
    B = A[1:5,1:5]
end

function f_point(A)
    B = @view A[1:5,1:5]
end

@btime f_alloc(A) # allocate array, 80 ns
@btime f_point(A)

A = rand(1000,1000) # Bind A to 1000x1000 rand matrix
B = f_alloc(A) # Copy 5x5 slice of A to new allocation, B
A .= zeros(1000,1000) # change contents of A
B # B is unchanged

A = rand(1000,1000) # Bind A to new 1000x1000 rand matrix
B = f_point(A) # Bind B to a pointer, which points at 5x5 slice of A
A .= zeros(1000,1000) # change contents of A

function f!(B)
    B[1,2]=10
end

f!(B)

B[1,2]

A[1,2]

N = 1000000
function f(x,y,N)
    z=0
    for i=1:N
        z += x*y
    end
 end

 @btime f(0.0,3.0)

 function f(x,y)
     z=0
     for i=1:10
         z += x*y
     end
  end

  @btime f(2,3)


@code_llvm f(2,5)

@code_llvm f(2.0,5.0)

@code_typed f(2,5.0)
@code_llvm f(2,5.0)

ff(x::Int,y::Int) = 2x + y
ff(x::Float64,y::Float64) = x/y
@show ff(2,5)
@show ff(2.0,5.0)



ff(x::Number,y::Number) = 2x
ff(x::Union{Int,Float64},y::Union{Int,Float64}) = 10 + x

ff(2.0,5)
typeof(2.0) <: Int

ff(x::Float64,y::Number) = 5x + 2y
ff(x::Number,y::Int) = x - y
ff(2.0,5)

function h()
    a = [1,2,3]
end
@btime h()

function hh()
    a = [0.0,0.3183098861837,3.0]
end
@btime hh()

function no_prealloc(A,B)
    C = rand(1000,1000) # preallocate array inside of function
    for j in 1:1000, i in 1:1000
        val = A[i,j] + B[i,j]
        C[i,j] = val
    end
end
@btime no_prealloc(A,B) # 3 ms, 2 allocations


C = zeros(1000,1000) # preallocate array outside of function
function w_prealloc!(C,A,B)
    for j in 1:1000, i in 1:1000
        val = A[i,j] + B[i,j]
        C[i,j] = val
    end
end
@btime w_prealloc!(C,A,B) # 2 ms, 0 allocations

w_prealloc!(C,A,B)

C

a = [0 0 0]
v = [1 2 3]
function f!(a,v)
    for i=1:100
        a .+= v
    end
end

@btime f!(a,v)

v = @SVector [1, 2, 3]
function g!(a,v)
    for i=1:100
        a' .+= v
    end
end

@btime g!(a,v)

A.+B.+C./10


function unfused(A,B,C)
    A + B + C
end
@btime unfused(A,B,C) # same as no_broadcast()
D
function fused(A,B,C,D)
    tmp = A .+ B
     tmp .+= C
end
@btime fused(A,B,C)

b = rand(100)
function dothis(b)
    a = sin.(b)
end

dothis(b)
