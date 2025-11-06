import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slotbooking/thank_you_screen.dart';
import 'dart:async';

class BookingConfirmationScreen extends StatefulWidget {
  final String slotTime;
  final String slotId;

  const BookingConfirmationScreen({
    Key? key,
    required this.slotTime,
    required this.slotId,
  }) : super(key: key);

  @override
  _BookingConfirmationScreenState createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _paymentController = TextEditingController();

  bool _isBookingConfirmed = false;
  bool _isLoading = false;

  Future<void> _saveBooking() async {
    if (_formKey.currentState!.validate()) {
      if (_paymentController.text == "1234") {
        setState(() => _isLoading = true);

        try {
          print("📝 Attempting to save booking to Firestore...");
          print("Data to save: {");
          print("  movie: 'Kantara',");
          print("  slotTime: ${widget.slotTime},");
          print("  slotId: ${widget.slotId},");
          print("  name: ${_nameController.text},");
          print("  email: ${_emailController.text}");
          print("}");

          print("📝 Creating Firestore document...");

          // Check network connection first
          try {
            final settings = FirebaseFirestore.instance.settings;
            print("📡 Firestore settings: ${settings.host}");

            await FirebaseFirestore.instance
                .collection('test')
                .add({
                  'timestamp': FieldValue.serverTimestamp(),
                  'connectionTest': true,
                })
                .timeout(const Duration(seconds: 15));
            print("✅ Test document created successfully!");
          } catch (e, stackTrace) {
            print("❌ Failed to create test document:");
            print("Error: $e");
            print("Stack trace: $stackTrace");
            throw Exception("Cannot connect to Firestore (timeout: 15s): $e");
          }

          // Save booking and decrement ticket count atomically using a transaction.
          final bookingRef =
              FirebaseFirestore.instance.collection('bookings').doc();
          final slotRef = FirebaseFirestore.instance
              .collection('slots')
              .doc(widget.slotId);
          const int startingTickets = 5; // fallback when slot doc doesn't exist

          await FirebaseFirestore.instance
              .runTransaction((transaction) async {
                final slotSnapshot = await transaction.get(slotRef);

                if (slotSnapshot.exists) {
                  final data = slotSnapshot.data();
                  final current = (data?['ticketsLeft'] ?? 0) as int;
                  if (current <= 0) {
                    throw Exception('No tickets left for this slot');
                  }
                  transaction.update(slotRef, {
                    'ticketsLeft': FieldValue.increment(-1),
                  });
                } else {
                  // Create the slot doc with startingTickets - 1
                  transaction.set(slotRef, {
                    'ticketsLeft': startingTickets - 1,
                    'slotTime': widget.slotTime,
                  });
                }

                // Create the booking document inside the same transaction
                transaction.set(bookingRef, {
                  'movie': 'Kantara',
                  'slotTime': widget.slotTime,
                  'slotId': widget.slotId,
                  'name': _nameController.text,
                  'email': _emailController.text,
                  'timestamp': FieldValue.serverTimestamp(),
                });
              })
              .timeout(
                const Duration(seconds: 15),
                onTimeout:
                    () =>
                        throw TimeoutException(
                          'Firestore transaction timed out',
                        ),
              );

          print("✅ Booking transaction completed. Doc ID: ${bookingRef.id}");

          // Notify user and show animated Thank You screen, then return to previous screen
          setState(() => _isLoading = false);

          // Optionally show a quick snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Booking Confirmed Successfully!"),
              backgroundColor: Colors.green,
            ),
          );

          // Show the animated Thank You screen and wait until it closes
          await Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const ThankYouScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );

          // After thank-you animation, return the slotId to the previous screen so it can decrement its local counter
          Navigator.pop(context, widget.slotId);
        } catch (e) {
          print("❌ Firestore Error: $e");
          setState(() => _isLoading = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ Failed to save booking: $e"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("❌ Invalid payment code. Please enter '1234'."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Booking Confirmation")),
      body:
          _isBookingConfirmed
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, size: 80, color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      "Booking Confirmed!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text("Thank you for booking with us."),
                  ],
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selected Slot: ${widget.slotTime}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your name"
                                    : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter your email"
                                    : null,
                      ),
                      TextFormField(
                        controller: _paymentController,
                        decoration: const InputDecoration(
                          labelText: "Payment Code (Enter '1234')",
                        ),
                        obscureText: true,
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? "Please enter payment code"
                                    : null,
                      ),
                      const SizedBox(height: 24),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveBooking,
                              child: const Text("Confirm Booking"),
                            ),
                          ),
                    ],
                  ),
                ),
              ),
    );
  }
}
