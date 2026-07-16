// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoginState {
  String get phone => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  bool get rememberMe => throw _privateConstructorUsedError;
  bool get isPasswordVisible => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginStateCopyWith<LoginState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginStateCopyWith<$Res> {
  factory $LoginStateCopyWith(
          LoginState value, $Res Function(LoginState) then) =
      _$LoginStateCopyWithImpl<$Res, LoginState>;
  @useResult
  $Res call(
      {String phone,
      String password,
      bool rememberMe,
      bool isPasswordVisible,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$LoginStateCopyWithImpl<$Res, $Val extends LoginState>
    implements $LoginStateCopyWith<$Res> {
  _$LoginStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? password = null,
    Object? rememberMe = null,
    Object? isPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginStateImplCopyWith<$Res>
    implements $LoginStateCopyWith<$Res> {
  factory _$$LoginStateImplCopyWith(
          _$LoginStateImpl value, $Res Function(_$LoginStateImpl) then) =
      __$$LoginStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String phone,
      String password,
      bool rememberMe,
      bool isPasswordVisible,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$LoginStateImplCopyWithImpl<$Res>
    extends _$LoginStateCopyWithImpl<$Res, _$LoginStateImpl>
    implements _$$LoginStateImplCopyWith<$Res> {
  __$$LoginStateImplCopyWithImpl(
      _$LoginStateImpl _value, $Res Function(_$LoginStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phone = null,
    Object? password = null,
    Object? rememberMe = null,
    Object? isPasswordVisible = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$LoginStateImpl(
      phone: null == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      rememberMe: null == rememberMe
          ? _value.rememberMe
          : rememberMe // ignore: cast_nullable_to_non_nullable
              as bool,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoginStateImpl implements _LoginState {
  const _$LoginStateImpl(
      {this.phone = '',
      this.password = '',
      this.rememberMe = false,
      this.isPasswordVisible = false,
      this.isLoading = false,
      this.error});

  @override
  @JsonKey()
  final String phone;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final bool rememberMe;
  @override
  @JsonKey()
  final bool isPasswordVisible;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'LoginState(phone: $phone, password: $password, rememberMe: $rememberMe, isPasswordVisible: $isPasswordVisible, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginStateImpl &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.rememberMe, rememberMe) ||
                other.rememberMe == rememberMe) &&
            (identical(other.isPasswordVisible, isPasswordVisible) ||
                other.isPasswordVisible == isPasswordVisible) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phone, password, rememberMe,
      isPasswordVisible, isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginStateImplCopyWith<_$LoginStateImpl> get copyWith =>
      __$$LoginStateImplCopyWithImpl<_$LoginStateImpl>(this, _$identity);
}

abstract class _LoginState implements LoginState {
  const factory _LoginState(
      {final String phone,
      final String password,
      final bool rememberMe,
      final bool isPasswordVisible,
      final bool isLoading,
      final String? error}) = _$LoginStateImpl;

  @override
  String get phone;
  @override
  String get password;
  @override
  bool get rememberMe;
  @override
  bool get isPasswordVisible;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$LoginStateImplCopyWith<_$LoginStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegisterState {
  int get currentStep => throw _privateConstructorUsedError;
  int get totalSteps => throw _privateConstructorUsedError;
  UserRole? get selectedRole => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String get fullNameAr => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String get countryCode => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get confirmPassword => throw _privateConstructorUsedError;
  bool get isPasswordVisible => throw _privateConstructorUsedError;
  bool get isConfirmPasswordVisible => throw _privateConstructorUsedError;
  PasswordStrength get passwordStrength => throw _privateConstructorUsedError;
  bool get agreedToTerms => throw _privateConstructorUsedError;
  String get storeName => throw _privateConstructorUsedError;
  String get storeNameAr => throw _privateConstructorUsedError;
  String get storeSlug => throw _privateConstructorUsedError;
  String get storeCategory => throw _privateConstructorUsedError;
  String get storeDescription => throw _privateConstructorUsedError;
  String get storeDescriptionAr => throw _privateConstructorUsedError;
  String? get storeLogoPath => throw _privateConstructorUsedError;
  String get storeCity => throw _privateConstructorUsedError;
  String get storeWilaya => throw _privateConstructorUsedError;
  int? get storeCategoryId => throw _privateConstructorUsedError;
  int? get storeCityId => throw _privateConstructorUsedError;
  int? get storeGovernmentId => throw _privateConstructorUsedError;
  String get whatsappNumber => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Map<String, String> get stepErrors => throw _privateConstructorUsedError;
  bool get showVendorSuccessOverlay => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RegisterStateCopyWith<RegisterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterStateCopyWith<$Res> {
  factory $RegisterStateCopyWith(
          RegisterState value, $Res Function(RegisterState) then) =
      _$RegisterStateCopyWithImpl<$Res, RegisterState>;
  @useResult
  $Res call(
      {int currentStep,
      int totalSteps,
      UserRole? selectedRole,
      String fullName,
      String fullNameAr,
      String email,
      String phoneNumber,
      String countryCode,
      DateTime? dateOfBirth,
      String location,
      String password,
      String confirmPassword,
      bool isPasswordVisible,
      bool isConfirmPasswordVisible,
      PasswordStrength passwordStrength,
      bool agreedToTerms,
      String storeName,
      String storeNameAr,
      String storeSlug,
      String storeCategory,
      String storeDescription,
      String storeDescriptionAr,
      String? storeLogoPath,
      String storeCity,
      String storeWilaya,
      int? storeCategoryId,
      int? storeCityId,
      int? storeGovernmentId,
      String whatsappNumber,
      bool isLoading,
      String? error,
      Map<String, String> stepErrors,
      bool showVendorSuccessOverlay});
}

/// @nodoc
class _$RegisterStateCopyWithImpl<$Res, $Val extends RegisterState>
    implements $RegisterStateCopyWith<$Res> {
  _$RegisterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? totalSteps = null,
    Object? selectedRole = freezed,
    Object? fullName = null,
    Object? fullNameAr = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? countryCode = null,
    Object? dateOfBirth = freezed,
    Object? location = null,
    Object? password = null,
    Object? confirmPassword = null,
    Object? isPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? passwordStrength = null,
    Object? agreedToTerms = null,
    Object? storeName = null,
    Object? storeNameAr = null,
    Object? storeSlug = null,
    Object? storeCategory = null,
    Object? storeDescription = null,
    Object? storeDescriptionAr = null,
    Object? storeLogoPath = freezed,
    Object? storeCity = null,
    Object? storeWilaya = null,
    Object? storeCategoryId = freezed,
    Object? storeCityId = freezed,
    Object? storeGovernmentId = freezed,
    Object? whatsappNumber = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? stepErrors = null,
    Object? showVendorSuccessOverlay = null,
  }) {
    return _then(_value.copyWith(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      selectedRole: freezed == selectedRole
          ? _value.selectedRole
          : selectedRole // ignore: cast_nullable_to_non_nullable
              as UserRole?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameAr: null == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      confirmPassword: null == confirmPassword
          ? _value.confirmPassword
          : confirmPassword // ignore: cast_nullable_to_non_nullable
              as String,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfirmPasswordVisible: null == isConfirmPasswordVisible
          ? _value.isConfirmPasswordVisible
          : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordStrength: null == passwordStrength
          ? _value.passwordStrength
          : passwordStrength // ignore: cast_nullable_to_non_nullable
              as PasswordStrength,
      agreedToTerms: null == agreedToTerms
          ? _value.agreedToTerms
          : agreedToTerms // ignore: cast_nullable_to_non_nullable
              as bool,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      storeNameAr: null == storeNameAr
          ? _value.storeNameAr
          : storeNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      storeSlug: null == storeSlug
          ? _value.storeSlug
          : storeSlug // ignore: cast_nullable_to_non_nullable
              as String,
      storeCategory: null == storeCategory
          ? _value.storeCategory
          : storeCategory // ignore: cast_nullable_to_non_nullable
              as String,
      storeDescription: null == storeDescription
          ? _value.storeDescription
          : storeDescription // ignore: cast_nullable_to_non_nullable
              as String,
      storeDescriptionAr: null == storeDescriptionAr
          ? _value.storeDescriptionAr
          : storeDescriptionAr // ignore: cast_nullable_to_non_nullable
              as String,
      storeLogoPath: freezed == storeLogoPath
          ? _value.storeLogoPath
          : storeLogoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCity: null == storeCity
          ? _value.storeCity
          : storeCity // ignore: cast_nullable_to_non_nullable
              as String,
      storeWilaya: null == storeWilaya
          ? _value.storeWilaya
          : storeWilaya // ignore: cast_nullable_to_non_nullable
              as String,
      storeCategoryId: freezed == storeCategoryId
          ? _value.storeCategoryId
          : storeCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeCityId: freezed == storeCityId
          ? _value.storeCityId
          : storeCityId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeGovernmentId: freezed == storeGovernmentId
          ? _value.storeGovernmentId
          : storeGovernmentId // ignore: cast_nullable_to_non_nullable
              as int?,
      whatsappNumber: null == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stepErrors: null == stepErrors
          ? _value.stepErrors
          : stepErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      showVendorSuccessOverlay: null == showVendorSuccessOverlay
          ? _value.showVendorSuccessOverlay
          : showVendorSuccessOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterStateImplCopyWith<$Res>
    implements $RegisterStateCopyWith<$Res> {
  factory _$$RegisterStateImplCopyWith(
          _$RegisterStateImpl value, $Res Function(_$RegisterStateImpl) then) =
      __$$RegisterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStep,
      int totalSteps,
      UserRole? selectedRole,
      String fullName,
      String fullNameAr,
      String email,
      String phoneNumber,
      String countryCode,
      DateTime? dateOfBirth,
      String location,
      String password,
      String confirmPassword,
      bool isPasswordVisible,
      bool isConfirmPasswordVisible,
      PasswordStrength passwordStrength,
      bool agreedToTerms,
      String storeName,
      String storeNameAr,
      String storeSlug,
      String storeCategory,
      String storeDescription,
      String storeDescriptionAr,
      String? storeLogoPath,
      String storeCity,
      String storeWilaya,
      int? storeCategoryId,
      int? storeCityId,
      int? storeGovernmentId,
      String whatsappNumber,
      bool isLoading,
      String? error,
      Map<String, String> stepErrors,
      bool showVendorSuccessOverlay});
}

/// @nodoc
class __$$RegisterStateImplCopyWithImpl<$Res>
    extends _$RegisterStateCopyWithImpl<$Res, _$RegisterStateImpl>
    implements _$$RegisterStateImplCopyWith<$Res> {
  __$$RegisterStateImplCopyWithImpl(
      _$RegisterStateImpl _value, $Res Function(_$RegisterStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? totalSteps = null,
    Object? selectedRole = freezed,
    Object? fullName = null,
    Object? fullNameAr = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? countryCode = null,
    Object? dateOfBirth = freezed,
    Object? location = null,
    Object? password = null,
    Object? confirmPassword = null,
    Object? isPasswordVisible = null,
    Object? isConfirmPasswordVisible = null,
    Object? passwordStrength = null,
    Object? agreedToTerms = null,
    Object? storeName = null,
    Object? storeNameAr = null,
    Object? storeSlug = null,
    Object? storeCategory = null,
    Object? storeDescription = null,
    Object? storeDescriptionAr = null,
    Object? storeLogoPath = freezed,
    Object? storeCity = null,
    Object? storeWilaya = null,
    Object? storeCategoryId = freezed,
    Object? storeCityId = freezed,
    Object? storeGovernmentId = freezed,
    Object? whatsappNumber = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? stepErrors = null,
    Object? showVendorSuccessOverlay = null,
  }) {
    return _then(_$RegisterStateImpl(
      currentStep: null == currentStep
          ? _value.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      selectedRole: freezed == selectedRole
          ? _value.selectedRole
          : selectedRole // ignore: cast_nullable_to_non_nullable
              as UserRole?,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      fullNameAr: null == fullNameAr
          ? _value.fullNameAr
          : fullNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: freezed == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      confirmPassword: null == confirmPassword
          ? _value.confirmPassword
          : confirmPassword // ignore: cast_nullable_to_non_nullable
              as String,
      isPasswordVisible: null == isPasswordVisible
          ? _value.isPasswordVisible
          : isPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isConfirmPasswordVisible: null == isConfirmPasswordVisible
          ? _value.isConfirmPasswordVisible
          : isConfirmPasswordVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      passwordStrength: null == passwordStrength
          ? _value.passwordStrength
          : passwordStrength // ignore: cast_nullable_to_non_nullable
              as PasswordStrength,
      agreedToTerms: null == agreedToTerms
          ? _value.agreedToTerms
          : agreedToTerms // ignore: cast_nullable_to_non_nullable
              as bool,
      storeName: null == storeName
          ? _value.storeName
          : storeName // ignore: cast_nullable_to_non_nullable
              as String,
      storeNameAr: null == storeNameAr
          ? _value.storeNameAr
          : storeNameAr // ignore: cast_nullable_to_non_nullable
              as String,
      storeSlug: null == storeSlug
          ? _value.storeSlug
          : storeSlug // ignore: cast_nullable_to_non_nullable
              as String,
      storeCategory: null == storeCategory
          ? _value.storeCategory
          : storeCategory // ignore: cast_nullable_to_non_nullable
              as String,
      storeDescription: null == storeDescription
          ? _value.storeDescription
          : storeDescription // ignore: cast_nullable_to_non_nullable
              as String,
      storeDescriptionAr: null == storeDescriptionAr
          ? _value.storeDescriptionAr
          : storeDescriptionAr // ignore: cast_nullable_to_non_nullable
              as String,
      storeLogoPath: freezed == storeLogoPath
          ? _value.storeLogoPath
          : storeLogoPath // ignore: cast_nullable_to_non_nullable
              as String?,
      storeCity: null == storeCity
          ? _value.storeCity
          : storeCity // ignore: cast_nullable_to_non_nullable
              as String,
      storeWilaya: null == storeWilaya
          ? _value.storeWilaya
          : storeWilaya // ignore: cast_nullable_to_non_nullable
              as String,
      storeCategoryId: freezed == storeCategoryId
          ? _value.storeCategoryId
          : storeCategoryId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeCityId: freezed == storeCityId
          ? _value.storeCityId
          : storeCityId // ignore: cast_nullable_to_non_nullable
              as int?,
      storeGovernmentId: freezed == storeGovernmentId
          ? _value.storeGovernmentId
          : storeGovernmentId // ignore: cast_nullable_to_non_nullable
              as int?,
      whatsappNumber: null == whatsappNumber
          ? _value.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      stepErrors: null == stepErrors
          ? _value._stepErrors
          : stepErrors // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      showVendorSuccessOverlay: null == showVendorSuccessOverlay
          ? _value.showVendorSuccessOverlay
          : showVendorSuccessOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$RegisterStateImpl implements _RegisterState {
  const _$RegisterStateImpl(
      {this.currentStep = 1,
      this.totalSteps = 3,
      this.selectedRole,
      this.fullName = '',
      this.fullNameAr = '',
      this.email = '',
      this.phoneNumber = '',
      this.countryCode = '+20',
      this.dateOfBirth,
      this.location = '',
      this.password = '',
      this.confirmPassword = '',
      this.isPasswordVisible = false,
      this.isConfirmPasswordVisible = false,
      this.passwordStrength = PasswordStrength.none,
      this.agreedToTerms = false,
      this.storeName = '',
      this.storeNameAr = '',
      this.storeSlug = '',
      this.storeCategory = '',
      this.storeDescription = '',
      this.storeDescriptionAr = '',
      this.storeLogoPath,
      this.storeCity = '',
      this.storeWilaya = '',
      this.storeCategoryId,
      this.storeCityId,
      this.storeGovernmentId,
      this.whatsappNumber = '',
      this.isLoading = false,
      this.error,
      final Map<String, String> stepErrors = const {},
      this.showVendorSuccessOverlay = false})
      : _stepErrors = stepErrors;

  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final int totalSteps;
  @override
  final UserRole? selectedRole;
  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String fullNameAr;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phoneNumber;
  @override
  @JsonKey()
  final String countryCode;
  @override
  final DateTime? dateOfBirth;
  @override
  @JsonKey()
  final String location;
  @override
  @JsonKey()
  final String password;
  @override
  @JsonKey()
  final String confirmPassword;
  @override
  @JsonKey()
  final bool isPasswordVisible;
  @override
  @JsonKey()
  final bool isConfirmPasswordVisible;
  @override
  @JsonKey()
  final PasswordStrength passwordStrength;
  @override
  @JsonKey()
  final bool agreedToTerms;
  @override
  @JsonKey()
  final String storeName;
  @override
  @JsonKey()
  final String storeNameAr;
  @override
  @JsonKey()
  final String storeSlug;
  @override
  @JsonKey()
  final String storeCategory;
  @override
  @JsonKey()
  final String storeDescription;
  @override
  @JsonKey()
  final String storeDescriptionAr;
  @override
  final String? storeLogoPath;
  @override
  @JsonKey()
  final String storeCity;
  @override
  @JsonKey()
  final String storeWilaya;
  @override
  final int? storeCategoryId;
  @override
  final int? storeCityId;
  @override
  final int? storeGovernmentId;
  @override
  @JsonKey()
  final String whatsappNumber;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final Map<String, String> _stepErrors;
  @override
  @JsonKey()
  Map<String, String> get stepErrors {
    if (_stepErrors is EqualUnmodifiableMapView) return _stepErrors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stepErrors);
  }

  @override
  @JsonKey()
  final bool showVendorSuccessOverlay;

  @override
  String toString() {
    return 'RegisterState(currentStep: $currentStep, totalSteps: $totalSteps, selectedRole: $selectedRole, fullName: $fullName, fullNameAr: $fullNameAr, email: $email, phoneNumber: $phoneNumber, countryCode: $countryCode, dateOfBirth: $dateOfBirth, location: $location, password: $password, confirmPassword: $confirmPassword, isPasswordVisible: $isPasswordVisible, isConfirmPasswordVisible: $isConfirmPasswordVisible, passwordStrength: $passwordStrength, agreedToTerms: $agreedToTerms, storeName: $storeName, storeNameAr: $storeNameAr, storeSlug: $storeSlug, storeCategory: $storeCategory, storeDescription: $storeDescription, storeDescriptionAr: $storeDescriptionAr, storeLogoPath: $storeLogoPath, storeCity: $storeCity, storeWilaya: $storeWilaya, storeCategoryId: $storeCategoryId, storeCityId: $storeCityId, storeGovernmentId: $storeGovernmentId, whatsappNumber: $whatsappNumber, isLoading: $isLoading, error: $error, stepErrors: $stepErrors, showVendorSuccessOverlay: $showVendorSuccessOverlay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            (identical(other.selectedRole, selectedRole) ||
                other.selectedRole == selectedRole) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.fullNameAr, fullNameAr) ||
                other.fullNameAr == fullNameAr) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword) &&
            (identical(other.isPasswordVisible, isPasswordVisible) ||
                other.isPasswordVisible == isPasswordVisible) &&
            (identical(
                    other.isConfirmPasswordVisible, isConfirmPasswordVisible) ||
                other.isConfirmPasswordVisible == isConfirmPasswordVisible) &&
            (identical(other.passwordStrength, passwordStrength) ||
                other.passwordStrength == passwordStrength) &&
            (identical(other.agreedToTerms, agreedToTerms) ||
                other.agreedToTerms == agreedToTerms) &&
            (identical(other.storeName, storeName) ||
                other.storeName == storeName) &&
            (identical(other.storeNameAr, storeNameAr) ||
                other.storeNameAr == storeNameAr) &&
            (identical(other.storeSlug, storeSlug) ||
                other.storeSlug == storeSlug) &&
            (identical(other.storeCategory, storeCategory) ||
                other.storeCategory == storeCategory) &&
            (identical(other.storeDescription, storeDescription) ||
                other.storeDescription == storeDescription) &&
            (identical(other.storeDescriptionAr, storeDescriptionAr) ||
                other.storeDescriptionAr == storeDescriptionAr) &&
            (identical(other.storeLogoPath, storeLogoPath) ||
                other.storeLogoPath == storeLogoPath) &&
            (identical(other.storeCity, storeCity) ||
                other.storeCity == storeCity) &&
            (identical(other.storeWilaya, storeWilaya) ||
                other.storeWilaya == storeWilaya) &&
            (identical(other.storeCategoryId, storeCategoryId) ||
                other.storeCategoryId == storeCategoryId) &&
            (identical(other.storeCityId, storeCityId) ||
                other.storeCityId == storeCityId) &&
            (identical(other.storeGovernmentId, storeGovernmentId) ||
                other.storeGovernmentId == storeGovernmentId) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._stepErrors, _stepErrors) &&
            (identical(
                    other.showVendorSuccessOverlay, showVendorSuccessOverlay) ||
                other.showVendorSuccessOverlay == showVendorSuccessOverlay));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        currentStep,
        totalSteps,
        selectedRole,
        fullName,
        fullNameAr,
        email,
        phoneNumber,
        countryCode,
        dateOfBirth,
        location,
        password,
        confirmPassword,
        isPasswordVisible,
        isConfirmPasswordVisible,
        passwordStrength,
        agreedToTerms,
        storeName,
        storeNameAr,
        storeSlug,
        storeCategory,
        storeDescription,
        storeDescriptionAr,
        storeLogoPath,
        storeCity,
        storeWilaya,
        storeCategoryId,
        storeCityId,
        storeGovernmentId,
        whatsappNumber,
        isLoading,
        error,
        const DeepCollectionEquality().hash(_stepErrors),
        showVendorSuccessOverlay
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterStateImplCopyWith<_$RegisterStateImpl> get copyWith =>
      __$$RegisterStateImplCopyWithImpl<_$RegisterStateImpl>(this, _$identity);
}

abstract class _RegisterState implements RegisterState {
  const factory _RegisterState(
      {final int currentStep,
      final int totalSteps,
      final UserRole? selectedRole,
      final String fullName,
      final String fullNameAr,
      final String email,
      final String phoneNumber,
      final String countryCode,
      final DateTime? dateOfBirth,
      final String location,
      final String password,
      final String confirmPassword,
      final bool isPasswordVisible,
      final bool isConfirmPasswordVisible,
      final PasswordStrength passwordStrength,
      final bool agreedToTerms,
      final String storeName,
      final String storeNameAr,
      final String storeSlug,
      final String storeCategory,
      final String storeDescription,
      final String storeDescriptionAr,
      final String? storeLogoPath,
      final String storeCity,
      final String storeWilaya,
      final int? storeCategoryId,
      final int? storeCityId,
      final int? storeGovernmentId,
      final String whatsappNumber,
      final bool isLoading,
      final String? error,
      final Map<String, String> stepErrors,
      final bool showVendorSuccessOverlay}) = _$RegisterStateImpl;

  @override
  int get currentStep;
  @override
  int get totalSteps;
  @override
  UserRole? get selectedRole;
  @override
  String get fullName;
  @override
  String get fullNameAr;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  String get countryCode;
  @override
  DateTime? get dateOfBirth;
  @override
  String get location;
  @override
  String get password;
  @override
  String get confirmPassword;
  @override
  bool get isPasswordVisible;
  @override
  bool get isConfirmPasswordVisible;
  @override
  PasswordStrength get passwordStrength;
  @override
  bool get agreedToTerms;
  @override
  String get storeName;
  @override
  String get storeNameAr;
  @override
  String get storeSlug;
  @override
  String get storeCategory;
  @override
  String get storeDescription;
  @override
  String get storeDescriptionAr;
  @override
  String? get storeLogoPath;
  @override
  String get storeCity;
  @override
  String get storeWilaya;
  @override
  int? get storeCategoryId;
  @override
  int? get storeCityId;
  @override
  int? get storeGovernmentId;
  @override
  String get whatsappNumber;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  Map<String, String> get stepErrors;
  @override
  bool get showVendorSuccessOverlay;
  @override
  @JsonKey(ignore: true)
  _$$RegisterStateImplCopyWith<_$RegisterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
