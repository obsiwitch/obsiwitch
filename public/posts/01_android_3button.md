---
title: Restore Android 3-button navigation
date: 2019-07-25
---

I tested the following on my Android One device (Nokia 2.2, Android 9) to
restore the old 3-button navigation (back, home, overview) instead of using
the 2-button gesture navigation.

N.B. It seems the next version of Android (Android Q) will default to 3-button
navigation when using a custom launcher. [[1]](https://android-developers.googleblog.com/2019/07/android-q-beta-5-update.html)

Issue the following commands in an [ADB](https://developer.android.com/studio/command-line/adb)
remote shell.

```sh
# Disable the default launcher (Quickstep com.android.launcher3). Please note
# that you cannot disable the Quickstep launcher from the GUI (Settings -> Apps),
# since the 'Disable' button is greyed out.
# N.B. You can list the installed packages by using `pm list packages`.
$ pm disable-user com.android.launcher3

# Enable software navigation keys
$ settings put secure system_navigation_keys_enabled 1

# Reboot the phone
$ reboot
```

To restore the default behaviour, you can re-enable the Quickstep launcher
through the GUI (`Settings -> Apps`) or run `pm enable com.android.launcher3` in
an ADB remote shell and then reboot your phone.
