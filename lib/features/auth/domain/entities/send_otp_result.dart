class SendOtpResult {
  const SendOtpResult({
    required this.verificationId,
    required this.phoneNumber,
    required this.expiresAt,
    this.resendToken,
    this.autoVerified = false,
    this.debugOtp,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
  final DateTime expiresAt;

  /// `true` when Android auto-retrieval signed the user in before manual OTP entry.
  final bool autoVerified;

  /// The fixed test code accepted by [PhoneAuthDatasource.verifyOtp] under
  /// `MockConfig.useMock` — no real SMS is sent in mock mode. Null on the
  /// real Firebase path (the code is sent to the device, not returned here).
  final String? debugOtp;
}
