# Privacy

OpenUsage reads nothing that belongs to other tools: no other app's Keychain items, auth files, logs,
databases, or environment variables. It holds only the credentials you add in the app, and it calls
only the provider APIs those accounts need.

## Credentials stored on this Mac

- OAuth tokens and API keys live in the app's own Keychain service
  (`com.robinebers.openusage.accounts`), one item per account. Removing an account deletes its item.
- A [CLIProxyAPI hub](cliproxyapi.md)'s management key lives in `com.robinebers.openusage.cliproxy-hubs`
  and is deleted with the hub. Hub accounts hold no token.
- Account names, the layout, settings, and the last fetched usage live in the app's preferences.
- Provider responses are never written to disk. Nothing syncs to iCloud.
- The [`openusage` command](cli.md) reads only that last fetched usage. It makes no network request
  and reads no Keychain item.
- A [proxy](proxy.md) password stays in your `~/.openusage/config.json`. OpenUsage reads it but never
  writes or logs it.

## Privacy Mode

**Settings → Advanced → Privacy → Privacy Mode** hides usage and account names from screen recordings.
While your screen is shared or recorded, the menu bar shows the app icon instead of your usage and the
panel blurs account names. While it's on, copied usage pictures blur every account name; while it's
off, they leave email addresses out. It is off by default. A single still screenshot (⌘⇧3, ⌘⇧4) can't
be detected, so use the copy button to share a picture.

## Telemetry in this build

This build sends no analytics. The PostHog SDK is not linked: there is no daily app-use ping, no crash
report upload, and no install id is sent anywhere. The recorder still mints an install id and marks the
day in the app's own preferences, but every event is dropped before it reaches the network.

Upstream OpenUsage sends an anonymous daily ping and crash reports. That behavior does not apply to
this build.
