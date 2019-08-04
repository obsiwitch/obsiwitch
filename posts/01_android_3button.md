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
2. `Settings -> System -> Advanced -> Developer options -> enable USB debugging`
3. Connect your phone to your computer via USB
4. Start the [adb](https://developer.android.com/studio/command-line/adb) daemon: `sudo adb start-server`
5. Accept when the USB debugging authorization dialog appears on your phone
6. Start a remote shell `adb shell`
7. Issue the following commands
```sh
# Disable the default launcher (Quickstep com.android.launcher3). Please note
# that you cannot disable the Quickstep launcher from the GUI (Settings -> Apps),
# since the 'Disable' button is greyed out.
# Depending on your device, you might have a different launcher installed.
# To find which package you need to disable, you can list the currently
# installed ones using the `pm list packages` command.
$ pm disable-user com.android.launcher3

# Enable software navigation keys
$ settings put secure system_navigation_keys_enabled 1

# Reboot the phone
$ reboot
```
8. finally, you can kill the adb daemon on your computer: `adb kill-server`

To restore the default behaviour, you can simply re-enable the Quickstep
launcher through the GUI (`Settings -> Apps`) or by running `pm enable
com.android.launcher3` in a remote shell w/ adb and then rebooting your phone.
