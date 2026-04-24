import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'interceptors.dart';

part 'dio_client.g.dart';

@riverpod
Dio dioClient(DioClientRef ref) {
  final dio = Dio();
  dio.interceptors.add(ref.watch(appInterceptorProvider));
  return dio;
}
