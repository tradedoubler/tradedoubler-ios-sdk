### **Installation Manual**


[TOC]



## iOS Integration 


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


### Additional Configuration

If you want to use Apple IDFA then on iOS 14.0+ it is necessary to add AppTrackingTransparency framework and entry in Info.plist under the key 

**NSUserTrackingUsageDescription** 

with a custom message that informs the user why the app is requesting permission to use data for tracking the user or the device.

Opening the URLs on iOS

To get TDUID it's necessary to handle URLs coming from web browsers or other apps. In order to open a normal URL with https scheme (only option for redirecting from a web browser) it will be necessary to add Associated Domains capability. This Apple documentation page may help you to do it correctly:

[https://developer.apple.com/documentation/safariservices/supporting_associated_domains](https://developer.apple.com/documentation/safariservices/supporting_associated_domains)

 

Another option is to create an URL with a custom scheme to be opened from another app. For example:

[tduid://www.your.domain.com/?tduid=3e28242cd1c67ca5d9b19d2395e52941](www.your.domain.com/?tduid=3e28242cd1c67ca5d9b19d2395e52941)

In this case you need to add custom scheme to your app, like shown on this site: 

[https://coderwall.com/p/mtjaeq/ios-custom-url-scheme](https://coderwall.com/p/mtjaeq/ios-custom-url-scheme)

Additionally, in case of handling custom schemes you need to add following lines to your Info.plist dictionary (open as a source code):

&lt;key>LSApplicationQueriesSchemes&lt;/key>

	&lt;array>

		&lt;string>tduid&lt;/string>

	&lt;/array>

Remember that if you have SceneDelegate in your project then you should make sure to handle URL not only in AppDelegate but also there. In many cases AppDelegate won’t be even notified of URL if SceneDelegate is present. Also: your app will try to open all URLs with your scheme (or your domain) and it's developer’s responsibility to check if parameters received from URL are present and in correct format (for example check their length). Setting the URL scheme offers a potential attack vector into your app.


### Configuring SDK

If there is SceneDelegate in the project (iOS 13.0 or later, as long as SceneDelegate has not been removed from the project), the method below: 

**func** scene(**_** scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        TDSDKInterface.shared.configure("1234", "5678")

        TDSDKInterface.shared.isTrackingEnabled = **true**

        TDSDKInterface.shared.isLoggingEnabled = **true**

    }

is the suggested location for configuring the framework. Otherwise you need to fall back to the old AppDelegate method: 

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        

        TDSDKInterface.shared.configure("1234", "5678")

        TDSDKInterface.shared.isTrackingEnabled = **true**

        TDSDKInterface.shared.isLoggingEnabled = **true**

        

        **return** **true**

    }

There you need to call: 

**TDSDKInterface.shared.configure({ORGANIZATION_ID}, {SECRET_CODE})**

These parameters are obligatory for the framework to work - first one in all cases of tracking, second one for all sales. You should obtain your values of these parameters from Tradedoubler. They’re stored only in the app memory, so after each launch of the app you need to call configure(). Please remember that if your project must handle iOS before 13.0 and SceneDelegate is also there, you have to implement appropriate methods in both classes. 


### Identify a User

It’s necessary to identify a user for the tracking to make sense. To accomplish that you have to set at least one of the two following parameters - email and / or IDFA. Framework is storing SHA-256 digest for each of them (if set).  \
Setting email may be done directly by using:

**TDSDKInterface.shared.email = {USER_EMAIL_PLAINTEXT} **like in code below

	TDSDKInterface.shared.email = "test012345678@example.com"

SHA256 will be counted internally.

If user is logging out remember to clear this value:

TDSDKInterface.shared.email = nil

or use a convenience method:

TDSDKInterface.shared.logout()

Same goes for IDFA - you may pass plaintext IDFA string, but in case of user limited / disabled tracking or not authorized when requested on iOS 14.0+ you will get null IDFA string  ("00000000-0000-0000-0000-000000000000"). This case will be seen as a nil (iOS null constant) by the framework. Furthermore, setting IDFA is possible directly by using: 

**TDSDKInterface.shared.IDFA = {USER_IDFA_PLAINTEXT}**

example:

TDSDKInterface.shared.IDFA = ASIdentifierManager.shared().advertisingIdentifier.uuidString


### Get TDUID

To bind identifiers passed to the framework in the previous paragraph we need to obtain TDUID from Tradedoubler. In iOS it may be very hard to obtain the installation URL from the Apple App Analytics. It may be possible using some 3rd parties APIs or just plainly impossible on the Apple ecosystem. 

Second option is to get TDUID from the redirection URL. It’s also possible to simulate a click redirecting to the TDUID. By default TDUID is extracted from query parameter of URL:

[https://www.your.domain.com?tduid=3e28242cd1c67ca5d9b19d2395e52941](https://www.your.domain.com/?tduid=3e28242cd1c67ca5d9b19d2395e52941)

 \
In case of non standardized URL, it is the developer's responsibility to extract TDUID and set it to the SDK instance.

When intercepting from the default URL obtained on the app opening two methods are important.



First is SceneDelegate’s

**func** scene(**_** scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        configureFramework()

        **for** context **in** connectionOptions.urlContexts {

            **let** url = context.url

            **if** TDSDKInterface.shared.handleTduidUrl(url: url) {

                // now you have tduid set in framework, debug or ignore

                **break**

            } **else** {

                //failed setting tduid. Not default URL structure or no tduid parameter obtained

            }

        }

    }

Second being AppDelegate’s

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        **if** **let** url = launchOptions?[UIApplication.LaunchOptionsKey.url] **as**? URL {

            **if** TDSDKInterface.shared.handleTduidUrl(url: url) {

                // now you have tduid set in framework

            } **else** {

                //failed setting tduid. Not default URL structure or no tduid parameter obtained

            }

        }

Also, when app has been already open the methods of interest are:

**func** scene(**_** scene: UIScene, openURLContexts URLContexts: Set&lt;UIOpenURLContext>) {

        **for** context **in** URLContexts {

            **let** url = context.url

            **if** tradeDoubler.handleTduidUrl(url: url) {

                // now you have tduid set in framework, debug or ignore

                **break**

            } **else** {

                //failed setting tduid. Not default URL structure or no tduid parameter obtained

            }

        }

    }

And

func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        if TDSDKInterface.shared.handleTduidUrl(url: url) {

            // now you have tduid set in framework

        } else {

            //failed setting tduid. Not default URL structure or no tduid parameter obtained

        }

        return true

    }

Also remember that on devices with iOS 14.0 and later AppDelegate method **directly above** won’t get called. Convenience method** <span style="text-decoration:underline;">handleTduidUrl(url:)</span>** may be used only for default URL structure. If a custom URL was used tduid should be set directly using

TDSDKInterface.shared.tduid = "tduid_obtained_from_a_custom_url"

For a better understanding, please analyze the methods of the demo app declared separately in SceneDelegate and AppDelegate above.


### Disable Tracking

In some cases, like testing the development version of an application, we may not want to track requests (although it effectively disables every feature you may expect from our framework). In this case property isTrackingEnabled TDSDKInterface singleton object allows us to make an appropriate setting.

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        (...)

        TDSDKInterface.shared.isTrackingEnabled = **false**

        **return** **true**

    }


### Enable Logs

In some cases, like testing the development version of an application, we may not log everything happening inside the framework into the console. Flag isLoggingEnabled inside TDSDKInterface singleton object allows to mute almost all logs (except for errors).

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        

      (...)

        TDSDKInterface.shared.isLoggingEnabled = **false**

        **return** **true**

    }


