import 'package:hive/hive.dart';

part 'member.g.dart';

@HiveType(typeId: 0)
class Member extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? avatarColorValue;

  Member({
    required this.id,
    required this.name,
    this.avatarColorValue,
  });

  // Copy with method for immutability
  Member copyWith({
    String? id,
    String? name,
    int? avatarColorValue,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }

  // For JSON serialization (if needed later)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarColorValue': avatarColorValue,
    };
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarColorValue: json['avatarColorValue'] as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Member(id: $id, name: $name)';
}

