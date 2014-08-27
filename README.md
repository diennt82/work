iphone-app (master_v2 branch)
=============================

Hubble app for iOS

You can only use this code base by opening the .xcworkspace and not the .xcodeproj.

To make your life easier.. make sure that you "git clone" the iphone-app and iphone-frameworks 
repos (without renaming them) into the same same root directory (ex. dev directory below).

```
> mkdir dev
> cd dev
> git clone -b master_v2 https://github.com/monitoreverywhere/iphone-app.git
> git clone https://github.com/monitoreverywhere/iphone-frameworks.git
> cd iphone-app
> open BlinkHD_ios.xcworkspace
```

After you have installed Cocoapods and the 3rd party libraries managed by it 
you should be able to compile for at least a Debug build with a Simulator target
without any trouble.

`~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

[sven - August 14, 2014]
This project was converted to use CocoaPods for integrating 3rd party libraries.
http://cocoapods.org

1. Install CocoaPods.
2. Run "> pods install" to install/update dependenancies.

`~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`


Developer Notes:
----------------

1. Delete comments and extra lines using vi... <br>
 `:%s/\n\n\/\* No comment provided by engineer\. \*\///g`