### Encryption

The iOS version of the framework uses encryption on the CommonCrypto framework foundations: MD5, SHA-256 and AES using 256 bit key.




## Usage


### Tracking app installation


<table>
  <tr>
   <td>Name
   </td>
   <td>Info
   </td>
   <td>Is required
   </td>
  </tr>
  <tr>
   <td>appInstallEventId
   </td>
   <td>Id of installation event in Tradedoubler system
   </td>
   <td>true
   </td>
  </tr>
</table>


For tracking app installation in iOS we have prepared the following method:

**@discardableResult** **public** **func** trackInstall(appInstallEventId: String) -> Bool 

It’s usage, however, is very limited. At the start, it’s necessary to download the application including our framework **from the App Store**, then get the TDUID from the installation URL, and after having this accomplished it’s required to have user email and / or IDFA already set in framework on app’s first run.

The only parameter is trackInstall event identifier, obtained from Tradedoubler.

Returned flag informs if the URL(s) were created (disabled tracking, trying to run this method more than once after installation or not having user identifiers set in the app will take effect in returning false). For the majority of use cases return should be ignored.

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        //configure framework here, including retrieving TDUID

        TDSDKInterface.shared.trackInstall(appInstallEventId: sdk_app_install)




### Tracking the Opening of the Application

To track opening of the application please use the following method:

 @discardableResult public func trackOpenApp() -> Bool

It should be invoked on each application launch after configuring necessary parameters.

