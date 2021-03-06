import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:thetale_api/src/models.dart';
import 'package:thetale_api/src/converters.dart';
import 'package:thetale_api/src/session.dart';

class TaleApi {
  TaleApi({this.apiUrl, this.applicationId, this.appVersion});

  final String apiUrl;
  final String applicationId;
  final String appVersion;

  http.Client client = http.Client();

  Future<TaleResponse<ApiInfo>> apiInfo() async {
    const method = "/api/info";
    final response = await client.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion");

    print("Headers: ${response.headers}");
    print("Body: ${response.body}");

    return TaleResponse(readSessionFromHeader(response.headers),
        _processResponse<ApiInfo>(response.body, convertApiInfo));
  }

  Future<ThirdPartyLink> auth({
      Map<String, String> headers,
      String applicationName,
      String applicationInfo, 
      String applicationDescription,
  }) async {
    const method = "/accounts/third-party/tokens/api/request-authorisation";

    final response = await client.post(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers,
        body: {
          "application_name": applicationName,
          "application_info": applicationInfo,
          "application_description": applicationDescription,
        });

    return _processResponse<ThirdPartyLink>(
        response.body, convertThirdPartyLink);
  }

  Future<TaleResponse<ThirdPartyStatus>> authStatus(
      {Map<String, String> headers}) async {
    const method = "/accounts/third-party/tokens/api/authorisation-state";

    final response = await client.get(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers);

    return TaleResponse(readSessionFromHeader(response.headers),
        _processResponse(response.body, convertThirdPartyStatus));
  }

  Future<GameInfo> gameInfo({Map<String, String> headers}) async {
    const method = "/game/api/info";
    final response = await client.get(
        "$apiUrl/$method?api_version=1.9&api_client=$applicationId-$appVersion",
        headers: headers);

    return _processResponse(response.body, convertGameInfo);
  }

  Future<PendingOperation> help({Map<String, String> headers}) async {
    const method = "/game/abilities/help/api/use";
    final response = await client.post(
        "$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion",
        headers: headers);

    final operation = convertOperation(json.decode(response.body));
    if (operation.isError) {
      throw Exception(operation.error);
    }
    return operation;
  }

  Future<PendingOperation> checkOperation(String pendingUrl,
      {Map<String, String> headers}) async {
    final response = await client.get("$apiUrl/$pendingUrl", headers: headers);

    return _processResponse(response.body, convertOperation);
  }

  Future<CardList> getCards({Map<String, String> headers}) async {
    const method = "/game/cards/api/get-cards";
    final response = await http.get("$apiUrl/$method?api_version=2.0&api_client=$applicationId-$appVersion", headers: headers);
    return _processResponse(response.body, convertCardList);
  }

  Future<ReceivedCardList> receiveNewCards({Map<String, String> headers}) async {
    const method = "/game/cards/api/receive";
    final response = await http.post("$apiUrl/$method?api_version=1.0&api_client=$applicationId-$appVersion", headers: headers);
    return _processResponse(response.body, convertReceivedCardList);
  }
  
  T _processResponse<T>(String body, T converter(dynamic json)) {
    final bodyJson = json.decode(body);
    final taleResponse = convertResponse(bodyJson, converter);

    if (taleResponse.isError) {
      throw taleResponse.error ?? "Что-то пошло не так";
    }
    return taleResponse.data;
  }
}

SessionInfo readSessionFromHeader(Map<String, String> headers) {
  final cookie = headers["set-cookie"];
  print("Set Cookie: $cookie");
  return readSessionInfo(cookie);
}

SessionInfo readSessionInfo(String cookie) {
  final sessionRegex = RegExp(r"sessionid=(\w+);");

  final sessionMatch = sessionRegex.firstMatch(cookie);
  String session;
  if (sessionMatch != null) {
    session = sessionMatch.group(1);
  }

  final csrfRegex = RegExp(r"csrftoken=(\w+);");

  final csrfMatch = csrfRegex.firstMatch(cookie);
  String csrf;
  if (csrfMatch != null) {
    csrf = csrfMatch.group(1);
  }

  return SessionInfo(session, csrf);
}

class TaleResponse<T> {
  TaleResponse(this.sessionInfo, this.data);

  final SessionInfo sessionInfo;
  final T data;
}
