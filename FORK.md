# This fork

Personal, telemetry-free build of [OpenUsage](https://github.com/robinebers/openusage). It keeps the
official name, bundle id (`com.robinebers.openusage`), and Keychain services so existing accounts,
settings, and Keychain items keep working. It is not distributed.

## What is different

- The PostHog SDK is not linked. `NoopTelemetrySink` replaces `PostHogTelemetrySink`, so no analytics,
  no crash report, and no install id ever leaves the Mac.
- **Settings → Advanced → Privacy** has no "Help Make OpenUsage Better" toggle; there is nothing to
  turn off.
- Builds made with `script/fork/build_personal.sh` carry no Sparkle feed, so they never replace
  themselves with an upstream telemetry build.

`TelemetryRecorder` is untouched. It still runs, but every event goes to the no-op sink. That keeps the
patch small and the upstream tests valid.

## Daily use

```sh
./script/fork/build_personal.sh build   # stage dist/OpenUsage.app
./script/fork/build_personal.sh run     # stage and launch
```

Quit the official app first: both use the same bundle id and the same single-instance lock. The first
launch after switching signing identities asks for Keychain access once per item; choose **Always
Allow**.

Never run `script/release.sh` or the `release.yml` workflow from this fork: they bake the upstream
appcast URL and would reinstall telemetry. `script/fork/verify_no_telemetry.sh` catches that if it
happens.

## Branch model

- `main` — fast-forward-only mirror of `upstream/main`. Never commit here.
- `no-telemetry` — the five small commits on top of `main`. This is the branch to build.

Fork-owned files (`FORK.md`, `script/fork/`, `.github/workflows/fork-verify.yml`) are new files, so
they never conflict.

## Syncing upstream

```sh
git remote add upstream https://github.com/robinebers/openusage.git   # once
./script/fork/sync_upstream.sh
```

That fetches tags, fast-forwards `main`, rebases `no-telemetry`, runs the guard, and builds. To pin to a
release tag instead of `main`:

```sh
TAG=v0.8.1 ./script/fork/sync_upstream.sh
```

SwiftPM may rewrite `Package.resolved`'s `originHash` on the first build after a sync; commit that
change so the next rebase starts clean. Push the result with `git push -u origin no-telemetry`.

Conflict resolutions:

| File | Resolution |
| --- | --- |
| `Package.swift` | Drop the PostHog package and product again |
| `Sources/OpenUsage/Services/Telemetry.swift` | Keep this fork's file (`git checkout --theirs` during a rebase) |
| `Sources/OpenUsage/Views/SettingsScreen.swift` | Delete the re-added analytics toggle |
| `docs/*`, `README.md` | Take upstream wording, then strip the telemetry section |
| `Package.resolved` | `swift package resolve`, then commit |

After each rebase, `git range-diff` should show the same five commits with equivalent changes.

## Verification

```sh
./script/fork/verify_no_telemetry.sh
script/test_quiet.sh
OPENUSAGE_FOCUS_TESTS=1 swift test --filter 'InlineRenameFocusTests|UpdateControlsTests|MetricPinMenuTests'
```

For a network check, run the app behind Little Snitch or `tcpdump -ni any host us.i.posthog.com`; expect
no hits.
