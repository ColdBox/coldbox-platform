# COLDBOX-1420: Keep WireBox mappings when first metadata processing fails

## Context

A handoff file from another repo (`plans/handoff-coldbox-jira-mapping-deletion.md`) reported this bug: when a WireBox mapping's first `mapping.process()` call fails (for example, the CFC file is briefly missing during a deploy), WireBox deletes the mapping from the binder. The first caller gets the real error. Every later caller gets `Injector.InstanceNotFoundException` until the app is reinitialized. A temporary error becomes a lasting outage.

The handoff was verified against this codebase. The bug is real, the code sites it names are exact, and the fix it suggests is the right one.

## Claims table (verification of the handoff)

| # | Claim | Verdict | Evidence |
|---|-------|---------|----------|
| 1 | `getInstance()` in `system/ioc/Injector.cfc` deletes the mapping in a catch block around `mapping.process()` | **Confirmed** | `system/ioc/Injector.cfc:577-588` (before the fix), inside `getInstance()`. |
| 2 | `Binder.processMappings()` has the same delete-on-error behavior | **Confirmed** | `system/ioc/config/Binder.cfc:1366-1373` (before the fix) — `variables.mappings.delete( key )` in the catch. |
| 3 | After deletion, later lookups throw `Injector.InstanceNotFoundException` | **Confirmed** | `system/ioc/Injector.cfc:561-566` throws exactly that type when `mappingExists()` is false and nothing else finds the name. |
| 4 | Models found by folder scanning may recover; explicit `binder.map().to()` mappings cannot | **Confirmed** | `system/ioc/Injector.cfc:524-571`: a missing mapping goes through `locateInstance()` scan locations and `registerNewInstance()`. An explicit mapping's path is not in a scan location, so nothing re-registers it. |
| 5 | Affects the `development` branch | **Confirmed** | Both delete sites existed on the branch (version 8.2.0 in box.json). |
| 6 | Affects ColdBox 8.1.0+34 on Lucee 6.3.4; repro script fails 10/10 | **Unverifiable** | The repro script was not run here. The code path makes the described result expected. |
| 7 | JIRA tickets COLDBOX-1420 and COLDBOX-1419 exist | **Unverifiable** | No JIRA access from the review environment. |
| 8 | Production failure story (`SQLTokenStorage@rememberMe`) | **Unverifiable** | Belongs to the other repo. Consistent with the confirmed code path. |

## Why the fix is safe

- **Why the delete existed:** added April 2018 in commit `1adec53ce` ("New caching and some error handling") with no ticket and no comment beyond "Remove bad mapping". No test asserted this behavior.
- **Retry is safe.** `Mapping.process()` sets `variables.discovered = true` only at the very end, inside an exclusive lock. A failed run leaves `discovered = false`, so a retry runs the whole thing again. The add methods (`addDIConstructorArgument`, `addDIProperty`, `addDISetter`) skip names that are already registered, and the annotation checks are guarded by `if ( !len( ... ) )`, so a retry does not double-register dependencies. The common transient failure (missing or uncompilable file) happens at the metadata fetch, before any state is written.
- **The old delete was already inconsistent.** `process()` registers alias keys in the binder before later steps that can throw. The delete removed only the one requested name, leaving alias keys pointing at the failed mapping. A mapping registered under several names (`map([ "a", "b" ])`) lost only the name that was looked up.
- **Other `process()` call sites already keep the mapping on failure:** `system/ioc/Builder.cfc:802-803`, `system/ioc/Builder.cfc:1033-1035`, `system/ioc/Injector.cfc` (autowire path). None of them delete on error.
- **Behavior change to be aware of:** for a mapping whose path is permanently wrong, later lookups now throw the original metadata/load error on every call instead of `InstanceNotFoundException` after the first. That error is more informative. No code in the framework or its tests relied on the old type for this case.

## Decision record

**Chosen: remove the deletion in both places.** In `getInstance()`, the try/catch only deleted and rethrew, so the whole try/catch was removed and `mapping.process()` is called directly. In `processMappings()`, only the `variables.mappings.delete( key )` line was removed; the collect-then-throw flow stays.

Alternatives rejected:

1. **Delete only scan-discovered mappings, keep explicit ones** (the handoff's fallback idea). Rejected: there is no flag on `Mapping` that records how it was created, so this needs new state for no benefit. Keeping a scanned mapping is also fine — a retry re-processes the same path, which is exactly what re-discovery would produce.
2. **Do nothing here; work around it in the consuming app.** Rejected: the bug is in ColdBox and affects every consumer. The workaround (eagerly load and re-register in a catch) treats the symptom and must be repeated in every app.

## Corrections sent back to the source repo

The handoff was accurate. Only small notes:

- The code comment was `// Remove bad mapping`, not the paraphrase in the handoff. No behavior difference.
- The delete-on-error dates to April 2018 (commit `1adec53ce`), so it affects far more versions than 8.1.0+34. The fix lands in 8.2.0 (current development version).
- Extra detail: the delete removed only the looked-up name, so aliases registered during the failed processing kept pointing at the dead mapping. The bug was worse than described for multi-name mappings.

## Changes made

1. `system/ioc/Injector.cfc` — `getInstance()` now calls `mapping.process()` directly; the delete-and-rethrow catch block is gone.
2. `system/ioc/config/Binder.cfc` — `processMappings()` no longer deletes a mapping whose processing failed; it still throws after the loop.
3. `tests/specs/ioc/InjectorLiveTest.cfc` — new feature block "Mappings survive a failed first processing (COLDBOX-1420)" with four specs:
   - Explicit mapping to a missing path: first and second lookups both throw the original error (not `InstanceNotFoundException`) and the mapping stays registered.
   - Recovery: mapping whose file is missing on the first lookup builds fine on the second lookup after the file is written.
   - `processMappings()` throws but keeps the failed mapping registered.
   - A mapping registered under two names keeps both names after a failed lookup.

## Verification (actual results)

`box run-script tests:wirebox` (33 bundles, 189 specs) run against three engines on port 8599:

| Engine | Result |
|--------|--------|
| Adobe ColdFusion 2023.0.23 | 189 pass, 0 fail, 0 error |
| BoxLang 1.15.0 (CFML compat) | 187 pass, 2 skipped (engine-specific skips), 0 fail, 0 error |
| Lucee 5.4.8 | 188 pass, 1 skipped (Lucee-specific skip), 0 fail, 0 error |

`box cfformat run` on the three touched files produced no changes beyond the fix itself.

Note: one transient error (`InjectorCreationTest.testProviderMethods`, "Injector not found in scope registration information") appeared in a single early run and never again across five later full runs on three engines. It came from leftover application-scope state after an ad-hoc single-bundle run in the same server boot, not from this change.

## Rollback

Revert the fix commit. The change is two localized edits plus additive tests. No config, data, or API surface changes.

## Out of scope

- Duplicate entries possible in a mapping's alias array if a retry re-runs alias processing — cosmetic, only reachable with a deterministic failure, not worth extra guards.
- COLDBOX-1419 (scheduler missing module mappings) — separate ticket (see `docs/plans/scheduler-module-mappings.md`).
- The consuming app's rememberMe workaround removal — the other repo's task after this ships.
