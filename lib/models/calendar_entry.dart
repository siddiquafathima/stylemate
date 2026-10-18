class CalendarEntry {
  final DateTime date;
  final String outfitId;

  CalendarEntry({required this.date, required this.outfitId});

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'outfitId': outfitId,
      };

  factory CalendarEntry.fromJson(Map<String, dynamic> json) => CalendarEntry(
        date: DateTime.parse(json['date'] as String),
        outfitId: json['outfitId'] as String,
      );
}
