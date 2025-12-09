import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/history_entry.dart';
import '../providers/history_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _isDeleteMode = false;
  final Set<HistoryEntry> _selectedEntries = {};

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _selectedEntries.clear();
    });
  }

  void _toggleSelection(HistoryEntry entry) {
    setState(() {
      if (_selectedEntries.contains(entry)) {
        _selectedEntries.remove(entry);
      } else {
        _selectedEntries.add(entry);
      }
    });
  }

  Future<void> _showDeleteConfirmation() async {
    final TextEditingController controller = TextEditingController();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Konfirmasi Hapus'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Anda akan menghapus ${_selectedEntries.length} data riwayat. Tindakan ini tidak dapat dibatalkan.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ketik "hapus" untuk mengonfirmasi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'hapus',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: controller.text.toLowerCase() == 'hapus'
                      ? () => Navigator.pop(context, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Hapus'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm == true) {
      await _deleteSelected();
    }
  }

  Future<void> _deleteSelected() async {
    final history = context.read<HistoryProvider>();
    await history.deleteEntries(_selectedEntries.toList());

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));

    setState(() {
      _isDeleteMode = false;
      _selectedEntries.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isDeleteMode ? 'Hapus Data' : 'Riwayat Pengenalan'),
        backgroundColor: _isDeleteMode ? Colors.red : const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _toggleDeleteMode,
            icon: Icon(_isDeleteMode ? Icons.close : Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, history, _) {
                if (history.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (history.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Hitung statistik verifikasi
                final verifiedEntries = history.entries
                    .where((e) => e.isCorrect != null)
                    .toList();
                final correctCount = verifiedEntries
                    .where((e) => e.isCorrect == true)
                    .length;
                final incorrectCount = verifiedEntries
                    .where((e) => e.isCorrect == false)
                    .length;
                final totalVerified = verifiedEntries.length;

                return Column(
                  children: [
                    if (totalVerified > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statistik Verifikasi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                height: 20,
                                child: Row(
                                  children: [
                                    if (correctCount > 0)
                                      Expanded(
                                        flex: correctCount,
                                        child: Container(
                                          color: Colors.green,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${(correctCount / totalVerified * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (incorrectCount > 0)
                                      Expanded(
                                        flex: incorrectCount,
                                        child: Container(
                                          color: Colors.red,
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${(incorrectCount / totalVerified * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Benar: $correctCount',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Salah: $incorrectCount',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: history.entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = history.entries[index];
                          final isCorrect = entry.isCorrect;
                          Color? statusColor;
                          if (isCorrect == true) statusColor = Colors.green[50];
                          if (isCorrect == false) statusColor = Colors.red[50];

                          return Row(
                            children: [
                              if (_isDeleteMode)
                                Checkbox(
                                  value: _selectedEntries.contains(entry),
                                  onChanged: (_) => _toggleSelection(entry),
                                  activeColor: Colors.red,
                                ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _isDeleteMode
                                      ? () => _toggleSelection(entry)
                                      : null,
                                  child: Card(
                                    color: statusColor,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(entry.imagePath),
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                width: 56,
                                                height: 56,
                                                color: Colors.grey[200],
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        ),
                                      ),
                                      title: Text(
                                        'Hasil: ${entry.prediction}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${entry.captureSource}',
                                          ),
                                          if (!_isDeleteMode)
                                            Text(
                                              '${_formatTimestamp(entry.recordedAt)}',
                                            ),
                                          if (isCorrect != null)
                                            Text(
                                              isCorrect
                                                  ? 'Terverifikasi Benar'
                                                  : 'Terverifikasi Salah',
                                              style: TextStyle(
                                                color: isCorrect
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Akurasi',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            '${entry.accuracy.toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (_isDeleteMode)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedEntries.isNotEmpty
                      ? _showDeleteConfirmation
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Konfirmasi Hapus (${_selectedEntries.length})'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Belum ada riwayat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai scan untuk melihat daftar hasil pengenalan multidigit di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            if (!_isDeleteMode)
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Mulai Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime time) {
    final local = time.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$date $hour:$minute';
  }
}