The Boolean flag returned by this method is discarded by default and is true only when the URL(s) were created (tracking must be enabled and framework configured correctly with at least one unique user identifier).

**func** application(**_** application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: **Any**]?) -> Bool {

        //configure framework, set email or IDFA

        TDSDKInterface.shared.trackOpenApp()

If you need to monitor not only opening a closed app but also situations when the user is bringing your app back from background it is possible. However, if you have sceneDelegate then standard method from AppDelegate won’t get called, so when you are supporting iOS before 13.0 you need to implement both:

AppDelegate:

**func** applicationWillEnterForeground(**_** application: UIApplication) {

        TDSDKInterface.shared.trackOpenApp()

SceneDelegate:

**func** sceneWillEnterForeground(**_** scene: UIScene) {

        TDSDKInterface.shared.trackOpenApp()




### Track Leads

**func** sdkLead() {

        TDSDKInterface.shared.trackLead(leadEventId: sdk_lead, leadId: "1234")

    }


<table>
  <tr>
   <td>Name
   </td>
   <td>Info
   </td>
   <td>Is required
   </td>
  </tr>
  <tr>
   <td>leadEventId
   </td>
   <td>Id of event in Tradedoubler system
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>leadId
   </td>
   <td>Id of lead (from Advertiser / Publisher)
   </td>
   <td>true
   </td>
  </tr>
</table>


Returned flag is signalling if the URL(s) was / were created and may be safely discarded.


### Track Sales

**func** sdkSale() {

        **let** reportInfo = ReportInfo(entries: 

[ReportEntry(id: "123", productName: "milk", price: 2.15, quantity: 3),

              ReportEntry(id: "456", productName: "tea", price: 1.00, quantity: 3)])

        TDSDKInterface.shared.trackSale(saleEventId: sdk_sale_2, orderNumber: "14", orderValue: reportInfo.orderValue, currency: "EUR", voucherCode: **nil**, reportInfo: reportInfo)

    }


<table>
  <tr>
   <td>Name
   </td>
   <td>Info
   </td>
   <td>Is required
   </td>
  </tr>
  <tr>
   <td>saleEventId
   </td>
   <td>Id of event in Tradedoubler system
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>orderNumber
   </td>
   <td>Unique order number (from Advertiser/ Publisher)
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>orderValue
   </td>
   <td>value of order
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>currency
   </td>
   <td>Currency of the order (ISO-4217)
   </td>
   <td>false
   </td>
  </tr>
  <tr>
   <td>voucherCode
   </td>
   <td>Voucher code affiliated with organization
   </td>
   <td>false
   </td>
  </tr>
  <tr>
   <td>reportInfo
   </td>
   <td>Info about basket
   </td>
   <td>false
   </td>
  </tr>
</table>


If reportInfo was passed, it’s possible to use reportInfo.orderValue as order value.

As in every other tracking - returned flag is discardable and is true if URL(s) was / were created.


### Track Sales PLT

**func** sdkSalePLT() {

        **let** reportInfo = BasketInfo(entries: 


    [BasketEntry.init(group: sdk_group_1, id: "123", productName: "milk", price: 2.15, quantity: 3),


    BasketEntry.init(group: sdk_group_2, id: "456", productName: "tea", price: 1.00, quantity: 3)])

        

        TDSDKInterface.shared.trackSalePlt(orderNumber: "28", currency: "EUR", voucherCode: **nil**, reportInfo: reportInfo)

        //or if you have custom event identifier (not 51)

        //TDSDKInterface.shared.trackSalePlt(saleEventId: custom_value, orderNumber: "28", currency: "EUR", voucherCode: nil, reportInfo: reportInfo)

 }


<table>
  <tr>
   <td>Name
   </td>
   <td>Info
   </td>
   <td>Is required
   </td>
  </tr>
  <tr>
   <td>saleEventId
   </td>
   <td>Id of event in Tradedoubler system, default 51
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>orderNumber
   </td>
   <td>Unique order number (from Advertiser/ Publisher)
   </td>
   <td>true
   </td>
  </tr>
  <tr>
   <td>currency
   </td>
   <td>Currency of the order (ISO-4217)
   </td>
   <td>false
   </td>
  </tr>
  <tr>
   <td>voucherCode
   </td>
   <td>Voucher code affiliated with organization
   </td>
   <td>false
   </td>
  </tr>
  <tr>
   <td>reportInfo
   </td>
   <td>Info about basket
   </td>
   <td>true
   </td>
  </tr>
</table>


Like in every other tracking method on this platform - trackSalePlt returns discardable boolean flag signalling if the URL(s) was / were created. 