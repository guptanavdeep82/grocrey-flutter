import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/api_response_model.dart';
import 'package:flutter_grocery/common/models/error_response_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';
import 'package:flutter_grocery/features/auth/screens/login_screen.dart';
import 'package:provider/provider.dart';

class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    ErrorResponseModel error = getError(apiResponse);

    if((error.errors?[0].code == '401' || error.errors![0].code == 'auth-001' &&  ModalRoute.of(Get.context!)?.settings.name != RouteHelper.getLoginRoute())) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }else {
      final raw = error.errors?.first.message;
      if (_friendlyMessage(raw) == 'server_busy_try_again') {
        return;
      }
      showCustomSnackBarHelper(getTranslated(raw, Get.context!));
    }
  }

  static String _friendlyMessage(String? raw) {
    final text = (raw ?? '').toLowerCase();
    if (text.contains('internal server')
        || text.contains('sqlstate')
        || text.contains('operation not permitted')
        || text.contains('server-busy')
        || text.contains('server is busy')
        || text.contains('server_busy_try_again')
        || text.contains('connection refused')
        || text.contains('oauth_access_tokens')
        || text.contains('queryexception')
        || text.contains('failed to load data - status code: 5')
        || text.contains('<html')
        || text.contains('whoops')) {
      return 'server_busy_try_again';
    }
    return raw ?? 'Something went wrong';
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse){
    ErrorResponseModel error;

    try{
      error = ErrorResponseModel.fromJson(apiResponse.response?.data);
    }catch(e){
      if(apiResponse.error != null && apiResponse.error is Map){
        error = ErrorResponseModel.fromJson(apiResponse.error);
      }else{
        error = ErrorResponseModel(errors: [Errors(code: '', message: apiResponse.error.toString())]);
      }
    }

    if(error.errors == null || error.errors!.isEmpty) {
      error = ErrorResponseModel(errors: [Errors(code: '', message: apiResponse.error?.toString() ?? 'Something went wrong')]);
    }

    return error;
  }
}