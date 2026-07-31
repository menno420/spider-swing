# Stable Android debug signing key

`debug.keystore` is deliberately committed so consecutive `android-debug`
workflow artifacts have the same Android signing identity. That lets a new
laboratory APK install over the previous one and preserves the app's local save
data, which is required to exercise real-device save migrations and long-term
progression.

This is the conventional public debug identity:

- alias: `androiddebugkey`
- keystore password: `android`
- key password: `android`
- SHA-256 file digest:
  `e9104672477e0238b6cc2f7d6b994c459e37f130cae06a37aff05001f101bbda`
- certificate SHA-256:
  `83ff0bc27903351779ffd1439f115e8c7e4c228fddd683e2a801c9700b30a741`

## Warning

This key is a debug convenience, not a security boundary. It is public and its
credentials are public. It must **NEVER** be reused for Google Play, a release
build, production signing, or any signed distribution. Losing or replacing it
only affects the ability to update this development package in place; release
signing remains deliberately absent from this repository.
