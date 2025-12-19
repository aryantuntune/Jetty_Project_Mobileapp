import '../config/api_config.dart';
import '../models/api_response.dart';
import '../models/branch.dart';
import '../models/ferry.dart';
import '../models/item_rate.dart';
import '../models/booking.dart';
import 'api_service.dart';

class BookingService {
  // Get all branches
  static Future<ApiResponse<List<Branch>>> getBranches() async {
    return await ApiService.get<List<Branch>>(
      ApiConfig.branches,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => Branch.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  // Get destination branches for a given from-branch
  static Future<ApiResponse<List<Branch>>> getDestinations(int branchId) async {
    final response = await ApiService.get<List<Branch>>(
      ApiConfig.getToBranches(branchId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => Branch.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );

    // Server might return plain array without wrapper
    return response;
  }

  // Get ferries for a branch
  static Future<ApiResponse<List<Ferry>>> getFerries({required int branchId}) async {
    return await ApiService.get<List<Ferry>>(
      ApiConfig.getFerries(branchId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => Ferry.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  // Get item rates for a branch
  static Future<ApiResponse<List<ItemRate>>> getItemRates({required int branchId}) async {
    return await ApiService.get<List<ItemRate>>(
      ApiConfig.getItemRates(branchId),
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => ItemRate.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  // Create a new booking
  static Future<ApiResponse<Booking>> createBooking({
    required int ferryId,
    required int fromBranchId,
    required int toBranchId,
    required String bookingDate,
    required String departureTime,
    required List<Map<String, dynamic>> items,
  }) async {
    return await ApiService.post<Booking>(
      ApiConfig.bookings,
      body: {
        'ferry_id': ferryId,
        'from_branch_id': fromBranchId,
        'to_branch_id': toBranchId,
        'booking_date': bookingDate,
        'departure_time': departureTime,
        'items': items,
      },
      fromJson: (data) => Booking.fromJson(data as Map<String, dynamic>),
    );
  }

  // Get all bookings for the logged-in customer
  static Future<ApiResponse<List<Booking>>> getBookings() async {
    return await ApiService.get<List<Booking>>(
      ApiConfig.bookings,
      fromJson: (data) {
        if (data is List) {
          return data.map((item) => Booking.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }

  // Get a single booking by ID
  static Future<ApiResponse<Booking>> getBookingById(int id) async {
    return await ApiService.get<Booking>(
      ApiConfig.getBooking(id),
      fromJson: (data) => Booking.fromJson(data as Map<String, dynamic>),
    );
  }

  // Cancel a booking
  static Future<ApiResponse> cancelBooking(int id) async {
    return await ApiService.post(ApiConfig.cancelBooking(id));
  }
}
