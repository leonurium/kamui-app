import 'package:dio/dio.dart';

class CurlGenerator {
  /// Generate a curl command from Dio RequestOptions
  static String generateCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();
    
    // Start with curl command
    buffer.write('curl');
    
    // Add method (default is GET)
    if (options.method != 'GET') {
      buffer.write(' -X ${options.method}');
    }
    
    // Add URL
    buffer.write(' "${options.uri}"');
    
    // Add headers
    if (options.headers.isNotEmpty) {
      for (final entry in options.headers.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Skip null values
        if (value == null) continue;
        
        // Handle different header formats
        if (key.toLowerCase() == 'content-type' && value.toString().contains('application/json')) {
          buffer.write(' -H "Content-Type: application/json"');
        } else {
          buffer.write(' -H "$key: $value"');
        }
      }
    }
    
    // Add data/body for POST, PUT, PATCH requests
    if (options.data != null && ['POST', 'PUT', 'PATCH'].contains(options.method)) {
      if (options.data is String) {
        buffer.write(' -d "${options.data}"');
      } else if (options.data is Map) {
        // Convert map to JSON string
        final jsonData = _mapToJsonString(options.data as Map);
        buffer.write(' -d \'$jsonData\'');
      } else {
        buffer.write(' -d "${options.data}"');
      }
    }
    
    // Add query parameters if they exist in URL
    if (options.queryParameters.isNotEmpty) {
      final queryString = options.queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      buffer.write(' -G -d "$queryString"');
    }
    
    return buffer.toString();
  }
  
  /// Convert a Map to a JSON string, handling nested structures
  static String _mapToJsonString(Map map) {
    try {
      // Simple JSON conversion - for more complex cases, you might want to use jsonEncode
      final entries = map.entries.map((e) => '"${e.key}": "${e.value}"').join(', ');
      return '{$entries}';
    } catch (e) {
      return map.toString();
    }
  }
  
  /// Generate a more readable curl command with line breaks
  static String generateReadableCurlCommand(RequestOptions options) {
    final buffer = StringBuffer();
    
    // Start with curl command
    buffer.writeln('curl \\');
    
    // Add method (default is GET)
    if (options.method != 'GET') {
      buffer.writeln('  -X ${options.method} \\');
    }
    
    // Add URL
    buffer.writeln('  "${options.uri}" \\');
    
    // Add headers
    if (options.headers.isNotEmpty) {
      for (final entry in options.headers.entries) {
        final key = entry.key;
        final value = entry.value;
        
        // Skip null values
        if (value == null) continue;
        
        // Handle different header formats
        if (key.toLowerCase() == 'content-type' && value.toString().contains('application/json')) {
          buffer.writeln('  -H "Content-Type: application/json" \\');
        } else {
          buffer.writeln('  -H "$key: $value" \\');
        }
      }
    }
    
    // Add data/body for POST, PUT, PATCH requests
    if (options.data != null && ['POST', 'PUT', 'PATCH'].contains(options.method)) {
      if (options.data is String) {
        buffer.writeln('  -d "${options.data}" \\');
      } else if (options.data is Map) {
        // Convert map to JSON string
        final jsonData = _mapToJsonString(options.data as Map);
        buffer.writeln('  -d \'$jsonData\' \\');
      } else {
        buffer.writeln('  -d "${options.data}" \\');
      }
    }
    
    // Add query parameters if they exist in URL
    if (options.queryParameters.isNotEmpty) {
      final queryString = options.queryParameters.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      buffer.writeln('  -G -d "$queryString" \\');
    }
    
    // Remove the last backslash and newline
    final result = buffer.toString().trim();
    return result.endsWith('\\') ? result.substring(0, result.length - 1).trim() : result;
  }
} 