import 'package:besocial_app/core/network/api_envelope.dart';
import 'package:besocial_app/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiEnvelope', () {
    test('decodes a success envelope', () {
      final json = {
        'success': true,
        'data': {'hello': 'world'},
        'error': null,
      };
      final env = ApiEnvelope<Map<String, dynamic>>.fromJson(
        json,
        (j) => j as Map<String, dynamic>,
      );
      expect(env.success, isTrue);
      expect(env.data, {'hello': 'world'});
      expect(env.error, isNull);
    });

    test('decodes an error envelope', () {
      final json = {
        'success': false,
        'data': null,
        'error': {'message': 'nope', 'code': 'INVALID_TOKEN'},
      };
      final env = ApiEnvelope<Object>.fromJson(json, (j) => j as Object);
      expect(env.success, isFalse);
      expect(env.data, isNull);
      expect(env.error?.code, 'INVALID_TOKEN');
      expect(env.error?.message, 'nope');
    });
  });

  group('ApiException', () {
    test('fromEnvelope copies code + message', () {
      final ex = ApiException.fromEnvelope(
        const ApiError(message: 'gone', code: 'POST_NOT_FOUND'),
        httpStatus: 404,
      );
      expect(ex.code, 'POST_NOT_FOUND');
      expect(ex.message, 'gone');
      expect(ex.httpStatus, 404);
      expect(ex.isTransport, isFalse);
    });

    test('synthetic CLIENT_* codes are transport-level', () {
      const ex = ApiException(
        code: ApiException.codeTimeout,
        message: 'slow',
      );
      expect(ex.isTransport, isTrue);
    });
  });
}
