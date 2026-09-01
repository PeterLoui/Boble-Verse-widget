class Verse {
  final String text;
  final String reference; // مثال: "يوحنا 3:16"

  const Verse({required this.text, required this.reference});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      text: json['text'] as String,
      reference: json['reference'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'reference': reference,
      };
}
