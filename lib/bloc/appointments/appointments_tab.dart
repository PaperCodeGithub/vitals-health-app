import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/apis.dart';

class AppointmentsTab extends StatefulWidget {
  const AppointmentsTab({super.key});

  @override
  State<AppointmentsTab> createState() => _AppointmentsTabState();
}

class _AppointmentsTabState extends State<AppointmentsTab> {
  final ScrollController _scrollController = ScrollController();

  List<DocumentSnapshot> _appointments = [];
  bool _isLoadingInitial = true;
  bool _isFetchingMore = false;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  String _accountType = '';

  final int _documentLimit = 10;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _fetchMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoadingInitial = true);
    try {
        _accountType = await DatabaseService.instance.getAccountType();

      final docs = await DatabaseService.instance.fetchPaginatedAppointments(
        limit: _documentLimit,
      );

      setState(() {
        _appointments = docs;
        if (docs.isNotEmpty) _lastDocument = docs.last;
        if (docs.length < _documentLimit) _hasMoreData = false;
        _isLoadingInitial = false;
      });
    } catch (e) {
      setState(() => _isLoadingInitial = false);
      print("Error fetching initial appointments: $e");
    }
  }

  Future<void> _fetchMoreData() async {
    if (_isFetchingMore || !_hasMoreData) return;

    setState(() => _isFetchingMore = true);

    try {
      final docs = await DatabaseService.instance.fetchPaginatedAppointments(
        limit: _documentLimit,
        lastDocument: _lastDocument,
      );

      setState(() {
        _appointments.addAll(docs);
        if (docs.isNotEmpty) _lastDocument = docs.last;
        if (docs.length < _documentLimit) _hasMoreData = false;
        _isFetchingMore = false;
      });
    } catch (e) {
      setState(() => _isFetchingMore = false);
      print("Error fetching more appointments: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF111111);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "My Appointments",
          style: GoogleFonts.outfit(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoadingInitial
          ? const Center(child: CupertinoActivityIndicator())
          : _appointments.isEmpty
          ? Center(
        child: Text(
          "No appointments scheduled yet.",
          style: TextStyle(color: Colors.grey.shade500),
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchInitialData,
        color: Theme.of(context).colorScheme.primary,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _appointments.length + (_isFetchingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading spinner at the bottom if fetching more
            if (index == _appointments.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }

            final doc = _appointments[index];
            return _buildAppointmentCard(doc, isDark, textColor);
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(DocumentSnapshot doc, bool isDark, Color textColor) {
    final data = doc.data() as Map<String, dynamic>;
    final cardColor = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03);
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05);

    final Timestamp? timestamp = data['appointmentTime'];
    final DateTime date = timestamp?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d • h:mm a').format(date);

    final status = data['status'] ?? 'pending';

    final String displayTitle = _accountType == 'clinic'
        ? "Patient ID: ${data['patientId']?.substring(0, 5)}..."
        : "Clinic Appt";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayTitle,
                style: GoogleFonts.outfit(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'confirmed':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case 'cancelled':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.redAccent;
        break;
      case 'pending':
      default:
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}