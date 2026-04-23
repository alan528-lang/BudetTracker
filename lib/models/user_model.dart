class UserModel {
  final String username;
  final String name;
  final String hashedPass;
  final DateTime since;

  const UserModel({
    required this.username,
    required this.name,
    required this.hashedPass,
    required this.since,
  });

  String get initials => name.isNotEmpty ? name[0].toUpperCase() : 'U';
  String get firstName => name.split(' ').first;

  Map<String, dynamic> toJson() => {
    'username':   username,
    'name':       name,
    'hashedPass': hashedPass,
    'since':      since.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    username:   j['username'] as String,
    name:       j['name']     as String,
    hashedPass: j['hashedPass'] as String,
    since:      DateTime.parse(j['since'] as String),
  );
}
