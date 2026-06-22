# ColdBox System Folder — Java Class Usage Report

> Generated: 2025-06-18
> Scope: `/system/` directory
> Total `createObject("java", ...)` calls: **99**
> Unique Java classes used: **37**

---

## 1. `java.lang` — Core Language

| Class | Files |
|---|---|
| `java.lang.System` | `AbstractAppender.cfc`, `AsyncManager.cfc`, `ConsoleAppender.cfc`, `Env.cfc`, `Executor.cfc`, `Mixer.cfc`, `CFMLEngine.cfc` |
| `java.lang.StringBuilder` | `HTMLHelper.cfc`, `XMLConverter.cfc`, `InterceptorBuffer.cfc`, `ExceptionBean.cfc`, `Renderer.cfc`, `Mixer.cfc` |
| `java.lang.String` | `RemotingUtil.cfc` |
| `java.lang.Thread` | `Executor.cfc`, `Scheduler.cfc`, `ScheduledTask.cfc`, `Util.cfc` |
| `java.lang.Runtime` | `CacheBoxProvider.cfc`, `ReportHandler.cfc` |
| `java.lang.RuntimeException` | `Future.cfc` |

## 2. `java.util` — Collections & Utilities

| Class | Files |
|---|---|
| `java.util.concurrent.ConcurrentHashMap` | `Injector.cfc`, `Singleton.cfc`, `ConcurrentStore.cfc`, `ConcurrentSoftReferenceStore.cfc`, `ObjectPopulator.cfc`, `Mixer.cfc` |
| `java.util.Collections` | `EventPool.cfc`, `ConcurrentStore.cfc` |
| `java.util.LinkedHashMap` | `EventPool.cfc` |
| `java.util.UUID` | `DBAppender.cfc`, `ScopeAppender.cfc`, `CacheBoxProvider.cfc`, `InterceptorState.cfc` |
| `java.util.TreeMap` | `EventURLFacade.cfc` |
| `java.util.concurrent.Executors` | `ExecutorBuilder.cfc` |
| `java.util.concurrent.ForkJoinPool` | `ExecutorBuilder.cfc` |
| `java.util.concurrent.LinkedBlockingQueue` | `Executor.cfc` |
| `java.util.concurrent.TimeUnit` | `TimeUnit.cfc` |
| `java.util.concurrent.CompletableFuture` | `Future.cfc` |
| `java.util.concurrent.FutureTask` | `FutureTask.cfc` |
| `java.util.stream.IntStream` | `AsyncManager.cfc` |

## 3. `java.time` — Date/Time API

| Class | Files |
|---|---|
| `java.time.ZoneOffset` | `DateTimeHelper.cfc` |
| `java.time.ZoneId` | `DateTimeHelper.cfc`, `Scheduler.cfc`, `ScheduledTask.cfc` |
| `java.time.temporal.ChronoField` | `DateTimeHelper.cfc` |
| `java.time.temporal.ChronoUnit` | `DateTimeHelper.cfc` |
| `java.time.temporal.TemporalAdjusters` | `DateTimeHelper.cfc` |
| `java.time.DayOfWeek` | `DateTimeHelper.cfc` |
| `java.time.LocalDateTime` | `DateTimeHelper.cfc` |
| `java.time.Duration` | `Duration.cfc` |
| `java.time.Period` | `Period.cfc` |

## 4. `java.net` — Networking

| Class | Files |
|---|---|
| `java.net.InetAddress` | `BugReport.cfm`, `Whoops.cfm`, `Util.cfc` |
| `java.net.Socket` | `SocketAppender.cfc` |
| `java.net.URI` | `RequestContext.cfc` |

## 5. `java.io` — I/O

| Class | Files |
|---|---|
| `java.io.ByteArrayOutputStream` | `ObjectMarshaller.cfc` |
| `java.io.ObjectOutputStream` | `ObjectMarshaller.cfc` |
| `java.io.ByteArrayInputStream` | `ObjectMarshaller.cfc` |
| `java.io.ObjectInputStream` | `ObjectMarshaller.cfc` |
| `java.io.PrintWriter` | `SocketAppender.cfc` |

## 6. `java.lang.ref` — Reference Types

| Class | Files |
|---|---|
| `java.lang.ref.ReferenceQueue` | `ConcurrentSoftReferenceStore.cfc` |
| `java.lang.ref.SoftReference` | `ConcurrentSoftReferenceStore.cfc` |

## 7. `org.hibernate` — ORM

| Class | Files |
|---|---|
| `org.hibernate.Version` | `Util.cfc` |

---

## 8. Files by `createObject` Call Count

| File | Count |
|---|---|
| `HTMLHelper.cfc` | 18 |
| `Builder.cfc` | 4 |
| `Executor.cfc` | 4 |
| `XMLConverter.cfc` | 5 |
| `ObjectMarshaller.cfc` | 4 |
| `DateTimeHelper.cfc` | 7 |
| `Scheduler.cfc` | 3 |
| `Future.cfc` | 2 |
| `ConcurrentStore.cfc` | 2 |
| `ConcurrentSoftReferenceStore.cfc` | 3 |
| `Mixer.cfc` | 4 |
| `Injector.cfc` | 2 |
| `ExecutorBuilder.cfc` | 3 |
| `SocketAppender.cfc` | 2 |
| `ScheduledTask.cfc` | 2 |
| `AsyncManager.cfc` | 2 |
| `Util.cfc` | 3 |
| `EventPool.cfc` | 2 |
| `CacheBoxProvider.cfc` | 2 |
| `ReportHandler.cfc` | 1 |
| `ExceptionBean.cfc` | 2 |
| `RequestContext.cfc` | 1 |
| `ObjectPopulator.cfc` | 1 |
| `EventURLFacade.cfc` | 1 |
| `InterceptorState.cfc` | 1 |
| `DBAppender.cfc` | 1 |
| `ScopeAppender.cfc` | 1 |
| `ConsoleAppender.cfc` | 2 |
| `Singleton.cfc` | 1 |
| `TimeUnit.cfc` | 1 |
| `Duration.cfc` | 1 |
| `Period.cfc` | 1 |
| `FutureTask.cfc` | 1 |
| `Env.cfc` | 1 |
| `CFMLEngine.cfc` | 1 |
| `RemotingUtil.cfc` | 1 |
| `BugReport.cfm` | 1 |
| `Whoops.cfm` | 1 |
| `Renderer.cfc` | 1 |
| `InterceptorBuffer.cfc` | 1 |

---

## Key Takeaways

1. **`java.lang.StringBuilder`** is the most-used class (20+ calls across 6 files) — used heavily for string concatenation in HTML helpers and converters.
2. **`java.util.concurrent.ConcurrentHashMap`** is the most-used concurrent collection (6 files) — core to caching, DI scopes, and event pooling.
3. **`java.lang.System`** is used for stdout/stderr access, property retrieval, and thread interruption (7 files).
4. **`java.time.*`** classes (9 unique classes) are used extensively in the async/time subsystem for modern date/time handling.
5. **`HTMLHelper.cfc`** is the single file with the most Java interop calls (18) — all `StringBuilder` for HTML generation.
6. **Serialization** (`ObjectMarshaller.cfc`) uses 4 distinct `java.io` classes for binary serialization.
7. **Caching stores** (`ConcurrentStore`, `ConcurrentSoftReferenceStore`) rely on `ConcurrentHashMap` and `SoftReference` for eviction policies.
