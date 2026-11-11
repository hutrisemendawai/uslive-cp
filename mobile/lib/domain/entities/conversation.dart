class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    this.participantIds = const [],
    this.lastMessageAt,
  });

  final String id;
  final String title;
  final List<String> participantIds;
  final DateTime? lastMessageAt;
}
