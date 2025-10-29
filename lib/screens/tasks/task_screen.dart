import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _ctrl = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _fire = FirebaseFirestore.instance;

  Future<void> _addTask() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final user = _auth.currentUser!;
    await _fire.collection('tasks').add({
      'title': text,
      'isCompleted': false,
      'userId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _ctrl.clear();
  }

  Future<void> _toggle(String docId, bool current) async {
    await _fire
        .collection('tasks')
        .doc(docId)
        .update({'isCompleted': !current});
  }

  Future<void> _delete(String docId) async {
    await _fire.collection('tasks').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;
    final stream = _fire
        .collection('tasks')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'New task title',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: _addTask,
                child: const Text('Add'),
              )
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(child: Text('No tasks yet.'));
              }
              final docs = snap.data!.docs;
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final d = docs[i];
                  final map = d.data() as Map<String, dynamic>;
                  final title = map['title'] ?? '';
                  final done = map['isCompleted'] ?? false;
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: done,
                        onChanged: (_) => _toggle(d.id, done),
                      ),
                      title: Text(
                        title,
                        style: TextStyle(
                          decoration: done
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(d.id),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
