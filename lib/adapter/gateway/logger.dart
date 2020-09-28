import 'package:cloud_functions/cloud_functions.dart';
import 'package:hosheee/domain/models/logger.dart' as i_logger;

class Logger implements i_logger.Logger {

  static Logger _instance;

  Logger._internal();

  factory Logger() {
    if (_instance == null) {
      _instance = Logger._internal();
    }
    return _instance;
  }

  log(String message, Object payload) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'writeLog');
    await callable.call(<String, dynamic>{
      'message': message,
      'payload': payload,
    });
  }

  info(String message, Object payload) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'writeLog');
    await callable.call(<String, dynamic>{
      'severity': 'INFO',
      'message': message,
      'payload': payload,
    });
  }

  error(String message, Object payload) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'writeLog');
    await callable.call(<String, dynamic>{
      'severity': 'ERROR',
      'message': message,
      'payload': payload,
    });
  }

  warn(String message, Object payload) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'writeLog');
    await callable.call(<String, dynamic>{
      'severity': 'WARNING',
      'message': message,
      'payload': payload,
    });
  }

  debug(String message, Object payload) async {
    final callable = CloudFunctions(region: 'asia-northeast1').getHttpsCallable(functionName: 'writeLog');
    await callable.call(<String, dynamic>{
      'severity': 'DEBUG',
      'message': message,
      'payload': payload,
    });
  }

}
