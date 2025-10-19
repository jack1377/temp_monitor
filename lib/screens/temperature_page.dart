import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TemperaturePage extends StatefulWidget {
  const TemperaturePage({super.key});

  @override
  State<TemperaturePage> createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final CollectionReference _temps =
      FirebaseFirestore.instance.collection('temperatures');

  final TextEditingController _controller = TextEditingController();
  final DateFormat _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  Future<void> _addTemperature() async {
    final temp = _controller.text.trim();
    if (temp.isEmpty) return;

    await _temps.add({
      'value': temp,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temperature Monitor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter temperature',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addTemperature,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _temps.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data()! as Map<String, dynamic>;
                    final ts = data['timestamp'] as Timestamp?;
                    final time = ts != null ? _fmt.format(ts.toDate()) : '';
                    return ListTile(
                      title: Text('${data['value']} °C'),
                      subtitle: Text(time),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
