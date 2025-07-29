enum ResponseStatus {
  ok(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  forbidden(403),
  notFound(404),
  internalServerError(500);

  final int code;
  const ResponseStatus(this.code);
}

sealed class ApiResponse {
  final bool success;
  final ResponseStatus status;
  final String message;

  const ApiResponse({
    required this.success,
    required this.status,
    required this.message,
  });

  Map<String, dynamic> toJson();
}

class SuccessResponse<T> extends ApiResponse {
  final T? data;

  const SuccessResponse({
    required ResponseStatus status,
    required String message,
    this.data,
  }) : super(success: true, status: status, message: message);

  @override
  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status.code,
    "message": message,
    if (data != null) "data": data,
  };

  factory SuccessResponse.ok({String message = "Request successful", T? data}) {
    return SuccessResponse(status: ResponseStatus.ok, message: message, data: data);
  }

  factory SuccessResponse.created({String message = "Resource created", T? data}) {
    return SuccessResponse(status: ResponseStatus.created, message: message, data: data);
  }

  factory SuccessResponse.noContent({String message = "No content"}) {
    return SuccessResponse(status: ResponseStatus.noContent, message: message, data: null);
  }
}

class ErrorResponse extends ApiResponse {
  final Map<String, String>? errors;

  const ErrorResponse({
    ResponseStatus status = ResponseStatus.internalServerError,
    required String message,
    this.errors,
  }) : super(success: false, status: status, message: message);

  @override
  Map<String, dynamic> toJson() => {
    "success": success,
    "status": status.code,
    "message": message,
    if (errors != null) "errors": errors,
  };

  factory ErrorResponse.badRequest({String message = "Bad request", Map<String, String>? errors}) {
    return ErrorResponse(status: ResponseStatus.badRequest, message: message, errors: errors);
  }

  factory ErrorResponse.unauthorized({String message = "Unauthorized"}) {
    return ErrorResponse(status: ResponseStatus.unauthorized, message: message);
  }

  factory ErrorResponse.forbidden({String message = "Forbidden"}) {
    return ErrorResponse(status: ResponseStatus.forbidden, message: message);
  }

  factory ErrorResponse.notFound({String message = "Not found"}) {
    return ErrorResponse(status: ResponseStatus.notFound, message: message);
  }

  factory ErrorResponse.internalServerError({String message = "Internal server error"}) {
    return ErrorResponse(status: ResponseStatus.internalServerError, message: message);
  }
}