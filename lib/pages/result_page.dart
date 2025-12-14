import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/capture_provider.dart';
import '../providers/history_provider.dart';
import '../services/recognition_service.dart';

class ResultPage extends StatefulWidget {
  final File? image;
  final Uint8List? imageBytes;
  final String? detectedNumber;
  final double? accuracy;

  const ResultPage({
    super.key,
    this.image,
    this.imageBytes,
    this.detectedNumber,
    this.accuracy,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaving = false;
  bool _showPipeline = false;

  @override
  Widget build(BuildContext context) {
    final capture = context.watch<CaptureProvider>();
    final history = context.watch<HistoryProvider>();
    final Uint8List? previewBytes = widget.imageBytes ?? capture.croppedBytes;
    final displayNumber = widget.detectedNumber ?? capture.prediction ?? '---';
    final displayAccuracy = widget.accuracy ?? capture.accuracy ?? 0;
    final captureSource = capture.captureSource ?? '-';
    final recordedAt = capture.predictionTimestamp;
    final hasResult = displayNumber != '---';
    final pipeline = capture.pipeline;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              const Text(
                'Hasil Pengenalan Multidigit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              // // Deskripsi
              // const Text(
              //   'Mengenali angka yang terdiri dari beberapa digit sekaligus langsung dari kamera. Membantu pembacaan angka secara cepat, otomatis, dan konsisten.',
              //   style: TextStyle(
              //     fontSize: 14,
              //     color: Colors.black54,
              //     height: 1.5,
              //   ),
              // ),
              const SizedBox(height: 24),

              // Gambar hasil scan
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: previewBytes != null
                      ? Image.memory(previewBytes, fit: BoxFit.contain)
                      : widget.image != null
                      ? Image.file(widget.image!, fit: BoxFit.contain)
                      : Center(
                          child: Text(
                            displayNumber,
                            style: const TextStyle(
                              fontSize: 100,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),

              // Metadata ring
              if (recordedAt != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaTile('Sumber', captureSource),
                      _buildMetaTile('Diproses', _formatTimestamp(recordedAt)),
                    ],
                  ),
                ),

              if (recordedAt != null) const SizedBox(height: 16),

              // Label Hasil Pengenalan
              const Text(
                'Hasil Pengenalan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 8),

              // Angka hasil deteksi
              Text(
                displayNumber,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 16),

              if (pipeline != null && pipeline.hasVisuals) ...[
                _buildPipelineToggleCard(),
                const SizedBox(height: 16),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: _buildPipelineSection(pipeline),
                  crossFadeState: _showPipeline
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 350),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 8),

              // Divider
              Divider(color: Colors.grey[300], thickness: 1),

              const SizedBox(height: 16),

              // Akurasi Pengenalan
              const Text(
                'Akurasi Pengenalan:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 12),

              // Progress bar akurasi
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (displayAccuracy.clamp(0, 100)) / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          displayAccuracy >= 80
                              ? Colors.green
                              : displayAccuracy >= 50
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${displayAccuracy.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),

              // Tombol Scan Lagi
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: hasResult ? () => Navigator.pop(context) : null,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    'Scan Lagi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Simpan ke Riwayat
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: hasResult && !_isSaving && !history.isSaving
                      ? () => _saveToHistory(
                          previewBytes,
                          displayNumber,
                          displayAccuracy,
                          captureSource,
                          recordedAt,
                        )
                      : null,
                  icon: const Icon(Icons.save, color: Color(0xFF1E88E5)),
                  label: const Text(
                    'Simpan ke Riwayat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPipelineToggleCard() {
    const accent = Color(0xFF0D47A1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E2FF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Lihat Selengkapnya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tampilkan visual tiap tahap preprocessing dan segmentasi.',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: () => setState(() => _showPipeline = !_showPipeline),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Icon(_showPipeline ? Icons.visibility_off : Icons.visibility),
            label: Text(_showPipeline ? 'Sembunyikan' : 'Lihat selengkapnya'),
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineSection(RecognitionPipeline pipeline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7FAFF), Color(0xFFE6EEFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD5E2FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140D47A1),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Visualisasi Pipeline',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Visualisasi tiap tahap pengolahan gambar.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          _buildStageTimeline(pipeline.stages),
          if (pipeline.digitCrops.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Digit Tersegmentasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildDigitGrid(pipeline.digitCrops),
          ],
          const SizedBox(height: 24),
          _buildSummaryChips(pipeline.summary),
        ],
      ),
    );
  }

  Widget _buildStageTimeline(List<PipelineStage> stages) {
    if (stages.isEmpty) {
      return const SizedBox.shrink();
    }
    final widgets = <Widget>[];
    for (var i = 0; i < stages.length; i++) {
      widgets.add(_PipelineStageCard(stage: stages[i]));
      if (i < stages.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  child: Divider(color: Color(0xFFB3C6FF), thickness: 1.2),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xFF90A4FF),
                ),
                Expanded(
                  child: Divider(color: Color(0xFFB3C6FF), thickness: 1.2),
                ),
              ],
            ),
          ),
        );
      }
    }
    return Column(children: widgets);
  }

  Widget _buildDigitGrid(List<DigitCropVisual> digits) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: digits.map((digit) => _DigitTile(visual: digit)).toList(),
    );
  }

  Widget _buildSummaryChips(PipelineSummary summary) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _InfoChip(title: 'Prediksi', value: summary.prediction),
        _InfoChip(title: 'Digit', value: summary.digitCount.toString()),
        _InfoChip(
          title: 'Akurasi rata-rata',
          value: '${summary.accuracy.toStringAsFixed(2)}%',
        ),
        _InfoChip(
          title: 'Waktu proses',
          value: '${summary.processingTimeMs} ms',
        ),
      ],
    );
  }

  Widget _buildMetaTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
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

  Future<void> _saveToHistory(
    Uint8List? previewBytes,
    String prediction,
    double accuracy,
    String captureSource,
    DateTime? recordedAt,
  ) async {
    if (previewBytes == null || recordedAt == null) {
      _showSnack('Gambar atau waktu deteksi tidak tersedia.');
      return;
    }

    // Tampilkan dialog konfirmasi kebenaran prediksi
    final bool? isCorrect = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Hasil'),
        content: const Text('Apakah hasil prediksi ini benar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Salah'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Benar'),
          ),
        ],
      ),
    );

    if (isCorrect == null) return; // User cancel dialog

    setState(() => _isSaving = true);
    final history = context.read<HistoryProvider>();

    try {
      await history.saveEntry(
        imageBytes: previewBytes,
        prediction: prediction,
        accuracy: accuracy,
        captureSource: captureSource,
        recordedAt: recordedAt,
        isCorrect: isCorrect,
      );
      if (!mounted) return;
      _showSnack('Disimpan ke riwayat (${isCorrect ? "Benar" : "Salah"}).');
    } catch (error) {
      _showSnack('Gagal menyimpan riwayat: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PipelineStageCard extends StatelessWidget {
  const _PipelineStageCard({required this.stage});

  final PipelineStage stage;

  @override
  Widget build(BuildContext context) {
    final ratioValue = stage.aspectRatio ?? 1.0;
    final aspectRatio = ratioValue.clamp(0.1, 10.0).toDouble();
    final imageWidget = stage.imageBytes.isNotEmpty
        ? Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Image.memory(
                stage.imageBytes,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          )
        : Container(
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFFE0E7FF),
            ),
            child: const Center(
              child: Icon(Icons.image_not_supported, color: Colors.black45),
            ),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6ECFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D47A1).withOpacity(0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              stage.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D47A1),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            stage.description,
            style: const TextStyle(color: Colors.black87, height: 1.4),
          ),
          const SizedBox(height: 12),
          imageWidget,
        ],
      ),
    );
  }
}

class _DigitTile extends StatelessWidget {
  const _DigitTile({required this.visual});

  final DigitCropVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C0D47A1),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            visual.caption,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: visual.imageBytes.isNotEmpty
                ? Image.memory(
                    visual.imageBytes,
                    height: 70,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    colorBlendMode: BlendMode.srcIn,
                    gaplessPlayback: true,
                  )
                : Container(
                    height: 70,
                    color: const Color(0xFFF1F4FF),
                    child: const Center(
                      child: Icon(Icons.crop_3_2, color: Colors.black38),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            '${visual.confidence.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D47A1),
            ),
          ),
          const Text(
            'confidence score',
            style: TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E8FF)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
