import 'package:thetale_api/src/api.dart';
import 'package:thetale_api/src/models.dart';
import 'package:thetale_api/src/session.dart';

/// This class stores the logic of when the client should store or use the [SessionInfo]
/// You should use [TaleApi] for more direct access to the API
class TaleApiWrapper {
  TaleApiWrapper(this.api, this.apiUrl);

  final TaleApi api;
  final String apiUrl;

  SessionStorage _storage;

  Future<Map<String, String>> getHeaders() async {
    return createHeadersFromSession(apiUrl, await _storage.readSession());
  }

  void setStorage(SessionStorage storage) {
    _storage = storage;
  }

  Future<TaleResponse<ApiInfo>> apiInfo() async {
    var taleResponse = await api.apiInfo();
    await _storage.addSession(taleResponse.sessionInfo);

    return taleResponse;
  }

  Future<ThirdPartyLink> auth(
    String applicationName,
    String applicationInfo,
    String applicationDescription,
  ) async {
      return api.auth(headers: await getHeaders(), 
        applicationName: applicationName, 
        applicationInfo: applicationInfo,
        applicationDescription: applicationDescription);
  }

  Future<TaleResponse<ThirdPartyStatus>> authStatus() async {
    var sessionPair = await api.authStatus(headers: await getHeaders());
    if (sessionPair.data.isAccepted) {
      await _storage.updateSession(sessionPair.sessionInfo);
    }

    return sessionPair;
  }

  Future<GameInfo> gameInfo() async {
    return api.gameInfo(headers: await getHeaders());
  } 

  Future<PendingOperation> help() async {
    return api.help(headers: await getHeaders());
  } 

  Future<PendingOperation> checkOperation(String pendingUrl) async {
      return api.checkOperation(pendingUrl, headers: await getHeaders());
  }

  Future<CardList> getCards() async {
    return api.getCards(headers: await getHeaders());
  }
}

class WrapperBuilder {
  TaleApiWrapper build([
    String apiUrl,
    String applicationId,
    String appVersion,
  ]) {
    return TaleApiWrapper(
        TaleApi(
            apiUrl: apiUrl,
            applicationId: applicationId,
            appVersion: appVersion),
        apiUrl);
  }
}
