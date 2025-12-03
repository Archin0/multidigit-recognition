import 'package:flutter/material.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  // Data dummy untuk history (nanti akan diganti dengan data dari database/backend)
  final List<Map<String, dynamic>> historyData = [
    {
      'id': 1,
      'detected_number': '567',
      'confidence': 0.95,
      'date': '2024-12-04',
      'time': '14:30',
    },
    {
      'id': 2,
      'detected_number': '12345',
      'confidence': 0.88,
      'date': '2024-12-04',
      'time': '13:15',
    },
    {
      'id': 3,
      'detected_number': '9876',
      'confidence': 0.92,
      'date': '2024-12-03',
      'time': '16:45',
    },
    {
      'id': 4,
      'detected_number': '42',
      'confidence': 0.78,
      'date': '2024-12-03',
      'time': '10:20',
    },
    {
      'id': 5,
      'detected_number': '13579',
      'confidence': 0.96,
      'date': '2024-12-02',
      'time': '09:00',
    },
  ];

  void _deleteHistoryItem(int id) {
    setState(() {
      historyData.removeWhere((item) => item['id'] == id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History dihapus'),
        backgroundColor: Color(0xFF007AFF),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua History?'),
        content: const Text('Semua riwayat deteksi akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                historyData.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua history telah dihapus'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: const Color(0xFF007AFF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (historyData.isNotEmpty)
            IconButton(
              onPressed: _clearAllHistory,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: historyData.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final item = historyData[index];
                return _buildHistoryCard(item);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat deteksi akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/detection');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Mulai Deteksi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007AFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final confidence = item['confidence'] as double;
    final confidencePercent = (confidence * 100).toStringAsFixed(0);
    
    Color confidenceColor;
    IconData confidenceIcon;
    
    if (confidence >= 0.9) {
      confidenceColor = const Color(0xFF00FF00);
      confidenceIcon = Icons.check_circle;
    } else if (confidence >= 0.7) {
      confidenceColor = Colors.orange;
      confidenceIcon = Icons.warning;
    } else {
      confidenceColor = Colors.red;
      confidenceIcon = Icons.error;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate ke detail atau result page
            Navigator.pushNamed(
              context,
              '/result',
              arguments: {
                'detected_number': item['detected_number'],
                'confidence': item['confidence'],
                'image_file': null,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon & Number
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      item['detected_number'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF007AFF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            confidenceIcon,
                            size: 16,
                            color: confidenceColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Confidence: $confidencePercent%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['date'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['time'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Delete Button
                IconButton(
                  onPressed: () => _deleteHistoryItem(item['id']),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.grey[400],
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
