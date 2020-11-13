"""
`solve_system(f,u0,n)` #code

Solves the dynamical system

``u_{n+1} = f(u_n)`` #latex

for N steps. Returns the solution at step `n` with parameters `p`.

"""
function solve_system(f,u0,p,n)
  u = u0
  for i in 1:n-1
    u = f(u,p)
  end
  u
end

f(u,p) = u^2 - p*u
typeof(f)

function lorenz(u,p)
  α,σ,ρ,β = p
  du1 = u[1] + α*(σ*(u[2]-u[1]))
  du2 = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du3 = u[3] + α*(u[1]*u[2] - β*u[3])
  [du1,du2,du3]
end
p = (0.02,10.0,28.0,8/3)

function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  u[1] = u0
  for i in 1:n-1
    u[i+1] = f(u[i],p)
  end
  u
end

a = solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)

a[1]

reduce(hcat,a)

using BenchmarkTools
function solve_system_save_matrix(f,u0,p,n)
  u = Matrix{eltype(u0)}(undef,length(u0),n)
  u[:,1] = u0
  for i in 1:n-1
    u[:,i+1] = f(u[:,i],p)
  end
  u
end
@btime solve_system_save_matrix(lorenz,[1.0,0.0,0.0],p,1000)
@btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)

function solve_system_save_matrix_view(f,u0,p,n)
  u = Matrix{eltype(u0)}(undef,length(u0),n)
  u[:,1] = u0
  for i in 1:n-1
    u[:,i+1] = f(@view(u[:,i]),p)
  end
  u
end
@btime  solve_system_save_matrix_view(lorenz,[1.0,0.0,0.0],p,1000)


function lorenz(du,u,p)
  α,σ,ρ,β = p
  du[1] = u[1] + α*(σ*(u[2]-u[1]))
  du[2] = u[2] + α*(u[1]*(ρ-u[3]) - u[2])
  du[3] = u[3] + α*(u[1]*u[2] - β*u[3])
end
p = (0.02,10.0,28.0,8/3)
function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  du = similar(u0) # create cache array, modify it, add to output
  u[1] = u0
  for i in 1:n-1
    f(du,u[i],p)
    u[i+1] = du
  end
  u
end
@btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)

function solve_system_save(f,u0,p,n)
  u = Vector{typeof(u0)}(undef,n)
  du = similar(u0) # create cache array, modify it, add to output
  u[1] = u0
  for i in 1:n-1
    f(du,u[i],p)
    u[i+1] = du[:]
  end
  u
end
@btime solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)

b = solve_system_save(lorenz,[1.0,0.0,0.0],p,1000)
