### Installation

Framework installation is possible using Carthage dependency manager. If you've never done that before please use Carthage official documentation, it's really helpful:

[https://github.com/Carthage/Carthage](https://github.com/Carthage/Carthage)

Especially, if you are working on Xcode 12.0 or newer, you should carefully read informations about necessary workaround:

[https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md](https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md)

If carthage is already installed then to add framework to your project please add this line in your Cartfile:

github "https://github.com/tradedoubler/tradedoubler-ios-sdk.git" ~> 1.0.0

After downloading the repository from Carthage you need to configure dependencies manually in build phases of your project. 

**Min SDK Version**

Repository works with iOS version 12.0 and newer.
