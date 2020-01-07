---
title: Restore Android 3-button navigation
date: 2019-07-25
---

I tested the following on my Android One device (Nokia 2.2, Android 9) to
restore the old 3-button navigation (back, home, overview) instead of using
the 2-button gesture navigation.

N.B. It seems the next version of Android (Android Q) will default to 3-button
navigation when using a custom launcher. [[1]](https://android-developers.googleblog.com/2019/07/android-q-beta-5-update.html)

1. Install another launcher on your phone (e.g. [Lean Launcher](https://play.google.com/store/apps/details?id=com.hdeva.launcher&hl=en))
2. Enable USB debugging on your phone (`Settings -> System -> Advanced -> Developer options -> enable USB debugging`) and connect it to your computer
3. Issue the following commands

```sh
# Start adb daemon and a remote shell. Accept if a USB debugging authorization
# dialog appears on your phone.
$ sudo adb start-server
$ adb shell

# Disable the default launcher (Quickstep com.android.launcher3). Please note
# that you cannot disable the Quickstep launcher from the GUI (Settings -> Apps),
# since the 'Disable' button is greyed out.
# N.B. You can list the installed packages by using `pm list packages`.
adb$ pm disable-user com.android.launcher3

# Enable software navigation keys
adb$ settings put secure system_navigation_keys_enabled 1

# Reboot the phone
adb$ reboot

# Stop adb daemon
$ adb kill-server
```

To restore the default behaviour, you can re-enable the Quickstep launcher
through the GUI (`Settings -> Apps`) or run `pm enable com.android.launcher3` in
an adb remote shell and then reboot your phone.
