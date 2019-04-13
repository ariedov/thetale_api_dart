import 'package:test/test.dart';
import 'package:thetale_api/src/api.dart';
import 'package:thetale_api/src/models.dart';
import 'package:thetale_api/src/session.dart';
import 'package:mockito/mockito.dart';
import 'package:thetale_api/src/wrapper.dart';

void main() {
  MockSessionStorage sessionStorage;
  MockApi api;

  setUp(() {
    sessionStorage = MockSessionStorage();
    api = MockApi();
  });

  test("api info save session test", () async {
    when(api.apiInfo()).thenAnswer((_) => Future(() => SessionDataPair(null, null)));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.apiInfo();

    verify(api.apiInfo());
    verify(sessionStorage.storeSession(any));
  });

  test("auth read header test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.auth();

    verify(api.auth(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });

  test("auth status unaccepted test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var mockStatus = ThirdPartyStatus("", 0, "", 0, /* unaccepted */ 1);
    when(api.authStatus(headers: anyNamed("headers"))).thenAnswer((_) => Future(() => SessionDataPair(null, mockStatus)));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.authStatus();

    verify(api.authStatus(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
    verifyNever(sessionStorage.storeSession(any)); 
  });

  test("auth status accepted test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var mockStatus = ThirdPartyStatus("", 0, "", 0, /* accepted */ 2);
    when(api.authStatus(headers: anyNamed("headers"))).thenAnswer((_) => Future(() => SessionDataPair(null, mockStatus)));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.authStatus();

    verify(api.authStatus(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
    verify(sessionStorage.storeSession(any)); 
  });

  test("auth game info header test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.gameInfo();

    verify(api.gameInfo(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });

  test("auth help header test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.help();

    verify(api.help(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });

  test("auth check operation header test", () async {
    when(sessionStorage.readSession()).thenReturn(SessionInfo("sessionId", "csrfToken"));
    var wrapper = TaleApiWrapper(sessionStorage, api, "");

    await wrapper.checkOperation("help");

    verify(api.checkOperation("help", headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });
}

class MockSessionStorage extends Mock implements SessionStorage {
}

class MockApi extends Mock implements TaleApi {
}