# Flutter Client

The Flutter Client is a mobile app for the [JVx framework](https://doc.sibvisions.com/jvx). It's super generic and renders work-screens dynamically. The app supports all layout features of JVx and comes with a default menu and login mechanism. It's designed as standalone app and also as library. This means that you can easily extend the library and create your own app.

# Requirements

- [Flutter dev environment](https://flutter.dev/docs/get-started/install)
- Java 6 or later (for the JVx application)
- A JVx application, running on a Java application (Jetty, Tomcat, ...) server, using [JVx mobile UI](https://sourceforge.net/projects/jvxmobile/)

# Build

We use [Visual Studio Code](https://code.visualstudio.com/) and [Android Studio](https://developer.android.com/studio) for Development. Simply clone our repository, open the project and get flutter packages (flutter pub get).

# Run

We recommend that you use the client as library and create your own app. We have an example [here](../../../flutterclient.example).

Following dependency is required in your pubspec.yaml:

    flutterclient:
        git:
        url: https://github.com/sibvisions/flutterclient.git


It's also possible to use the app itself - standalone and not as library. You have the choice.

Currently not all packages we use are migrated to null-safety,
therefore you'll need `--no-sound-null-safety` as an additional argument.

## VSCode

In .vscode/launch.json your configuration should look like this:

```
    {
        "name": "Flutter",
        "request": "launch",
        "type": "dart",
        "args": [
            "--no-sound-null-safety"
        ]
    }
```

## Android Studio

In Android Studio add `--no-sound-null-safety` to Configurations -> Edit Configuration -> Additional Arguments.

## Terminal command

`flutter run --no-sound-null-safety`