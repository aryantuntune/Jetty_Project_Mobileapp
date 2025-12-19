import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/customer.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Registration - Step 1: Send OTP
  static Future<ApiResponse> sendOTP({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    return await ApiService.post(
      ApiConfig.registerSendOtp,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'mobile': mobile,
        'password': password,
      },
      requiresAuth: false,
    );
  }

  // Registration - Step 2: Verify OTP and complete registration
  static Future<ApiResponse<Map<String, dynamic>>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConfig.registerVerifyOtp,
      body: {
        'email': email,
        'otp': otp,
      },
      requiresAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  // Login
  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post<Map<String, dynamic>>(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
      requiresAuth: false,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      await _saveAuthData(response.data!);
    }

    return response;
  }

  // Helper to save auth data from login/register responses
  static Future<void> _saveAuthData(Map<String, dynamic> data) async {
    // Server returns: { token: "...", customer: {...} }
    final token = data['token']?.toString();
    final customerData = data['customer'];

    if (token != null && token.isNotEmpty) {
      await StorageService.saveToken(token);
    }

    if (customerData != null && customerData is Map<String, dynamic>) {
      final customer = Customer.fromJson(customerData);
      await StorageService.saveCustomerId(customer.id);
    }
  }

  // Logout
  static Future<ApiResponse> logout() async {
    // Note: Server uses GET for logout
    final response = await ApiService.get(ApiConfig.logout);

    // Always clear local storage regardless of server response
    await StorageService.clearAll();

    return response.success
        ? response
        : ApiResponse(success: true, message: 'Logged out locally');
  }

  // Get Profile
  static Future<ApiResponse<Customer>> getProfile() async {
    return await ApiService.get<Customer>(
      ApiConfig.profile,
      fromJson: (data) => Customer.fromJson(data as Map<String, dynamic>),
    );
  }

  // Update Profile
  static Future<ApiResponse<Customer>> updateProfile({
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    return await ApiService.put<Customer>(
      ApiConfig.updateProfile,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'mobile': mobile,
      },
      fromJson: (data) => Customer.fromJson(data as Map<String, dynamic>),
    );
  }

  // Password Reset - Step 1: Request OTP
  static Future<ApiResponse> requestPasswordResetOTP({
    required String email,
  }) async {
    return await ApiService.post(
      ApiConfig.forgotPasswordRequestOtp,
      body: {'email': email},
      requiresAuth: false,
    );
  }

  // Password Reset - Step 2: Verify OTP
  static Future<ApiResponse> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    return await ApiService.post(
      ApiConfig.forgotPasswordVerifyOtp,
      body: {
        'email': email,
        'otp': otp,
      },
      requiresAuth: false,
    );
  }

  // Password Reset - Step 3: Reset Password
  static Future<ApiResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    return await ApiService.post(
      ApiConfig.resetPassword,
      body: {
        'email': email,
        'otp': otp,
        'password': password,
      },
      requiresAuth: false,
    );
  }

  // Check if user is logged in
  static bool isLoggedIn() {
    return StorageService.isLoggedIn();
  }
}
