import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slotbooking/Booking Confirmation Screen.dart';

class BookingSlotsScreen extends StatelessWidget {
  final List<String> slotTimes = [
    "10am to 11am",
    "11am to 12pm",
    "12pm to 1pm",
    "1pm to 2pm",
    "2pm to 3pm",
  ];

  @override
  Widget build(BuildContext context) {
    final slotsCollection = FirebaseFirestore.instance.collection('slots');

    return Scaffold(
      appBar: AppBar(title: Text("Movie Booking Slots")),
      body: StreamBuilder<QuerySnapshot>(
        stream: slotsCollection.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Map of slotId -> ticketCount from Firestore
          final docs = snapshot.data!.docs;
          Map<String, int> ticketsMap = {
            for (var doc in docs)
              doc.id: (doc.data()! as Map<String, dynamic>)['ticketsLeft'] ?? 0
          };

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: slotTimes.length,
            itemBuilder: (context, index) {
              String slotId = index.toString();
              int ticketsLeft = ticketsMap[slotId] ?? 5;
              bool isSoldOut = ticketsLeft == 0;

              return GestureDetector(
                onTap: () async {
                  if (!isSoldOut) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingConfirmationScreen(
                          slotTime: slotTimes[index],
                          slotId: slotId,
                        ),
                      ),
                    );

                    // After booking confirmation, no need to update local state,
                    // the StreamBuilder will automatically refresh the UI.
                  }
                },
                child: Card(
                  color: isSoldOut ? Colors.grey.shade400 : Colors.white,
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Opacity(
                    opacity: isSoldOut ? 0.5 : 1.0,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Movie: Kantara",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSoldOut ? Colors.black38 : Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Time: ${slotTimes[index]}",
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Tickets left: $ticketsLeft",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isSoldOut ? Colors.redAccent : Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSoldOut)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                "Sold Out",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
