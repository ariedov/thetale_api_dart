# The Tale API

[![Build Status](https://travis-ci.org/ariedov/thetale_api_dart.svg?branch=master)](https://travis-ci.org/ariedov/thetale_api_dart)
[![codecov](https://codecov.io/gh/ariedov/thetale_api_dart/branch/master/graph/badge.svg)](https://codecov.io/gh/ariedov/thetale_api_dart)
[![pub package](https://img.shields.io/pub/v/thetale_api.svg)](https://pub.dartlang.org/packages/thetale_api)

This is an unofficial way to create a basic API for the ZPG https://the-tale.org

### Usage

There are two classes to use `TheTaleApi` and `TheTaleApiWrapper.` The only difference between these two are that `TheTaleApiWrapper` handles the session storing using `SessionStorage.`

If you don't want any code to handle the session stuff, just use `TheTaleApi`.

To create `TheTaleApiWrapper` use the `WrapperBuilder`.

```dart
final wrapper = WrapperBuilder().build(apiUrl, applicationId, appVersion);
wrapper.setStorage(LocalSessionStorage());
```

You have to set the `SessionStorage` to make sure the session with preserve between method calls. There is no `SessionStorage` implementations available, a basic in-memory example would look like this:

```dart
class LocalSessionStorage implements SessionStorage {
  SessionInfo _sessionInfo;

  @override
  Future<void> addSession(SessionInfo sessionInfo) async {
    _sessionInfo = sessionInfo;
  }

  @override
  Future<SessionInfo> readSession() async {
    return _sessionInfo;
  }

  @override
  Future<void> updateSession(SessionInfo sessionInfo) async {
    _sessionInfo = sessionInfo;
  }
}
```

### Specifics

Only a few methods will actually set the session: `apiInfo()` and `authStatus()`. This means that the session will be empty if you don't call `apiInfo()` before any other call.

Please, refer to the [example](example/thetale_api_example.dart) for more details.
