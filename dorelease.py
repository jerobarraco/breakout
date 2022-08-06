#!/usr/bin/env python3
#coding: utf-8
from subprocess import call
import datetime
import os

##building
T_HTML5 = 'html5'
T_LINUX = 'linux'
T_ANDROID = 'android'
T_IOS = 'ios'
T_MAC = 'mac'
T_WINDOWS = 'windows'
# List of targets to compile
TARGETS = [T_HTML5, T_LINUX] #, T_ANDROID]
# List of languages to compile with
LANGS = ["en_US"] #["es_AR", "en_US", "pt_BR"]

# Which targets will use ogg
USE_OGG = [T_LINUX, T_ANDROID]

# Which target will compile in 32 bit mode (by default is the architecture of the cpu that compiles)
IN32B = []

RELEASE = True

# Build all the targets for the given languages
for tar in TARGETS:
	for lan in LANGS:
		print("Building for %s in %s ..."%(tar, lan))
		print("Cleaning ...")
		call(["openfl", "clean", tar])
		print("Building ...")
		#Basic command
		args = ["openfl", "build", tar, "-Dlang="+lan, "-DCanvas", "-minify", "-yui"]

		#Add the debug flag if necessary
		if (not RELEASE):
			args.append('-debug')
			args.append('-Ddebug')

		#Force building in 32 bit mode if necessary
		# Notice that building in 64 is actually only possible if the platform allows it so no way to enforce it
		if (tar in IN32B):
			args.append('-32')

		# and set OGG in case is important
		if (tar in USE_OGG):
			args.append('-Dogg')

		# Mix & bake
		call(args)

## Archiving
NAME = "Breakout"
CDATE = datetime.date.today().strftime("%Y-%m-%d")
CWD = os.getcwd()
OUTDIR = "builds/"
BASENAME = NAME+'_'+CDATE

#Generate the sources package
SNAME = BASENAME+"_src.zip"
OSFILE = os.path.join(OUTDIR, SNAME)
call(["7z", "a", "-r", OSFILE, "-ir@src_included_files.txt" ])

# Archive the HTML5 package
if (T_HTML5 in TARGETS):
	ZNAME = BASENAME+".zip"
	RELDIR = os.path.join(CWD, "out/html5/bin/")
	OZFILE = os.path.join(RELDIR , "../../..", OUTDIR, ZNAME)
	call(["7z", "a", "-r", OZFILE, "*"], cwd=RELDIR)

# Archive the Android target
if (T_ANDROID in TARGETS):
	OAFILE =  './out/android/release/bin/app/build/outputs/apk/Breakout-debug.apk'
	ANAME = BASENAME+'.apk'
	AFILE = os.path.join(CWD, OUTDIR, ANAME)
	call (['mv', OAFILE, AFILE])

	#Optional deployment
	adb_bin = '/home/nande/bin/android/platform-tools/adb'
	call ([adb_bin, 'usb'])
	call ([adb_bin, 'uninstall', 'com.moongate.cftest'])
	call ([adb_bin, 'install', AFILE])

# Archive the Linux64 target
if (T_LINUX in TARGETS and T_LINUX not in IN32B):
	if (T_LINUX in IN32B):
		ZNAME = BASENAME+"_linux_32.zip"
		RELDIR = os.path.join(CWD, "out/linux/bin/")
	else:
		ZNAME = BASENAME+"_linux_64.zip"
		RELDIR = os.path.join(CWD, "out/linux/bin/")

	OZFILE = os.path.join(RELDIR , "../../..", OUTDIR, ZNAME)
	call(["7z", "a", "-r", OZFILE, "*"], cwd=RELDIR)