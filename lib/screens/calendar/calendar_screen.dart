import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/wardrobe_service.dart';
import '../../widgets/outfit_thumbnail.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  final ScrollController _dayScrollController = ScrollController();
  static const _todayIndex = 6; // matches the "i - 6" offset below

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dayScrollController.hasClients) return;
      final target = ((_todayIndex - 2) * 58.0).clamp(0.0, _dayScrollController.position.maxScrollExtent);
      _dayScrollController.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeService>();
    final today = DateTime.now();
    // Past week through the next two weeks, so you can plan ahead --
    // not just look at days that already passed.
    final days = List.generate(21, (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i - 6)));
    final selectedOutfit = wardrobe.outfitForDate(_selectedDay);
    final otherOutfits = wardrobe.outfits.where((o) => o.id != selectedOutfit?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Style calendar')),
      body: Column(
        children: [
          SizedBox(
            height: 76,
            child: ListView.separated(
              controller: _dayScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final day = days[i];
                final selected = _isSameDay(day, _selectedDay);
                final hasOutfit = wardrobe.outfitForDate(day) != null;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(day), style: TextStyle(fontSize: 11, color: selected ? Colors.white70 : Colors.grey)),
                        const SizedBox(height: 4),
                        Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black)),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasOutfit ? (selected ? Colors.white : Theme.of(context).colorScheme.primary) : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(DateFormat('EEEE, MMM d').format(_selectedDay), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 8),
                if (selectedOutfit == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(child: Text('No outfit logged for this day')),
                              TextButton(
                                onPressed: wardrobe.outfits.isEmpty ? null : () => _assign(context, _selectedDay),
                                child: const Text('Assign'),
                              ),
                            ],
                          ),
                          if (wardrobe.outfits.isEmpty)
                            const Text(
                              'Create an outfit first (Outfits tab), then come back here to assign it to a day.',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: OutfitThumbnail(outfit: selectedOutfit, wardrobe: wardrobe, borderRadius: 12),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(selectedOutfit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${selectedOutfit.itemIds.length} items', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: wardrobe.outfits.isEmpty ? null : () => _assign(context, _selectedDay),
                            child: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (otherOutfits.isNotEmpty) ...[
                  const Text('You might also like', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: otherOutfits.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final outfit = otherOutfits[i];
                        return GestureDetector(
                          onTap: () => wardrobe.assignOutfitToDate(_selectedDay, outfit.id),
                          child: SizedBox(
                            width: 80,
                            child: OutfitThumbnail(outfit: outfit, wardrobe: wardrobe, borderRadius: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  void _assign(BuildContext context, DateTime day) {
    final wardrobe = context.read<WardrobeService>();
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Choose an outfit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            ),
            ...wardrobe.outfits.map((o) => ListTile(
                  leading: SizedBox(width: 44, height: 44, child: OutfitThumbnail(outfit: o, wardrobe: wardrobe, borderRadius: 10)),
                  title: Text(o.name),
                  subtitle: Text('${o.itemIds.length} items'),
                  onTap: () {
                    wardrobe.assignOutfitToDate(day, o.id);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
