String getLocalFilePath(
    String baseUrl, String baseDir, String appName, String appVersion,
    [bool translationPath = true]) {
  String trimmedBaseUrl = baseUrl.split('/')[2];

  if (translationPath)
    return '$baseDir/translations/$trimmedBaseUrl/$appName/$appVersion';
  else
    return '$baseDir/images/$trimmedBaseUrl/$appName/$appVersion';
}
