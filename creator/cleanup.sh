flutterBin=`which flutter`
flutterDir=`dirname $flutterBin`

pubCache=$flutterDir/../.pub-cache

if [ ! -d $pubCache ]; then
  pubCache=~/.pub-cache
fi

rm -r $pubCache/hosted/pub.dev/wakelock-*
rm -r $pubCache/hosted/pub.dev/mobile_scanner-*
rm -r $pubCache/hosted/pub.dev/package_info_plus-*
rm -r $pubCache/hosted/pub.dev/shared_preferences_foundation-*
rm -r $pubCache/hosted/pub.dev/url_launcher_ios-*
rm -r $pubCache/hosted/pub.dev/image_picker_ios-*
rm -r $pubCache/hosted/pub.dev/file_picker-*
rm -r $pubCache/hosted/pub.dev/device_info_plus-*
rm -r $pubCache/hosted/pub.dev/flutter_native_splash-*
rm -r $pubCache/hosted/pub.dev/sqflite-*
rm -r $pubCache/hosted/pub.dev/flutter_keyboard_visibility-*
rm -r $pubCache/hosted/pub.dev/flutter_native_timezone-*
rm -r $pubCache/hosted/pub.dev/connectivity_plus-*
rm -r $pubCache/hosted/pub.dev/path_provider_foundation-*
#rm -r $pubCache/hosted/pub.dev/file_saver-*
rm -r $pubCache/git/fix_file_saver-*
