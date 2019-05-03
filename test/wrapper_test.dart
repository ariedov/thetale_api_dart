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
    when(api.apiInfo()).thenAnswer((_) => Future(() => TaleResponse(null, null)));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.apiInfo();

    verify(api.apiInfo());
    verify(sessionStorage.addSession(any));
  });

  test("auth read header test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.auth("", "", "");

    verify(api.auth(headers: anyNamed("headers"), applicationName: "", applicationInfo: "", applicationDescription: ""));
    verify(sessionStorage.readSession());
  });

  test("auth status unaccepted test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var mockStatus = ThirdPartyStatus("", 0, "", 0, /* unaccepted */ 1);
    when(api.authStatus(headers: anyNamed("headers"))).thenAnswer((_) => Future(() => TaleResponse(null, mockStatus)));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.authStatus();

    verify(api.authStatus(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
    verifyNever(sessionStorage.addSession(any)); 
  });

  test("auth status accepted test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var mockStatus = ThirdPartyStatus("", 0, "", 0, /* accepted */ 2);
    when(api.authStatus(headers: anyNamed("headers"))).thenAnswer((_) => Future(() => TaleResponse(null, mockStatus)));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.authStatus();

    verify(api.authStatus(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
    verify(sessionStorage.updateSession(any)); 
  });

  test("auth game info header test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.gameInfo();

    verify(api.gameInfo(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });

  test("help header test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.help();

    verify(api.help(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });

  test("cards header test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.getCards();

    verify(api.getCards(headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });


  test("auth check operation header test", () async {
    when(sessionStorage.readSession()).thenAnswer((_) => Future(() => (SessionInfo("sessionId", "csrfToken"))));
    var wrapper = TaleApiWrapper(api, "");
    wrapper.setStorage(sessionStorage);

    await wrapper.checkOperation("help");

    verify(api.checkOperation("help", headers: anyNamed("headers")));
    verify(sessionStorage.readSession());
  });
}

class MockSessionStorage extends Mock implements SessionStorage {
}

class MockApi extends Mock implements TaleApi {
}