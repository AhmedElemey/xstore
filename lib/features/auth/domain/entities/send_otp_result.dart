class SendOtpResult {
  const SendOtpResult({
    required this.verificationId,
    required this.phoneNumber,
    required this.expiresAt,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
  final DateTime expiresAt;
}
