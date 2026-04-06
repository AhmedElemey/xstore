class VerifyOtpParams {
  const VerifyOtpParams({
    required this.verificationId,
    required this.otpCode,
    this.phoneNumber = '',
  });

  final String verificationId;
  final String otpCode;
  final String phoneNumber;
}
