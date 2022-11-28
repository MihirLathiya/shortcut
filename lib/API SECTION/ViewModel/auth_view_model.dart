import 'package:get/get.dart';
import 'package:hotlinecafee/model/repo/auth_repo.dart';
import 'package:hotlinecafee/model/response_model/reset_password_res_model.dart';
import 'package:hotlinecafee/model/response_model/send_forgot_otp_res_model.dart';
import 'package:hotlinecafee/model/response_model/sign_up_res_model.dart';
import 'package:hotlinecafee/model/response_model/social_login_res_model.dart';
import 'package:hotlinecafee/model/response_model/username_res_model.dart';
import 'package:hotlinecafee/model/response_model/verify_forgot_otp_res_model.dart';
import 'package:hotlinecafee/model/response_model/verify_sign_up_otp_res_model.dart';

import '../common/snackbar.dart';
import '../model/apis/api_response.dart';
import '../model/response_model/forgot_password_res_model.dart';
import '../model/response_model/gender_selection_res_model.dart';
import '../model/response_model/login_res_model.dart';

class AuthViewModel extends GetxController {
  /// SOCIAL LOGIN
  ApiResponse _socialApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get socialApiResponse => _socialApiResponse;

  Future<void> socialLoginViewModel({Map<String, dynamic>? model}) async {
    _socialApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      SocialloginResponseModel socialResponse =
          await AuthRepo().socialLoginRepo(body: model);
      print("SocialloginResponseModel=response==>$socialResponse");

      _socialApiResponse = ApiResponse.complete(socialResponse);
    } catch (e) {
      print("SocialloginResponseModel=e==>$e");

      _socialApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// SIGN UP
  ApiResponse _signUpApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get signUpApiResponse => _signUpApiResponse;

  Future<void> signUpViewModel({Map<String, dynamic>? model}) async {
    _signUpApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      SignUpResponseModel response = await AuthRepo().signUpRepo(body: model);
      print("SignUpViewModel=response==>$response");

      _signUpApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("SignUpViewModel=e==>$e");
      CommonSnackBar.commonSnackBar(message: "Number Already Used.");
      _signUpApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// SignUp OTP
  ApiResponse _signOtpApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get signOtpApiResponse => _signOtpApiResponse;

  Future<void> signUpOtpViewModel({Map<String, dynamic>? model}) async {
    _signOtpApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      VerifySignUpOtpResponseModel response =
          await AuthRepo().otpRepo(body: model);
      print("OtpViewModel=response==>$response");

      _signOtpApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("OtpViewModel=e==>$e");
      _signOtpApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// Username
  ApiResponse _userNameApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get userNameApiResponse => _userNameApiResponse;

  Future<void> userNameViewModel({Map<String, dynamic>? model}) async {
    _userNameApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      UserNameResponseModel response =
          await AuthRepo().userNameRepo(body: model);
      print("OtpViewModel=response==>$response");

      _userNameApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("OtpViewModel=e==>$e");
      _userNameApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// LOG IN

  ApiResponse _logInApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get logInApiResponse => _logInApiResponse;

  Future<void> loginViewModel({Map<String, dynamic>? model}) async {
    _logInApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      LoginResponseModel response = await AuthRepo().loginRepo(body: model);
      print("LoginViewModel=response==>$response");

      _logInApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("LoginViewModel=e==>$e");
      _logInApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// SELECT GENDER
  ApiResponse _genderSelectApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get genderSelectApiResponse => _genderSelectApiResponse;

  Future<void> genderSectionViewModel({Map<String, dynamic>? model}) async {
    _genderSelectApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      GenderSelectionResponseModel response =
          await AuthRepo().genderSelectionRepo(body: model);
      print("GenderSectionViewModel=response==>$response");

      _genderSelectApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("GenderSectionViewModel=e==>$e");
      _genderSelectApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  String _gender = "";

  String get genderSelect => _gender;

  set genderSelect(String value) {
    _gender = value;
    update();
  }

  /// FORGOT PASSWORD
  ApiResponse _forgotPassApiResponse =
      ApiResponse.initial(message: 'Initialization');
  ApiResponse get forgotPassApiResponse => _forgotPassApiResponse;
  Future<void> forgotPasswordViewModel({Map<String, dynamic>? model}) async {
    _forgotPassApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      ForgotPasswordResponseModel response =
          await AuthRepo().forgotPasswordRepo(body: model);
      print("ForgotPasswordRepo=response==>$response");

      _forgotPassApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("ForgotPasswordRepo=e==>$e");
      _forgotPassApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// SEND FORGOT OTP
  ApiResponse _sendForgotOtpApiResponse =
      ApiResponse.initial(message: 'Initialization');
  ApiResponse get sendForgotOtpApiResponse => _sendForgotOtpApiResponse;
  Future<void> sendForgotOtpViewModel({Map<String, dynamic>? model}) async {
    _forgotPassApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      SendForgotOtpResponseModel response =
          await AuthRepo().sendForgotOtpRepo(body: model);
      print("SendForgotOtpResponseModel=response==>$response");

      _sendForgotOtpApiResponse = ApiResponse.complete(response);
    } catch (e) {
      print("SendForgotOtpResponseModel=e==>$e");
      _sendForgotOtpApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// Verify FORGOT OTP
  ApiResponse _verifyForgotOtpApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get verifyForgotOtpApiResponse => _verifyForgotOtpApiResponse;

  Future<void> verifyForgotOtpViewModel({Map<String, dynamic>? model}) async {
    _verifyForgotOtpApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      VerifyForgotOtpResponseModel resModel =
          await AuthRepo().verifyForgotOtpRepo(body: model);
      print("VerifyForgotOtpResModel=response==>$resModel");

      _verifyForgotOtpApiResponse = ApiResponse.complete(resModel);
    } catch (e) {
      print("VerifyForgotOtpResModel=e==>$e");
      _verifyForgotOtpApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }

  /// RESET PASSWORD
  ApiResponse _resetPassApiResponse =
      ApiResponse.initial(message: 'Initialization');

  ApiResponse get resetPassApiResponse => _resetPassApiResponse;

  Future<void> resetPasswordViewModel({Map<String, dynamic>? model}) async {
    _resetPassApiResponse = ApiResponse.loading(message: 'Loading');
    update();
    try {
      ResetPasswordResModel resModel =
          await AuthRepo().resetPasswordRepo(body: model);
      print("ResetPasswordResModel=response==>$resModel");

      _resetPassApiResponse = ApiResponse.complete(resModel);
    } catch (e) {
      print("ResetPasswordResModel=e==>$e");
      _resetPassApiResponse = ApiResponse.error(message: 'error');
    }
    update();
  }
}
