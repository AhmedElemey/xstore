/// Wire body for `POST /api/notifications/device-token`.
class RegisterDeviceTokenRequest {
  const RegisterDeviceTokenRequest({required this.token});

  final String token;

  Map<String, dynamic> toJson() => {'token': token};
}
