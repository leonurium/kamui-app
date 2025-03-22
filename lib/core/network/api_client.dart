import 'package:dio/dio.dart';
import '../utils/signature.dart';
import '../config/constants.dart';
import '../utils/device_info.dart';
import '../utils/logger.dart';

class ApiClient {
  late Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));
    
    _setupInterceptors();
  }
  
  Future<void> _setupInterceptors() async {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add common headers
          final deviceId = await DeviceInfoUtil.getDeviceId();
          final signature = await Signature.generate();
          
          options.headers['Device-ID'] = deviceId;
          options.headers['Signature'] = signature;
          options.headers['X-API-KEY'] = Constants.apiKey;
          options.headers['Content-Type'] = 'application/json';
          
          Logger.debug("[REQUEST] ${options.uri}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Logger.debug('[RESPONSE] [${response.statusCode}] ${response.data.toString()}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          Logger.error('${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
  
  Dio get dio => _dio;
}