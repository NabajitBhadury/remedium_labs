import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/service.dart';
import '../../theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../profile/family_members_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BookingFlowScreen extends StatefulWidget {
  final String franchiseName;
  final String franchiseId;
  final Service service;
  final bool isHomeCollection;

  const BookingFlowScreen({
    super.key,
    required this.franchiseName,
    required this.franchiseId,
    required this.service,
    this.isHomeCollection = false,
  });

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _couponController = TextEditingController();

  // State
  String _bookingFor = 'Self';
  String _gender = 'Male';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _visitType = 'Lab Visit';
  String _paymentMode = 'Online';
  bool _isProcessing = false;

  // Coupon state
  bool _isApplyingCoupon = false;
  double? _discount;
  double? _finalAmount;
  String? _appliedCoupon;
  String? _couponError;

  // Booking result
  String? _bookingToken;
  double? _bookingFinalAmount;

  @override
  void initState() {
    super.initState();
    if (widget.isHomeCollection) {
      _visitType = 'Home Collection';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>();
      if (user.isAuthenticated && user.userName != null) {
        _nameController.text = user.userName!;
        if (user.userPhone != null) _phoneController.text = user.userPhone!;
        if (user.userGender != null) {
          final g = user.userGender!;
          if (['Male', 'Female', 'Other'].contains(g)) {
            _gender = g;
          } else if (g.toLowerCase() == 'male') {
            _gender = 'Male';
          } else if (g.toLowerCase() == 'female') {
            _gender = 'Female';
          } else {
            _gender = 'Other';
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _ageController.dispose();
    _couponController.dispose();
    super.dispose();
  }

  double get _baseAmount => widget.service.price;
  double get _convenienceFee => _visitType == 'Home Collection' ? 10.0 : 0.0;
  double get _orderAmount => _baseAmount + _convenienceFee;
  double get _payableAmount => _finalAmount ?? _orderAmount;

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time slot'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 2) {
      if (_visitType == 'Home Collection' && _addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your address'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isApplyingCoupon = true;
      _couponError = null;
    });

    try {
      final result = await context.read<BookingProvider>().applyCoupon(
            couponCode: code,
            orderAmount: _orderAmount,
          );
      setState(() {
        _appliedCoupon = result.couponCode;
        _discount = result.discount;
        _finalAmount = result.finalAmount;
        _couponError = null;
      });
    } catch (e) {
      setState(() {
        _appliedCoupon = null;
        _discount = null;
        _finalAmount = null;
        _couponError = e.toString();
      });
    } finally {
      setState(() => _isApplyingCoupon = false);
    }
  }

  void _removeCoupon() {
    setState(() {
      _couponController.clear();
      _appliedCoupon = null;
      _discount = null;
      _finalAmount = null;
      _couponError = null;
    });
  }

  Future<void> _confirmBooking() async {
    setState(() => _isProcessing = true);

    try {
      final data = await context.read<BookingProvider>().createBooking(
            serviceType: _visitType,
            labId: widget.franchiseId,
            userId: context.read<AuthProvider>().userId?.toString() ?? "0",
            patientName: _nameController.text.trim(),
            patientPhone: _phoneController.text.trim(),
            testId: widget.service.id,
            amount: _orderAmount,
            finalAmount: _payableAmount,
            patientGender: _gender,
            patientAddress: _addressController.text.trim(),
            bookingDate: _selectedDate.toIso8601String().split('T')[0],
            bookingTime: _selectedTime != null ? "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}" : null,
            testName: widget.service.name,
            franchiseId: widget.franchiseId,
            franchiseName: widget.franchiseName,
            discount: _discount,
            couponCode: _appliedCoupon,
            paymentMode: _paymentMode,
          );

      if (mounted) {
        setState(() {
          _isProcessing = false;
          
          // Handle cases where the provider might return the whole response or just the 'data' map
          final responseData = data.containsKey('data') && data['data'] is Map ? data['data'] : data;
          
          _bookingToken = responseData['token']?.toString() ?? responseData['booking_id']?.toString();
          
          _bookingFinalAmount =
              double.tryParse(responseData['final_amount']?.toString() ?? '') ??
                  _payableAmount;
          _currentStep = 4; // success step
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final bool showSuccess = _currentStep == 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Book Appointment',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          if (!showSuccess)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              color: Colors.white,
              child: Row(
                children: [
                  _buildStepIndicator(0, 'Details'),
                  _buildStepLine(0),
                  _buildStepIndicator(1, 'Time'),
                  _buildStepLine(1),
                  _buildStepIndicator(2, 'Type'),
                  _buildStepLine(2),
                  _buildStepIndicator(3, 'Review'),
                ],
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildStepContent(),
              ),
            ),
          ),

          // Bottom Action Bar
          if (!showSuccess)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : (_currentStep == 3 ? _confirmBooking : _nextStep),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep == 3
                                  ? 'Confirm & Pay ₹${_payableAmount.toStringAsFixed(0)}'
                                  : 'Continue',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: GoogleFonts.outfit(
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppTheme.primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        color:
            _currentStep > step ? AppTheme.primaryColor : Colors.grey.shade200,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPatientDetailsStep();
      case 1:
        return _buildDateTimeStep();
      case 2:
        return _buildVisitTypeStep();
      case 3:
        return _buildReviewStep();
      case 4:
        return _buildSuccessStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Patient Details ───────────────────────────────────────────────

  Widget _buildPatientDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey(0),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Details',
            style:
                GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Who is this checkup for?',
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Self / Family tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _buildTabOption('Self', _bookingFor == 'Self'),
                _buildTabOption('Family Member', _bookingFor == 'Family'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_bookingFor == 'Family') ...[
            _buildFamilySelector(),
            const SizedBox(height: 24),
          ],

          _buildInputLabel('Full Name'),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Enter patient name', Icons.person_outline),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          _buildInputLabel('Phone Number'),
          TextFormField(
            controller: _phoneController,
            decoration: _inputDecoration('Enter phone number', Icons.phone_outlined),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (v.length != 10) return 'Must be 10 digits';
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Gender'),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration('', Icons.people_outline),
                      items: ['Male', 'Female', 'Other']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Age'),
                    TextFormField(
                      controller: _ageController,
                      decoration:
                          _inputDecoration('Age', Icons.calendar_today_outlined),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn().slideX(),
    );
  }

  Widget _buildTabOption(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _bookingFor = label == 'Self' ? 'Self' : 'Family';
            if (_bookingFor == 'Self') {
              final user = context.read<AuthProvider>();
              _nameController.text = user.userName ?? '';
              _phoneController.text = user.userPhone ?? '';
            } else {
              _nameController.clear();
              _phoneController.clear();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFamilySelector() {
    final familyMembers = context.watch<AuthProvider>().familyMembers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Member',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FamilyMembersScreen()),
                );
              },
              child: const Text('Manage'),
            ),
          ],
        ),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: familyMembers.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == familyMembers.length) {
                return _buildAddMemberCard();
              }
              final member = familyMembers[index];
              return _buildMemberCard(member);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(dynamic member) {
    bool isSelected = _nameController.text == member.name;
    return GestureDetector(
      onTap: () {
        setState(() {
          _nameController.text = member.name;
          _phoneController.text = member.phone;
          _ageController.text = member.age.toString();
          final g = member.gender?.toString() ?? 'Male';
          _gender = ['Male', 'Female', 'Other'].contains(g)
              ? g
              : g[0].toUpperCase() + g.substring(1).toLowerCase();
        });
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  isSelected ? AppTheme.primaryColor : Colors.grey.shade100,
              child: Text(
                member.name[0].toUpperCase(),
                style: GoogleFonts.outfit(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              member.name.split(' ')[0],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FamilyMembersScreen()),
        );
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.grey.shade400),
            const SizedBox(height: 4),
            Text(
              'Add New',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Step 1: Date & Time ───────────────────────────────────────────────────

  Widget _buildDateTimeStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedule Appointment',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a convenient date and time',
          style: GoogleFonts.inter(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04), blurRadius: 10),
            ],
          ),
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            onDateChanged: (val) => setState(() => _selectedDate = val),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Available Slots',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 9, minute: 0),
            const TimeOfDay(hour: 10, minute: 0),
            const TimeOfDay(hour: 11, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 16, minute: 0),
            const TimeOfDay(hour: 17, minute: 0),
          ].map((time) {
            bool isSelected = _selectedTime?.hour == time.hour;
            return GestureDetector(
              onTap: () => setState(() => _selectedTime = time),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : Colors.grey.shade200,
                  ),
                ),
                child: Text(
                  '${time.hour > 12 ? time.hour - 12 : time.hour}:00 ${time.hour >= 12 ? 'PM' : 'AM'}',
                  style: GoogleFonts.inter(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  // ─── Step 2: Visit Type ────────────────────────────────────────────────────

  Widget _buildVisitTypeStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visit Type',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        if (!widget.isHomeCollection)
          _buildOptionCard(
            'Lab Visit',
            'Visit the lab at your scheduled time.',
            Icons.apartment_rounded,
            _visitType == 'Lab Visit',
            () => setState(() => _visitType = 'Lab Visit'),
          ),
        if (!widget.isHomeCollection) const SizedBox(height: 16),
        _buildOptionCard(
          'Home Collection',
          'Executive will collect sample from home.',
          Icons.home_rounded,
          _visitType == 'Home Collection',
          () => setState(() => _visitType = 'Home Collection'),
          price: '+ ₹10',
        ),

        if (_visitType == 'Home Collection') ...[
          const SizedBox(height: 24),
          _buildInputLabel('Home Address'),
          TextFormField(
            controller: _addressController,
            decoration: _inputDecoration(
              'Enter full address',
              Icons.location_on_outlined,
            ),
            maxLines: 3,
          ),
        ],
      ],
    ).animate().fadeIn().slideX();
  }

  Widget _buildOptionCard(
    String title,
    String subtitle,
    IconData icon,
    bool selected,
    VoidCallback onTap, {
    String? price,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withOpacity(0.04) : Colors.white,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primaryColor : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: selected
                              ? AppTheme.primaryColor
                              : Colors.black87,
                        ),
                      ),
                      if (price != null)
                        Text(
                          price,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  // ─── Step 3: Review + Coupon ───────────────────────────────────────────────

  Widget _buildReviewStep() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Booking summary card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.science,
                      color: AppTheme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.service.name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.franchiseName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child:
                    Divider(height: 1, color: Colors.grey.shade300),
              ),
              _buildReviewRow('Patient', _nameController.text),
              _buildReviewRow(
                'Date',
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              _buildReviewRow(
                'Time',
                '${_selectedTime?.hour}:${_selectedTime?.minute.toString().padLeft(2, '0')}',
              ),
              _buildReviewRow('Visit Type', _visitType),
              const SizedBox(height: 20),

              // Price breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildPriceRow('Test Fee', _baseAmount),
                    if (_convenienceFee > 0) ...[
                      const SizedBox(height: 8),
                      _buildPriceRow('Convenience Fee', _convenienceFee),
                    ],
                    if (_discount != null && _discount! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer,
                                  size: 14, color: Colors.green.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Coupon ($_appliedCoupon)',
                                style: GoogleFonts.inter(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Text(
                            '-₹${_discount!.toStringAsFixed(0)}',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payable',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '₹${_payableAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Coupon Section ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.local_offer_outlined,
                      color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Apply Coupon',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_appliedCoupon != null)
                // Applied coupon badge
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green.shade600, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _appliedCoupon!,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            Text(
                              'Saving ₹${_discount?.toStringAsFixed(0) ?? '0'}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _removeCoupon,
                        icon: Icon(Icons.close,
                            color: Colors.green.shade700, size: 20),
                      ),
                    ],
                  ),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _couponController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Enter coupon code',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.grey.shade400, fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppTheme.primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isApplyingCoupon ? null : _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isApplyingCoupon
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Apply',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                if (_couponError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _couponError!,
                    style: GoogleFonts.inter(
                      color: Colors.red.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Payment Mode ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Mode',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final mode in ['Online', 'Cash', 'Card'])
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMode = mode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(
                            right: mode != 'Card' ? 8 : 0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _paymentMode == mode
                                ? AppTheme.primaryColor
                                : AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _paymentMode == mode
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                mode == 'Online'
                                    ? Icons.payment
                                    : mode == 'Cash'
                                        ? Icons.money
                                        : Icons.credit_card,
                                size: 20,
                                color: _paymentMode == mode
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mode,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _paymentMode == mode
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    ).animate().fadeIn().slideX();
  }

  // ─── Step 4: Success ───────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    final token = _bookingToken ?? '—';
    final amount = _bookingFinalAmount ?? _payableAmount;

    return Column(
      key: const ValueKey(4),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 64,
          ),
        ).animate().scale(
              curve: Curves.elasticOut,
              duration: const Duration(milliseconds: 600),
            ),
        const SizedBox(height: 24),
        Text(
          'Booking Confirmed!',
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Your appointment has been successfully booked.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Booking Token',
                style: GoogleFonts.inter(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 48), // Balance for centering vs the icon
                    Expanded(
                      child: Text(
                        token,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy Token',
                      icon: const Icon(Icons.copy_rounded, color: AppTheme.primaryColor),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: token));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Token copied to clipboard!'),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildReviewRow('Test', widget.service.name),
              _buildReviewRow('Lab', widget.franchiseName),
              _buildReviewRow('Patient', _nameController.text),
              _buildReviewRow('Payment', _paymentMode),
              _buildReviewRow('Amount Paid', '₹${amount.toStringAsFixed(0)}'),
              if (_appliedCoupon != null)
                _buildReviewRow(
                    'Coupon Used', '$_appliedCoupon (-₹${_discount?.toStringAsFixed(0)})'),
              const SizedBox(height: 16),
              Text(
                'Please share this token at the lab center.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _goHome,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Back to Home',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideX();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.grey[700])),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
