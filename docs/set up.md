# For running
An html5 build will be provided.
Runs off of any simple HTTP server. 
	
# For developing

## Tools
### IDE 
    
    Suggested: Intellij With Haxe support 
	Version 2016.3 is the latest one to support Haxe 
	https://www.jetbrains.com/idea/download/previous.html

	Haxe Plugin: 
		Can be installed using the IDE plugins settings.
		Clicking on Browse Plugins.
		
	To set up haxe on the IDE for development you can follow this guidelines
	http://haxe3.blogspot.in/2013/09/setting-up-haxeopenfl-project-in.html
	
		
### Openfl
Installation instructions as described in the main site [openfl.org](http://www.openfl.org/learn/docs/getting-started/)
* Download and install Haxe
* Ensure that Haxe tools are on the PATH (might require windows restart)
* Run
    
    `haxelib install openfl`
         
    `haxelib run openfl setup`

* Install Spritesheet library

	`haxelib install spritesheet`

	
### Code
Project code can be obtained at [bitbucket.org](https://bitbucket.org/jerobarraco/jbm-html5-programming-test/src)


# For building
### Test
To build the project or run it with the included webserver use 
    `openfl test html5`

Or run it with
	`openfl build html5`

### Release
There's a bundled script for building a release. It creates a release-mode minified version of the game.
You need to have *python* installed as well as *7zip* and run `python3 dorelease.py` in the root folder of the project.

It will leave 2 zip files one for the binaries, and the other for the source (with the -src postfix).
Named with the current date, in the folder `out/builds`.


### Building for Mobile using PhoneGap

1. Go to the [PhoneGap.com](http://phonegap.com/getstarted/)
2. Download and install the client (in my case i used the command line client)
3. Replace the folder `phone_gap/www/bin` with the one generated in `out/html5/release` but don't change the file `phone_gap/www/index.html`
 The plugins are already set into `config.xml`. They are
 - *Cordova-plugin-whitelist* 
 - *[Cordova-HTTPD](https://github.com/floatinghotpot/cordova-httpd.git#4304980)* 
4. Go to [Build.PhoneGap.com](https://build.phonegap.com/apps) and create the project.
5. Go to *"Update Code"* for the project, and upload a zip file of the `phone_gap` folder.
5. Load the correct signatures and go to *"Rebuild All"*
6. Download the `.ipa` and `.apk` generated files


### Building for other targets
OpenFL allows many other targets in other languages than HTML5. 
Ie. windows, mac, linux (native via cpp or neko) 64 or 32b, as well as Flash, iOS and Android.
You can read about it on [OpenFL site](http://www.openfl.org/lime/docs/command-line-tools/basic-commands/)

* For iOS run `openfl build ios`
* For Android run `openfl build android`
* For Windows run `openfl build windows`

#### Building for Android using native code
Built using GNU/Linux (Kubuntu 16.10)

You need the Android SDK *and* NDK, as well as a Java SDK.	
You can allow OpenFL to install them automatically or 
you can install them manually.

I've installed them manually.

1. Get and install the Android SDK and [Android NDK](https://developer.android.com/ndk/downloads/index.html)
Android SDK can be installed using the distribution's package manager or downloading it from the [web](https://developer.android.com/studio/index.html#downloads)
2. Install a Java SDK
Using your distribution's package manager or via web
3. Run `openfl setup android` it will ask you to install automatically, 
or if manually (my case) it will ask for the path of the 3 tools.

Once that's set, you can build your android package by running `openfl build android`

If you want to make a **release** build, be sure to add 
*the certificate*, the certificate *password* and the *alias* in the `project.xml` file.