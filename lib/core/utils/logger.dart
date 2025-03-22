import 'dart:developer' as developer;
import 'package:flutter/material.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static LogLevel logLevel = LogLevel.debug;

  static void _log(LogLevel level, String message, bool useEmoji) {
    if (!_shouldLog(level)) return;

    final stackTrace = StackTrace.current;
    final String fileName = _getCallerFile(stackTrace);
    final int lineNumber = _getCallerLine(stackTrace);
    final String emoji = _emojiForLevel(level);
    final String levelText = useEmoji ? emoji : '[${level.name.toUpperCase()}]';
    final String currentTime = _currentFormattedTime();
    
    final String logMessage =
        '$levelText [$currentTime] [$fileName:$lineNumber] - $message';

    debugPrint(logMessage);
    developer.log(logMessage, name: 'Logger');
  }

  static bool _shouldLog(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return logLevel == LogLevel.debug;
      case LogLevel.info:
        return logLevel == LogLevel.debug || logLevel == LogLevel.info;
      case LogLevel.warning:
        return logLevel == LogLevel.debug || logLevel == LogLevel.info || logLevel == LogLevel.warning;
      case LogLevel.error:
        return true;
    }
  }

  static String _emojiForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  static String _currentFormattedTime() {
    final now = DateTime.now();
    return '${now.year}-'
        '${_twoDigits(now.month)}-'
        '${_twoDigits(now.day)} '
        '${_twoDigits(now.hour)}:'
        '${_twoDigits(now.minute)}:'
        '${_twoDigits(now.second)}';
  }

  static String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }

  static String _getCallerFile(StackTrace stackTrace) {
    try {
      final traceLines = stackTrace.toString().split("\n");
      final targetLine = traceLines.length > 2 ? traceLines[2] : traceLines.last;
      final match = RegExp(r'(\w+\.dart)').firstMatch(targetLine);
      return match?.group(1) ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  static int _getCallerLine(StackTrace stackTrace) {
    try {
      final traceLines = stackTrace.toString().split("\n");
      final targetLine = traceLines.length > 2 ? traceLines[2] : traceLines.last;
      final match = RegExp(r':(\d+):').firstMatch(targetLine);
      return int.tryParse(match?.group(1) ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // Public Logging Methods
  static void debug(String message, { bool useEmoji = true }) => _log(LogLevel.debug, message, useEmoji);
  static void info(String message, { bool useEmoji = true }) => _log(LogLevel.info, message, useEmoji);
  static void warning(String message, { bool useEmoji = true }) => _log(LogLevel.warning, message, useEmoji);
  static void error(String message, { bool useEmoji = true }) => _log(LogLevel.error, message, useEmoji);
}
