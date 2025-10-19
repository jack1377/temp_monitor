import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TemperaturePage extends StatefulWidget {
  @override
  _TemperaturePageState createState() => _TemperaturePageState();
}

class _TemperaturePageState extends State<TemperaturePage> {
  final CollectionReference _temps =
      FirebaseFirestore.instance.collection('temperatures');

  final TextEditingController _controller = TextEditingController();
  final DateFormat _fmt = DateFormat('yyyy-MM-dd HH:mm:ss');

  void _addTemperature() {
    final tempText = _controller.text.trim();
    if (tempText.isEmpty) return;

    _temps.add({
      'value': double.tryParse(tempText) ?? 0.0,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Monitor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter temperature',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTemperature,
                  child: Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _temps.orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final ts = data['timestamp'] as Timestamp?;
                    final timeStr = ts != null
                        ? _fmt.format(ts.toDate())
                        : '...';
                    return ListTile(
                      title: Text('${data['value']} °C'),
                      subtitle: Text(timeStr),
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
