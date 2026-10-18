import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/wardrobe_service.dart';
import '../../widgets/clothing_thumbnail.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const _categoryColors = {
    'Tops': Color(0xFF6E57E0),
    'Bottoms': Color(0xFF4A90D9),
    'Dresses': Color(0xFFE0765C),
    'Shoes': Color(0xFF4CAF93),
    'Accessories': Color(0xFFFCE773),
    'Outerwear': Color(0xFF9C8AA5),
  };

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeService>();
    final total = wardrobe.items.length;
    final worn = wardrobe.items.where((i) => i.wearCount > 0).length;
    final usagePercent = total == 0 ? 0 : ((worn / total) * 100).round();

    // Category breakdown for the donut chart.
    final Map<String, int> byCategory = {};
    for (final item in wardrobe.items) {
      final key = item.category.trim().isEmpty ? 'Uncategorized' : item.category;
      byCategory[key] = (byCategory[key] ?? 0) + 1;
    }

    // Wear count per weekday, for the last 7 days, from calendar entries.
    final today = DateTime.now();
    final last7Days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    final weeklyCounts = last7Days.map((day) {
      return wardrobe.calendar.where((e) =>
          e.date.year == day.year && e.date.month == day.month && e.date.day == day.day).length;
    }).toList();

    // Real outfits-logged-per-month, last 6 months, from actual calendar data.
    final monthLabels = <String>[];
    final monthCounts = <int>[];
    for (int i = 5; i >= 0; i--) {
      final month = DateTime(today.year, today.month - i, 1);
      monthLabels.add(_monthAbbrev(month.month));
      monthCounts.add(wardrobe.calendar.where((e) => e.date.year == month.year && e.date.month == month.month).length);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Wardrobe usage', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('$usagePercent% worn at least once', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('$total', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  const Padding(padding: EdgeInsets.only(top: 10), child: Text('items', style: TextStyle(fontSize: 12))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (byCategory.isNotEmpty) ...[
            const Text('Closet composition', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: byCategory.entries.map((e) {
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            color: _categoryColors[e.key] ?? Colors.grey,
                            title: '',
                            radius: 40,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: byCategory.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: _categoryColors[e.key] ?? Colors.grey, shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Expanded(child: Text('${e.key} (${e.value})', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          const Text('This week\'s activity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Outfits logged per day', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= last7Days.length) return const SizedBox.shrink();
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        return Text(labels[last7Days[index].weekday - 1], style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(weeklyCounts.length, (i) => FlSpot(i.toDouble(), weeklyCounts[i].toDouble())),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const SizedBox(height: 24),

          const Text('Monthly trends', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Outfits logged per month', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: monthCounts.every((c) => c == 0)
                ? const Center(child: Text('No history yet -- log outfits to your calendar to see this fill in.', style: TextStyle(fontSize: 12), textAlign: TextAlign.center))
                : BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= monthLabels.length) return const SizedBox.shrink();
                              return Text(monthLabels[index], style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                      ),
                      barGroups: List.generate(monthCounts.length, (i) {
                        return BarChartGroupData(x: i, barRods: [
                          BarChartRodData(toY: monthCounts[i].toDouble(), color: Theme.of(context).colorScheme.primary, width: 18, borderRadius: BorderRadius.circular(4)),
                        ]);
                      }),
                    ),
                  ),
          ),

          const SizedBox(height: 24),
          const Text('Most worn', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          if (wardrobe.mostWorn.isEmpty)
            const Text('Nothing logged yet -- assign outfits to calendar days to see this.', style: TextStyle(fontSize: 12)),
          ...wardrobe.mostWorn.map((i) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(width: 40, height: 40, child: ClothingThumbnail(item: i, borderRadius: 8)),
                title: Text('${i.color} ${i.subCategory}'),
                trailing: Text('${i.wearCount}x'),
              )),
          const SizedBox(height: 16),

          const Text('Forgotten items', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          ...wardrobe.forgottenItems.map((i) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(width: 40, height: 40, child: ClothingThumbnail(item: i, borderRadius: 8)),
                title: Text('${i.color} ${i.subCategory}'),
                subtitle: Text(i.lastWorn == null
                    ? 'Never worn'
                    : 'Last worn ${DateTime.now().difference(i.lastWorn!).inDays} days ago'),
              )),
        ],
      ),
    );
  }

  String _monthAbbrev(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    // DateTime months can go negative/over via DateTime(year, month-i, 1)
    // normalization, so re-derive a safe 1-12 index from the actual date.
    final normalized = DateTime(2000, month, 1).month;
    return names[normalized - 1];
  }
}
