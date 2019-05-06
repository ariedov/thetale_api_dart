import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:thetale_api/src/api.dart';

import 'utils.dart';

void main() {
  TaleApi api;

  setUp(() {
    api = TaleApi(
        apiUrl: "https://the-tale.org",
        applicationId: "applicationId",
        appVersion: "appVersion");
  });

  test("test help error", () {
    api.client = MockClient((request) async {
      final payload = readFileAsString("test/resources/help_error.json");
      return Response(payload, 200);
    });

    expect(api.help(), throwsException);
  });

  test("test help success", () async {
    api.client = MockClient((request) async {
      final payload = readFileAsString("test/resources/help.json");
      return Response(payload, 200);
    });

    var operation = await api.help();
    expect(operation.isError, false);
    expect(operation.isProcessing, true);
  });
}
