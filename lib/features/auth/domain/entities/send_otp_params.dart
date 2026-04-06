class SendOtpParams {
  const SendOtpParams({
    required this.phoneNumber,
    required this.e164Number,
  });

  final String phoneNumber;
  final String e164Number;
}
