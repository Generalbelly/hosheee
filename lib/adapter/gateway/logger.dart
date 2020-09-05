import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:wish_list/domain/models/logger.dart' as i_logger;

class Logger implements i_logger.Logger {

  final HttpsCallable _callable = CloudFunctions.instance.getHttpsCallable(
    functionName: 'writeLog',
  );

  log(String message, Object payload) async {
    await _callable.call(<String, dynamic>{
      'message': message,
      'payload': payload,
    });
  }

  info(String message, Object payload) async {
    await _callable.call(<String, dynamic>{
      'severity': 'INFO',
      'message': message,
      'payload': payload,
    });
  }

  error(String message, Object payload) async {
    await _callable.call(<String, dynamic>{
      'severity': 'ERROR',
      'message': message,
      'payload': payload,
    });
  }

  warn(String message, Object payload) async {
    await _callable.call(<String, dynamic>{
      'severity': 'WARNING',
      'message': message,
      'payload': payload,
    });
  }

  debug(String message, Object payload) async {
    await _callable.call(<String, dynamic>{
      'severity': 'DEBUG',
      'message': message,
      'payload': payload,
    });
  }

}
