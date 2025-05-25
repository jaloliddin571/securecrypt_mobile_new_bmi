import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, int> stats = {
    'Caesar': 0,
    'Vigenère': 0,
    'AES': 0,
    'RSA': 0,
    'File Encrypt': 0,
    'File Decrypt': 0,
    'Steganography': 0,
    'QR Code': 0,
  };

  final Map<String, String> keys = {
    'Caesar': 'caesar_count',
    'Vigenère': 'vigenere_count',
    'AES': 'aes_count',
    'RSA': 'rsa_count',
    'File Encrypt': 'file_enc_count',
    'File Decrypt': 'file_dec_count',
    'Steganography': 'stegano_count',
    'QR Code': 'qr_count',
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final updatedStats = <String, int>{};
    for (var entry in keys.entries) {
      updatedStats[entry.key] = prefs.getInt(entry.value) ?? 0;
    }
    setState(() => stats = updatedStats);
  }

  Future<void> _resetStats() async {
    final prefs = await SharedPreferences.getInstance();
    for (var key in keys.values) {
      await prefs.remove(key);
    }
    await _loadStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📉 Barcha statistikalar tozalandi.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Statistika', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadStats),
          IconButton(icon: const Icon(Icons.delete_forever), onPressed: _resetStats),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00FFAB), Color(0xFF14FFEC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: stats.entries.map((entry) {
                return Card(
                  elevation: 5,
                  color: const Color(0xFF2A2A2A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: Colors.tealAccent),
                    title: Text(entry.key,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    trailing: Text('${entry.value}',
                        style: const TextStyle(color: Colors.tealAccent, fontSize: 18)),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            height: 320,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2E2E2E),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < stats.keys.length) {
                          return Transform.rotate(
                            angle: -0.7,
                            child: Text(stats.keys.elementAt(index), style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false),
                barGroups: stats.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value.value;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: value.toDouble(),
                      width: 18,
                      borderRadius: BorderRadius.circular(6),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00FFAB), Color(0xFF14FFEC)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    )
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}