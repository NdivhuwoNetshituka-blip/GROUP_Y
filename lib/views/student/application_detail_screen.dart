/**
 * GROUP Y - TPG316C Student Assistant Application System
 *
 * Student Numbers and Names:
 *   215135458 - LE Lipali
 *   223013773 - NM Netshituka
 *   224004294 - B Linda
 *   221050663 - GR Kgwele
 *   222066543 - RG Madi
 *   224007421 - Y Mazamani
 *   224099468 - LE Letsie
 *   219002738 - LTBG Pule
 *   223060226 - NC Pali
 *   223007074 - T Zitha
 *
 * File: application_detail_screen.dart
 * Description: Shows full details of an application and lets the student edit or delete it.
 */

import 'package:flutter/material.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Application Details")),

      body: Padding(
        padding: const EdgeInsets.all(16.0),

        child: Card(
          elevation: 5,

          child: Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Student Application",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 10),
                    Text(
                      "Full Name: Rotondwa Gift",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.email),
                    SizedBox(width: 10),
                    Text(
                      "Email: example@gmail.com",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 10),
                    Text("Phone: 0843214912", style: TextStyle(fontSize: 16)),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.school),
                    SizedBox(width: 10),
                    Text(
                      "Course: Information Technology",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                Text(
                  "Application Status: Pending",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
