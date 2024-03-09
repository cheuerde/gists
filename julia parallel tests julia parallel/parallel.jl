
addprocs(3)

@everywhere using NumericExtensions

@everywhere n = 100000
@everywhere p = 1
@everywhere niter=1000



a = @parallel [rand() for i = 1:n]
b = @parallel [rand() for i = 1:n]

x = rand(n)
y = rand(n)



#reduce(+, map(fetch,
#{ (@spawnat p dot(localpart(x),localpart(y))) for p=procs(x) }))


@time for i=1:10 reduce(+, map(fetch,
{ (@spawnat p dot(localpart(a),localpart(b))) for p=procs(a) })) end

@time for i=1:niter for p=procs(a) @spawnat  dot(localpart(a),localpart(b)) end end




@time for i=1:10 sum(x.*y) end


@time for i=1:niter reduce(+, map(fetch,
{ (@spawnat p dot(localpart(a),localpart(b))) for p=procs(a) })) end


### Final version
@time for i=1:niter mapreduce(fetch, +, { (@spawnat p sum(a[localindexes(a)].*b[localindexes(b)])) for p=procs(a) }) end



@time for i=1:10 reduce(+, map(fetch,{ (@spawnat p sum(localpart(a).*localpart(b))) for p=procs(a) })) end


############


function test(x,y) 

  n = length(x)
  n == length(y) || error("dimensions don't match") 
  res = Array(typeof(x[1]+y[1]),size(x))
@simd for i=1:n 
    @inbounds res[i] = x[i] + y[i] + y[i] + x[i]
  end
   res
end




function test:<T(x::Array{T,1},y::Array{T,1}) 

  n = length(x)
  n == length(y) || error("dimensions don't match") 
  res = Array(T,size(x))
@simd for i=1:n 
    @inbounds res[i] = x[i] + y[i] + y[i] + x[i]
  end
   res
end


######

addprocs(3)

@everywhere using Base.LinAlg.BLAS

@everywhere n = 100000000

niter = 100

X = SharedArray(Float64,(n,1),pids=procs()[2:end])

@sync for p=procs(X) @spawnat p for i=localindexes(X) X[i] = rand() end end

Y = SharedArray(Float64,(n,1),pids=procs()[2:end])

@sync for p=procs(Y) @spawnat p for i=localindexes(Y) Y[i] = rand() end end


## dot for Darray

@everywhere function dot_parallel(x::SharedArray, y::SharedArray)
sum = 0.0
@simd for i=localindexes(x) 
  @inbounds sum += x[i] * y[i] end
sum
end

@everywhere function dot_parallel(x::DArray, y::DArray)
dot(localpart(x),localpart(y))
end
 

@everywhere function pdot(x, y)

isequal(procs(x),procs(y)) || error("not equally shared")
mapreduce(fetch, +, { (@spawnat p dot_parallel(x,y)) for p=procs(x) })

end

@everywhere function pdot(x::Array, y::Array)

dot(x,y)

end






pdot(X,Y)




a = rand(n)
b = rand(n)

@time for i=1:niter dot(a,b) end







@everywhere function dot_parallel(x::Array, y::Array)
sum = 0.0
@simd for i=1:length(x) 
  @inbounds sum += x[i] * y[i] end
sum
end







