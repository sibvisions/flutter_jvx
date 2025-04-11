flutterBin=`which flutter`
flutterDir=`dirname $flutterBin`

pubCache=$flutterDir/../.pub-cache

if [ ! -d $pubCache ]; then
  pubCache=~/.pub-cache
fi

rm -r $pubCache/hosted/pub.dev/wakelock_plus*
rm -r $pubCache/hosted/pub.dev/mobile_scanner-*
rm -r $pubCache/hosted/pub.dev/package_info_plus-*
rm -r $pubCache/hosted/pub.dev/shared_preferences_foundation-*
rm -r $pubCache/hosted/pub.dev/url_launcher_ios-*
rm -r $pubCache/hosted/pub.dev/image_picker_ios-*
rm -r $pubCache/hosted/pub.dev/file_picker-*
rm -r $pubCache/hosted/pub.dev/device_info_plus-*
rm -r $pubCache/hosted/pub.dev/flutter_native_splash-*
rm -r $pubCache/hosted/pub.dev/sqflite-*
rm -r $pubCache/hosted/pub.dev/sqflite_*
rm -r $pubCache/hosted/pub.dev/flutter_keyboard_visibility-*
rm -r $pubCache/hosted/pub.dev/geolocator-*
rm -r $pubCache/hosted/pub.dev/geolocator_*
rm -r $pubCache/hosted/pub.dev/connectivity_plus*
rm -r $pubCache/hosted/pub.dev/path_provider_foundation-*
rm -r $pubCache/hosted/pub.dev/flutter_timezone*
rm -r $pubCache/hosted/pub.dev/flutter_inappwebview*
rm -r $pubCache/hosted/pub.dev/flutter_tts*
rm -r $pubCache/hosted/pub.dev/speech_to_text*
rm -r $pubCache/hosted/pub.dev/file_saver*
#rm -r $pubCache/hosted/pub.dev/html_editor_enhanced*
rm -r $pubCache/hosted/pub.dev/push-*
rm -r $pubCache/hosted/pub.dev/flutter_local_notifications*
rm -r $pubCache/hosted/pub.dev/screen_brightness*
rm -r $pubCache/hosted/pub.dev/open_filex*
rm -r $pubCache/hosted/pub.dev/pointer_interceptor*
rm -r $pubCache/hosted/pub.dev/webview_flutter*
rm -r $pubCache/hosted/pub.dev/android_id*
rm -r $pubCache/hosted/pub.dev/app_links*
rm -r $pubCache/hosted/pub.dev/screenshot*
rm -r $pubCache/hosted/pub.dev/json_dynamic_widget*
rm -r $pubCache/hosted/pub.dev/web-*
rm -r $pubCache/git/fix_html-editor-enhanced*

echo $pubCache