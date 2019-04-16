class SessionInfo {
  SessionInfo(this.sessionId, this.csrfToken);

  final String sessionId;
  final String csrfToken;
}

abstract class SessionStorage {

  void addSession(SessionInfo sessionInfo);

  void updateSession(SessionInfo sessionInfo);

  SessionInfo readSession();
}

Map<String, String> createHeadersFromSession(
    String apiUrl, SessionInfo session) {
  return {
    "Referer": apiUrl,
    "X-CSRFToken": session.csrfToken,
    "Cookie": "csrftoken=${session.csrfToken}; sessionid=${session.sessionId}",
  };
}
