import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:thetale_api/src/converters.dart';
import 'package:thetale_api/thetale_api.dart';

void main() {
  test("test parse error", () {
    final payload = readFileAsString("test/resources/wrong_csrf.json");

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyLink);

    expect(response.isError, true);
  });

  test("test api info", () {
    final payload = readFileAsString("test/resources/api_info.json");

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertApiInfo);

    expect(response.status, "ok");
    expect(response.data.gameVersion, "v0.3.27.1");
  });

  test("test third party", () {
    final payload = readFileAsString("test/resources/third_party.json");

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyLink);

    expect(response.isError, false);
    expect(response.data.authorizationPage,
        "/accounts/third-party/tokens/41b21f95-8b4f-41f0-acef-e5ca06edcaf0");
  });

  test("test auth status", () {
    final payload = readFileAsString("test/resources/auth_status.json");

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertThirdPartyStatus);

    expect(response.isError, false);
    expect(response.data.expireAt, 1542405235);
  });

  test("test card list", () {
    final payload = readFileAsString("test/resources/cards.json");

    final payloadJson = json.decode(payload);
    final response = convertResponse(payloadJson, convertCardList);

    expect(response.data.newCards, 0);
    expect(response.data.cards.length, 4);
    expect(response.data.cards[0].uid, "2eb4ac2980df4bbbb4f78f230a144e18");
    expect(response.data.cards[2].uid, "ff8a04bf29e840aab25d27e94fa8c812");
  });

  test("test headers read", () {
    const payload = """
        sessionid=csxqqjj7cyiy9b3mukhzor9z9we9twks; expires=Fri, 16-Nov-2018 16:15:22 GMT; HttpOnly; Max-Age=1209600; Path=/; Secure,csrftoken=PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk; expires=Fri, 01-Nov-2019 16:15:22 GMT; HttpOnly; Max-Age=31449600; Path=/; Secure""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, "csxqqjj7cyiy9b3mukhzor9z9we9twks");
    expect(session.csrfToken,
        "PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk");
  });

  test("test session headers read", () {
    const payload = """
        sessionid=csxqqjj7cyiy9b3mukhzor9z9we9twks; expires=Fri, 16-Nov-2018 16:15:22 GMT; HttpOnly; Max-Age=1209600; Path=/; Secure,""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, "csxqqjj7cyiy9b3mukhzor9z9we9twks");
    expect(session.csrfToken, null);
  });

  test("test csrf headers read", () {
    const payload = """
        csrftoken=PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk; expires=Fri, 01-Nov-2019 16:15:22 GMT; HttpOnly; Max-Age=31449600; Path=/; Secure""";

    final session = readSessionInfo(payload);

    expect(session.sessionId, null);
    expect(session.csrfToken,
        "PVw6ZDIEt2UfcxsWwtdAES9Mwlq7FH7bxoyJMw1YlIj7wc3WhB0rKt6aRhzOkrOk");
  });

  test("test game info", () {
    final payload = readFileAsString("test/resources/game_info.json");

    final jsonPayload = json.decode(payload);
    final gameInfo = convertGameInfo(jsonPayload);
    expect(gameInfo.account.hero.base.name, "Сурен");
  });

  test("test processing operation", () {
    final payload = readFileAsString("test/resources/processing.json");
    final jsonPayload = json.decode(payload);

    final status = convertOperation(jsonPayload);
    expect(status.status, "processing");
    expect(status.statusUrl, "/postponed-tasks/35657544/status");
  });
  
  test("test not authorized", () {
    final payload = readFileAsString("test/resources/not_authorized.json");

    final operation = convertOperation(json.decode(payload));
    expect(operation.isError, true);
    expect(operation.error, "У Вас нет прав для проведения данной операции");
  });
}

String readFileAsString(String name) {
  final file = new File(name);
  return file.readAsStringSync();
}