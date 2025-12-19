import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/app_colors.dart';
import '../models/branch.dart';
import '../models/ferry.dart';
import '../models/item_rate.dart';
import '../services/booking_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_overlay.dart';
import 'booking_success_screen.dart';

class RouteSelectionScreen extends StatefulWidget {
  const RouteSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  List<Branch> _branches = [];
  List<Branch> _destinations = [];
  List<Ferry> _ferries = [];
  List<ItemRate> _itemRates = [];

  Branch? _selectedFromBranch;
  Branch? _selectedToBranch;
  Ferry? _selectedFerry;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Map to track quantity for each item rate
  Map<int, int> _itemQuantities = {};

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await BookingService.getBranches();

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _branches = response.data!;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _loadDestinations(int branchId) async {
    setState(() => _isLoading = true);

    final response = await BookingService.getDestinations(branchId);

    setState(() {
      _isLoading = false;
      if (response.success && response.data != null) {
        _destinations = response.data!;
      } else {
        _destinations = [];
      }
    });
  }

  Future<void> _loadFerriesAndRates(int branchId) async {
    setState(() => _isLoading = true);

    final ferriesResponse = await BookingService.getFerries(branchId: branchId);
    final itemsResponse = await BookingService.getItemRates(branchId: branchId);

    setState(() {
      _isLoading = false;
      if (ferriesResponse.success && ferriesResponse.data != null) {
        _ferries = ferriesResponse.data!;
      }
      if (itemsResponse.success && itemsResponse.data != null) {
        _itemRates = itemsResponse.data!;
        // Reset quantities
        _itemQuantities = {};
      }
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  double _calculateTotal() {
    double total = 0;
    for (final item in _itemRates) {
      final qty = _itemQuantities[item.id] ?? 0;
      total += item.price * qty;
    }
    return total;
  }

  bool _hasSelectedItems() {
    return _itemQuantities.values.any((qty) => qty > 0);
  }

  Future<void> _handleBooking() async {
    // Validation
    if (_selectedFromBranch == null) {
      _showError('Please select starting point');
      return;
    }
    if (_selectedToBranch == null) {
      _showError('Please select destination');
      return;
    }
    if (_selectedFerry == null) {
      _showError('Please select a ferry');
      return;
    }
    if (_selectedDate == null) {
      _showError('Please select a date');
      return;
    }
    if (_selectedTime == null) {
      _showError('Please select a time');
      return;
    }
    if (!_hasSelectedItems()) {
      _showError('Please select at least one item');
      return;
    }

    setState(() => _isLoading = true);

    // Build items list
    final items = <Map<String, dynamic>>[];
    _itemQuantities.forEach((itemRateId, quantity) {
      if (quantity > 0) {
        items.add({
          'item_rate_id': itemRateId,
          'quantity': quantity,
        });
      }
    });

    final response = await BookingService.createBooking(
      ferryId: _selectedFerry!.id,
      fromBranchId: _selectedFromBranch!.id,
      toBranchId: _selectedToBranch!.id,
      bookingDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
      departureTime: '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00',
      items: items,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success && response.data != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingSuccessScreen(booking: response.data!),
        ),
      );
    } else {
      _showError(response.message.isNotEmpty ? response.message : 'Booking failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Book Ferry Ticket'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: _errorMessage != null
            ? _buildErrorView()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with gradient
                    _buildHeader(),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Route Details Card
                          _buildRouteCard(),

                          const SizedBox(height: 20),

                          // Ferry & Schedule Card
                          _buildScheduleCard(),

                          const SizedBox(height: 20),

                          // Items Card (Dynamic from server)
                          _buildItemsCard(),

                          const SizedBox(height: 24),

                          // Total Amount Card
                          _buildTotalCard(),

                          const SizedBox(height: 24),

                          // Confirm Button
                          CustomButton(
                            text: 'Confirm Booking',
                            onPressed: _handleBooking,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadBranches,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_boat, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            'Select Your Route',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard() {
    return _buildModernCard(
      title: 'Route Details',
      icon: Icons.route_rounded,
      child: Column(
        children: [
          _buildDropdown<Branch>(
            value: _selectedFromBranch,
            label: 'From',
            hint: 'Select starting point',
            icon: Icons.my_location_rounded,
            items: _branches,
            itemBuilder: (branch) => branch.name,
            onChanged: (branch) {
              setState(() {
                _selectedFromBranch = branch;
                _selectedToBranch = null;
                _selectedFerry = null;
                _destinations = [];
                _ferries = [];
                _itemRates = [];
                _itemQuantities = {};
              });
              if (branch != null) {
                _loadDestinations(branch.id);
                _loadFerriesAndRates(branch.id);
              }
            },
          ),
          const SizedBox(height: 20),
          _buildDropdown<Branch>(
            value: _selectedToBranch,
            label: 'To',
            hint: 'Select destination',
            icon: Icons.location_on_rounded,
            items: _destinations,
            itemBuilder: (branch) => branch.name,
            onChanged: (branch) {
              setState(() => _selectedToBranch = branch);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _buildModernCard(
      title: 'Ferry & Schedule',
      icon: Icons.calendar_today_rounded,
      child: Column(
        children: [
          _buildDropdown<Ferry>(
            value: _selectedFerry,
            label: 'Select Ferry',
            hint: 'Choose ferry',
            icon: Icons.directions_boat_rounded,
            items: _ferries,
            itemBuilder: (ferry) => '${ferry.name} (${ferry.capacity} seats)',
            onChanged: (ferry) {
              setState(() => _selectedFerry = ferry);
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeSelector(
                  label: 'Date',
                  value: _selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                      : 'Select Date',
                  icon: Icons.calendar_month_rounded,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateTimeSelector(
                  label: 'Time',
                  value: _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'Select Time',
                  icon: Icons.access_time_rounded,
                  onTap: _selectTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return _buildModernCard(
      title: 'Tickets & Items',
      icon: Icons.confirmation_number_rounded,
      child: _itemRates.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Select a starting point to see available items',
                style: TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: _itemRates.map((item) {
                final qty = _itemQuantities[item.id] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildItemCounter(
                    item.itemName,
                    '₹${item.price.toStringAsFixed(0)}',
                    _getIconForItem(item.itemName),
                    qty,
                    (value) => setState(() => _itemQuantities[item.id] = value),
                  ),
                );
              }).toList(),
            ),
    );
  }

  IconData _getIconForItem(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('adult') || name.contains('person')) {
      return Icons.person_rounded;
    } else if (name.contains('child') || name.contains('kid')) {
      return Icons.child_care_rounded;
    } else if (name.contains('senior') || name.contains('elder')) {
      return Icons.elderly_rounded;
    } else if (name.contains('vehicle') || name.contains('car') || name.contains('bike')) {
      return Icons.directions_car_rounded;
    } else if (name.contains('luggage') || name.contains('bag')) {
      return Icons.luggage_rounded;
    }
    return Icons.confirmation_number_rounded;
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Payable at counter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          Text(
            '₹${_calculateTotal().toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.primary),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(
                  itemBuilder(item),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            isExpanded: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelector({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCounter(
    String label,
    String price,
    IconData icon,
    int count,
    void Function(int) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                color: count > 0 ? AppColors.primary : AppColors.textSecondary,
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
