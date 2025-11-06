import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:slotbooking/Homepage.dart";
import "package:slotbooking/firebase_options.dart";
import "package:firebase_core/firebase_core.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print("🔥 Initializing Firebase...");

    final options = DefaultFirebaseOptions.currentPlatform;
    print("📱 Platform: ${defaultTargetPlatform}");
    print("🔑 Project ID: ${options.projectId}");

    await Firebase.initializeApp(options: options);
    print("✅ Firebase initialized successfully!");

    // Test Firestore connection with more detailed error handling
    try {
      print("🔄 Testing Firestore connection...");
      final testDoc = await FirebaseFirestore.instance
          .collection('test')
          .add({'timestamp': FieldValue.serverTimestamp(), 'test': true})
          .timeout(const Duration(seconds: 30));

      print("📝 Test document created with ID: ${testDoc.id}");

      final testRead = await testDoc.get();
      if (testRead.exists) {
        print("✅ Firestore read/write test successful!");
      } else {
        print("⚠️ Test document was created but cannot be read back");
      }
    } catch (e, stackTrace) {
      print("❌ Detailed Firestore test failed:");
      print("Error: $e");
      print("Stack trace: $stackTrace");
    }

    runApp(const MyApp());
  } catch (error) {
    print("❌ Firebase initialization failed: $error");
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home:  BookingSlotsScreen());
  }
}
