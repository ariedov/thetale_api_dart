import 'dart:io';

import 'package:http/http.dart';
import 'package:thetale_api/thetale_api.dart';

const String apiUrl = "https://the-tale.org";
const String applicationId = "epic_tale_api_example";
const String appVersion = "0.0.1";

const String applicationName = "Название приложения";
const String applicationInfo = "Информация о приложении";
const String applicationDescription = "Описание приложения";

main() async {
  final wrapper = WrapperBuilder().build(apiUrl, applicationId, appVersion);
  wrapper.setStorage(LocalSessionStorage());

  final info = await wrapper.apiInfo();
  stdout.write("Session id: ${info.sessionInfo.sessionId}");

  final thirdPartyLink = await wrapper.auth(
      applicationName, applicationInfo, applicationDescription);
  stdout.writeln(
      "Authorize application by following the link: ${apiUrl}${thirdPartyLink.authorizationPage}");

  TaleResponse<ThirdPartyStatus> status;
  do {
    sleep(Duration(seconds: 25));
    status = await wrapper.authStatus();
  } while (!status.data.isAccepted);

  stdout.writeln("Ну привет, ${status.data.accountName}");
  final gameInfo = await wrapper.gameInfo();
  stdout.writeln("${gameInfo.account.hero.base.name} уже заждался.");
}

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
