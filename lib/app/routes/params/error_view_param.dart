import 'package:flutter/foundation.dart';

class ErrorViewParam {
  final Object? error;
  final FlutterErrorDetails? flutterError;
  final StackTrace? stackTrace;
  final String? message;

  ErrorViewParam({this.error, this.flutterError, this.stackTrace, this.message});
}
