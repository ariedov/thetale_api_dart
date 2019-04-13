import 'package:thetale_api/src/api.dart';
import 'package:thetale_api/src/models.dart';
import 'package:thetale_api/src/session.dart';

/// This class stores the logic of when the client should store or use the [SessionInfo]
/// You should use [TaleApi] for more direct access to the API
class TaleApiWrapper {
  TaleApiWrapper(this.storage, this.api, this.apiUrl);

  final SessionStorage storage;
  final TaleApi api;
  final String apiUrl;

  Map<String, String> get headers 
    => createHeadersFromSession(apiUrl, storage.readSession());

  Future<ApiInfo> apiInfo() async {
    var sessionPair = await api.apiInfo();
    storage.storeSession(sessionPair.sessionInfo);

    return sessionPair.data;
  }

  Future<ThirdPartyLink> auth() => api.auth(headers: headers);
  
  Future<ThirdPartyStatus> authStatus() async {
    var sessionPair = await api.authStatus(headers: headers);
    if (sessionPair.data.isAccepted) {
      storage.storeSession(sessionPair.sessionInfo);
    }

    return sessionPair.data;
  }

  Future<GameInfo> gameInfo() => api.gameInfo(headers: headers);

  Future<PendingOperation> help() => api.help(headers: headers);

  Future<PendingOperation> checkOperation(String pendingUrl) => api.checkOperation(pendingUrl, headers: headers);
}

