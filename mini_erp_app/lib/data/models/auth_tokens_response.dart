/// OpenAPI: AuthTokensResponseDto
class AuthTokensResponse {
  const AuthTokensResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthTokensResponse.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken']?.toString();
    final refresh = json['refreshToken']?.toString();
    if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
      throw const FormatException('Invalid AuthTokensResponseDto');
    }
    return AuthTokensResponse(accessToken: access, refreshToken: refresh);
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
