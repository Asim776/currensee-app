import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  HistoryScreen({super.key});

  Future<void> _clearHistory(BuildContext context) async {
    try {
      if (user != null) {
        final batch = FirebaseFirestore.instance.batch();
        final historyRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('conversion_history');

        final snapshot = await historyRef.get();
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("History cleared successfully!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error clearing history: $e")));
    }
  }

  Future<void> _deleteSingleEntry(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('conversion_history')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Conversion deleted successfully!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting entry: $e")));
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Conversion"),
          content: Text("Are you sure you want to delete this entry?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSingleEntry(context, docId);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Clear History"),
          content: Text(
              "Are you sure you want to clear your entire conversion history? This cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearHistory(context);
              },
              child: Text("Clear History"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Conversion History",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearHistoryDialog(context),
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user!.uid)
                  .collection('conversion_history')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No conversion history available."));
                }

                final historyDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: historyDocs.length,
                  itemBuilder: (context, index) {
                    final doc = historyDocs[index];
                    final data = doc.data() as Map<String, dynamic>;

                    String from = data['from'] ?? '';
                    String to = data['to'] ?? '';
                    double amount = data['amount']?.toDouble() ?? 0;
                    String result = data['result'] ?? '';
                    Timestamp? timestamp = data['timestamp'];
                    String formattedTime = timestamp != null
                        ? DateFormat('MMM d, yyyy - hh:mm a')
                            .format(timestamp.toDate())
                        : "Unknown";

                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      bottomLeft: Radius.circular(20)),
                                  gradient: LinearGradient(
                                    colors: [Colors.blue, Colors.lightBlueAccent],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$from ➜ $to",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text("Amount: $amount",
                                      style: TextStyle(fontSize: 15)),
                                  Text("Converted: $result",
                                      style: TextStyle(fontSize: 15)),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                            color: Colors.grey[600], fontSize: 12),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline,
                                            color: Colors.redAccent),
                                        onPressed: () => _showDeleteConfirmationDialog(
                                            context, doc.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
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
