import 'package:meta/meta.dart';

@immutable
class Person {
  final String id;
  final String emoji;
  final String name;
  final String bio;

  const Person({
    @required this.id,
    @required this.emoji,
    @required this.name,
    @required this.bio,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        bio: json['bio'],
        emoji: json['emoji'],
        name: json['name'],
        id: json['id'].toString(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          emoji == other.emoji &&
          name == other.name &&
          bio == other.bio;

  @override
  int get hashCode =>
      id.hashCode ^ emoji.hashCode ^ name.hashCode ^ bio.hashCode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'name': name,
        'bio': bio,
      };
}
