import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  final MoodStorageService _storageService = MoodStorageService();
  Map<MoodType, int> _moodCounts = {};
  double? _averageMood;
  List<MoodEntry> _weekEntries = [];
  int _totalEntries = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// Public method to reload data from outside
  void reload() => _loadStatistics();

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    final counts = await _storageService.getMoodCounts(lastDays: 30);
    final average = await _storageService.getAverageMood(lastDays: 30);
    final allEntries = await _storageService.getAllEntries();

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final weekEntries = allEntries
        .where((e) => e.dateTime.isAfter(weekAgo))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    setState(() {
      _moodCounts = counts;
      _averageMood = average;
      _weekEntries = weekEntries;
      _totalEntries = allEntries.length;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatistics,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildWeekChart(),
                    const SizedBox(height: 24),
                    _buildMoodDistribution(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final moodLabel = _averageMood != null
        ? MoodType.fromValue(_averageMood!.round()).label
        : 'N/A';

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.calendar_today, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    '$_totalEntries',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Total Entries'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.trending_up, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    moodLabel,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Avg (30 days)'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekChart() {
    if (_weekEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.show_chart, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No data for this week',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start logging your mood to see trends',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last 7 Days',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final mood = MoodType.values.firstWhere(
                            (m) => m.value == value.toInt(),
                            orElse: () => MoodType.neutral,
                          );
                          return Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 1,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weekEntries.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.mood.value.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final mood = MoodType.fromValue(spot.y.toInt());
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Color(mood.colorValue),
                            strokeColor: Colors.white,
                            strokeWidth: 2,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistribution() {
    final total = _moodCounts.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Distribution (30 days)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: MoodType.values.map((mood) {
                        final count = _moodCounts[mood] ?? 0;
                        return PieChartSectionData(
                          value: count.toDouble(),
                          color: Color(mood.colorValue),
                          radius: 25,
                          showTitle: false,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: MoodType.values.map((mood) {
                      final count = _moodCounts[mood] ?? 0;
                      final percentage =
                          total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(mood.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(mood.emoji),
                            const SizedBox(width: 4),
                            Expanded(child: Text(mood.label)),
                            Text('$percentage%'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
