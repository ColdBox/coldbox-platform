# ColdBox Async Programming

## AsyncManager

Our manager for integration into the ColdBox async programming aspects. The manager will be registered in WireBox as `AsyncManager@ColdBox`.

The super type has a new `async()` method that returns to you the instance of the AsyncManager so you can execute async/parallel operations.

### Runnable Methods

- `allOf( tasksOfClosures:array ):array` : Run the array of tasks in parallel and join (block) wait for all results to be done and return an array of results, if any.
- `anyOf( tasksOfClosures:array ):any` : Run the array of closure tasks in parallel and whichever finishes first, return the result of the computation
- `run( runnable, [method], [debug=false], [loadAppContext=true] ):Future` A shortcut to execute a runnable method/closure/lambda and give you back a ColdBox Future the computation.

### Creation Methods

- `newFuture():Future` : Returns a new empty ColdBox future
- `newCompletedFuture( value ):Future` : Returns a new future that is already completed with the given value
- `newExecutor( type, threads ):Executor` : Create a java executor service
https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Executors.html

### Coldbox Future

Modeled after `CompletableFuture`. Here are the CFML methods and which Java methods to proxy into.

- `cancel( mayInterruptIfRunning:false )` -> cancel(boolean)
- `complete( any )` -> complete() to complete a future.
- `completeWithException( e )` -> completeExceptionally()
- `get( [timeout=0], [timeUnit=seconds], [defaultValue] )` -> get() block to get result.
- `getNow( defaultValue ):any` -> getNow() Returns the result value (or throws any encountered exception) if completed, else returns the given valueIfAbsent.
- `getNative()` - Gives you the native `CompletableFuture` Java object
- `isCancelled()` - Returns true if this CompletableFuture was cancelled before it completed normally.
- `isCompletedWithException()` -> isCompletedExceptionally() Returns true if this CompletableFuture completed exceptionally, in any way.
- `isDone()` - Returns true if completed in any fashion: normally, exceptionally, or via cancellation.
- `onException( closure ):any` -> exceptionally() callback gives you a chance to recover from errors generated from the original Future. You can log the exception here and return a default value.
- `run( runnable, [method=run] )` -> supplyAsync(), runAsync() Returns a new CompletableFuture that is asynchronously completed by a task running in the ForkJoinPool.commonPool() after it runs the given action and an optional returned value
- `then()` -> thenApply(), thenAccept(), thenRun() basically a post-processor once the runnable has completed and produced a result or no result.
- `thenCompose( closure:CompletableFuture )` - Passes the result of the previous computation to the closure, which in turns MUST return a new ColdBox Future computation. The second computation depends on the initial one. Sequential computational chain or functional chain
- `thenCombine( Future, (r1,r2) => {} )` - Used when you want two futures to run independently and do something after both complete. The second argument is a closure that accepts the results of both computations and you will return a single value from the computation. The callback function passed to thenCombine() will be called when both the Futures are complete.

## WireBox Updates

- Ability to annotate a function with `future` so it will wrap the result in a ColdBox completable future.  The return MUST be a closure.

```java
function getQuestionsFromGoogle() future{
	return () => googleApi.get( "docs" );
}
```

### Thread Pools

https://www.callicoder.com/java-executor-service-and-thread-pool-tutorial/



## Todo

- Custom ThreadPools
- acceptEither
- allOf
- applyToEither
- xasync operations