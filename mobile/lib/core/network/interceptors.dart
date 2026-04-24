import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'interceptors.g.dart';

@riverpod
Interceptor appInterceptor(AppInterceptorRef ref) {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      // Add tokens if needed
      return handler.next(options);
    },
  );
}
