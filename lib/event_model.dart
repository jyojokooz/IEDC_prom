class Event {
  final String id;
  final String title;
  final String tagline;
  final String imageUrl;
  final String description;
  final String date;
  final String venue;
  final List<String> rules;

  const Event({
    required this.id,
    required this.title,
    required this.tagline,
    required this.imageUrl,
    required this.description,
    required this.date,
    required this.venue,
    required this.rules,
  });
}
