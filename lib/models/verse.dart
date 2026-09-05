/// آية واحدة من الكتاب المقدس مع الشاهد بتاعها.
class Verse {
  final String text;
  final String reference; // مثال: "يوحنا 3:16"

  const Verse({required this.text, required this.reference});

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      text: (json['text'] as String?)?.trim() ?? '',
      reference: (json['reference'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'reference': reference,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Verse && other.text == text && other.reference == reference;

  @override
  int get hashCode => Object.hash(text, reference);

  @override
  String toString() => 'Verse($reference)';
}
