import 'package:meta/meta.dart';

@immutable
class Person {
  final String emoji;
  final String name;
  final String bio;

  const Person({
    @required this.emoji,
    @required this.name,
    @required this.bio,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
        bio: json['bio'],
        emoji: json['emoji'],
        name: json['name'],
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Person &&
          runtimeType == other.runtimeType &&
          emoji == other.emoji &&
          name == other.name &&
          bio == other.bio;

  @override
  int get hashCode => emoji.hashCode ^ name.hashCode ^ bio.hashCode;
}
