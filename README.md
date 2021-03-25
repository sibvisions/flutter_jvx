Flutter Client
The Flutter Client is a mobile app for the JVx framework. It's super generic and renders work-screens dynamically. The app supports all layout features of JVx and comes with a default menu and login mechanism. It's designed as standalone app and also as library. This means that you can easily extend the library and create your own app.

Requirements
Flutter dev environment
Java 6 or later (for the JVx application)
A JVx application, running on a Java application (Jetty, Tomcat, ...) server, using JVx mobile UI
Build
We use Visual Studio Code and Android Studio for Development. Simply clone our repository, open the project and get flutter packages (flutter pub get).

Run
We recommend that you use the client as library and create your own app. We have an example here.

Following dependency is required in your pubspec.yaml:

jvx_flutterclient:
    git:
    url: https://github.com/sibvisions/flutterclient.git
It's also possible to use the app itself - standalone and not as library. You have the choice.