import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeedbackHistoryScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  FeedbackHistoryScreen({super.key});

  Future<void> _clearAllFeedbacks(BuildContext context) async {
    if (user != null) {
      final batch = FirebaseFirestore.instance.batch();
      final feedbackRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Feedbacks');

      final snapshot = await feedbackRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("All feedbacks cleared!")));
    }
  }

  Future<void> _deleteSingleFeedback(
      BuildContext context, String docId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user!.uid)
          .collection('Feedbacks')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Feedback deleted")));
    }
  }

  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Feedback"),
        content: Text("Are you sure you want to delete this feedback?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteSingleFeedback(context, docId);
              },
              child: Text("Yes")),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Clear All Feedbacks"),
        content: Text(
            "Are you sure you want to delete all feedbacks? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearAllFeedbacks(context);
              },
              child: Text("Clear All")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(user!.uid)
            .collection('Feedbacks')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No feedbacks found."));
          }

          final feedbackDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: feedbackDocs.length,
            itemBuilder: (context, index) {
              final doc = feedbackDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final rating = data['rating']?.toDouble() ?? 0.0;
              final feedback = data['feedback'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final date = timestamp != null
                  ? DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate())
                  : "Unknown";

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 4,
                margin: EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // You could add a feature to view detailed feedback here
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.rate_review, color: Colors.amber),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Rating: $rating ⭐", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text(feedback),
                              SizedBox(height: 5),
                              Text("Date: $date", style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(context, doc.id),
                        ),
                      ],
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
