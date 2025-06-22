import 'package:dio/dio.dart';
import 'package:kamui_app/data/models/main_response.dart';
import '../utils/signature.dart';
import '../config/constants.dart';
import '../utils/device_info.dart';
import '../utils/logger.dart';
import '../utils/curl_generator.dart';

class ApiClient {
  late Dio _dio;
  late Dio _dynamicDio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: Constants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));
    
    _dynamicDio = Dio(BaseOptions(
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

          if (Constants.networkLogger) {
            // Generate and log curl command
            final curlCommand = CurlGenerator.generateReadableCurlCommand(options);
            Logger.debug("[CURL COMMAND]");
            Logger.info(curlCommand);
            
            Logger.debug("[REQUEST] ${options.uri}");
            Logger.debug("[HEADERS]:");
            for (var header in options.headers.entries) {
              Logger.info("${header.key}: ${header.value}");
            }
            if (options.method == 'POST') {
              Logger.debug("[BODY] ${options.data}");
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if(Constants.networkLogger) {
            Logger.warning('[RESPONSE] [${response.statusCode}] ${response.data.toString()}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final errorResponse = e.response;
          if (errorResponse != null) {
            final mainResponse = MainResponse<String>.fromJson(
              errorResponse.data,
              (json) => json, // Pass identity function for dynamic data
            );
            if(Constants.networkLogger) {
              Logger.warning("[RESPONSE] [${errorResponse.statusCode}] ${mainResponse.message ?? mainResponse.error}");
            }
            handler.resolve(errorResponse);
          } else {
            if(Constants.networkLogger) {
              Logger.error('[ERROR] ${e.message}');
              Logger.error('[ERROR TYPE] ${e.type}');
              if (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout ||
                  e.type == DioExceptionType.sendTimeout) {
                Logger.error('[ERROR] Server timeout - Using mock data');
              }
            }
            return handler.next(e);
          }
        },
      ),
    );
    
    // Setup interceptors for dynamic Dio instance
    _dynamicDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add common headers
          final deviceId = await DeviceInfoUtil.getDeviceId();
          final signature = await Signature.generate();
          
          options.headers['Device-ID'] = deviceId;
          options.headers['Signature'] = signature;
          options.headers['X-API-KEY'] = Constants.apiKey;
          options.headers['Content-Type'] = 'application/json';

          if (Constants.networkLogger) {
            // Generate and log curl command
            final curlCommand = CurlGenerator.generateReadableCurlCommand(options);
            Logger.debug("[CURL COMMAND - DYNAMIC]");
            Logger.info(curlCommand);
            
            Logger.debug("[REQUEST - DYNAMIC] ${options.uri}");
            Logger.debug("[HEADERS - DYNAMIC]:");
            for (var header in options.headers.entries) {
              Logger.info("${header.key}: ${header.value}");
            }
            if (options.method == 'POST') {
              Logger.debug("[BODY - DYNAMIC] ${options.data}");
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if(Constants.networkLogger) {
            Logger.warning('[RESPONSE - DYNAMIC] [${response.statusCode}] ${response.data.toString()}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final errorResponse = e.response;
          if (errorResponse != null) {
            final mainResponse = MainResponse<String>.fromJson(
              errorResponse.data,
              (json) => json, // Pass identity function for dynamic data
            );
            if(Constants.networkLogger) {
              Logger.warning("[RESPONSE - DYNAMIC] [${errorResponse.statusCode}] ${mainResponse.message ?? mainResponse.error}");
            }
            handler.resolve(errorResponse);
          } else {
            if(Constants.networkLogger) {
              Logger.error('[ERROR - DYNAMIC] ${e.message}');
              Logger.error('[ERROR TYPE - DYNAMIC] ${e.type}');
              if (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout ||
                  e.type == DioExceptionType.sendTimeout) {
                Logger.error('[ERROR - DYNAMIC] Server timeout - Using mock data');
              }
            }
            return handler.next(e);
          }
        },
      ),
    );
  }
  
  // Method to create a Dio instance with dynamic base URL
  Dio createDynamicDio(String baseUrl) {
    final dynamicDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ));
    
    // Add the same interceptors
    dynamicDio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add common headers
          final deviceId = await DeviceInfoUtil.getDeviceId();
          final signature = await Signature.generate();
          
          options.headers['Device-ID'] = deviceId;
          options.headers['Signature'] = signature;
          options.headers['X-API-KEY'] = Constants.apiKey;
          options.headers['Content-Type'] = 'application/json';

          if (Constants.networkLogger) {
            // Generate and log curl command
            final curlCommand = CurlGenerator.generateReadableCurlCommand(options);
            Logger.debug("[CURL COMMAND - DYNAMIC]");
            Logger.info(curlCommand);
            
            Logger.debug("[REQUEST - DYNAMIC] ${options.uri}");
            Logger.debug("[HEADERS - DYNAMIC]:");
            for (var header in options.headers.entries) {
              Logger.info("${header.key}: ${header.value}");
            }
            if (options.method == 'POST') {
              Logger.debug("[BODY - DYNAMIC] ${options.data}");
            }
          }
          
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if(Constants.networkLogger) {
            Logger.warning('[RESPONSE - DYNAMIC] [${response.statusCode}] ${response.data.toString()}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final errorResponse = e.response;
          if (errorResponse != null) {
            final mainResponse = MainResponse<String>.fromJson(
              errorResponse.data,
              (json) => json, // Pass identity function for dynamic data
            );
            if(Constants.networkLogger) {
              Logger.warning("[RESPONSE - DYNAMIC] [${errorResponse.statusCode}] ${mainResponse.message ?? mainResponse.error}");
            }
            handler.resolve(errorResponse);
          } else {
            if(Constants.networkLogger) {
              Logger.error('[ERROR - DYNAMIC] ${e.message}');
              Logger.error('[ERROR TYPE - DYNAMIC] ${e.type}');
              if (e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.receiveTimeout ||
                  e.type == DioExceptionType.sendTimeout) {
                Logger.error('[ERROR - DYNAMIC] Server timeout - Using mock data');
              }
            }
            return handler.next(e);
          }
        },
      ),
    );
    
    return dynamicDio;
  }
  
  Dio get dio => _dio;
}