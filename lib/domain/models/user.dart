class User {
  String id;
  String email;
  String username;
  String avatarUrl;
//  Timestamp createdAt;
//  Timestamp updatedAt;

  User(this.id, this.email, {String username, String avatarUrl})
  : this.username = username,
    this.avatarUrl = avatarUrl;

  User.fromMap(Map<String, dynamic> data)
    : id = data['uid'],
      username = data['username'],
      email = data['email'],
      avatarUrl = data['avatarUrl'];

  Map<String, dynamic> toMap() =>
    {
      'uid': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
    };

}
