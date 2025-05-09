class User {
  final String id;
  final String username;
  final String token;
  
  User({
    required this.id,
    required this.username,
    required this.token,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      token: json['token'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'token': token,
    };
  }
}