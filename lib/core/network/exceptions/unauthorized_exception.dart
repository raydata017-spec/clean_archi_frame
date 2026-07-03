import 'api_exception.dart';

class UnauthorizedException extends ApiException {
  UnauthorizedException({
    super.statusCode = 401,
    super.message = 'Unauthorized access. Please login again.',
    super.apiError,
  });
}
