class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.message = '',
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic)? fromJsonT) {
    // Handle success field - can be bool or missing
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] == true || json['success'] == 1;
    } else {
      // If no success field, check if data exists (common pattern)
      isSuccess = json.containsKey('data') && json['data'] != null;
    }

    // Handle message field
    String msg = '';
    if (json['message'] != null) {
      msg = json['message'].toString();
    } else if (json['error'] != null) {
      msg = json['error'].toString();
    }

    // Handle data field
    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (e) {
        print('Error parsing data: $e');
      }
    }

    // Handle errors field
    List<String>? errorList;
    if (json['errors'] != null) {
      if (json['errors'] is List) {
        errorList = List<String>.from(json['errors'].map((e) => e.toString()));
      } else if (json['errors'] is Map) {
        // Laravel validation errors come as Map
        errorList = [];
        (json['errors'] as Map).forEach((key, value) {
          if (value is List) {
            errorList!.addAll(value.map((e) => e.toString()));
          } else {
            errorList!.add(value.toString());
          }
        });
      }
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: msg,
      data: parsedData,
      errors: errorList,
    );
  }

  @override
  String toString() => 'ApiResponse(success: $success, message: $message, hasData: ${data != null})';
}
