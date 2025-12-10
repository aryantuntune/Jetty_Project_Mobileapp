class ApiConfig {
  // Base URL - Change this to your actual API URL
  static const String baseUrl = 'https://unfurling.ninja/api';

  // API Endpoints
  static const String registerSendOtp = '/customer/register/send-otp';
  static const String registerVerifyOtp = '/customer/register/verify-otp';
  static const String login = '/customer/login';
  static const String logout = '/customer/logout';
  static const String profile = '/customer/profile';

  static const String branches = '/branches';
  static String getDestinations(int branchId) => '/branches/$branchId/destinations';

  static const String ferries = '/ferries';
  static const String itemRates = '/item-rates';
  static String getItemRate(int itemRateId) => '/item-rates/$itemRateId';

  static const String bookings = '/bookings';
  static String getBooking(int bookingId) => '/bookings/$bookingId';
  static String cancelBooking(int bookingId) => '/bookings/$bookingId/cancel';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> headersWithToken(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
