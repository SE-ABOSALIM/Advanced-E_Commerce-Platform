class User {
  final int? id;
  final String nameSurname;
  final String password;
  final String email;
  final String phoneNumber;
  final String phoneVerified;
  final String emailVerified;

  const User({
    this.id,
    required this.nameSurname,
    required this.password,
    required this.email,
    required this.phoneNumber,
    this.phoneVerified = 'pending',
    this.emailVerified = 'pending',
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'name_surname': nameSurname,
      'password': password,
      'email': email,
      'phone_number': phoneNumber,
      'phone_verified': phoneVerified,
      'email_verified': emailVerified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      nameSurname: map['name_surname'] ?? map['nameSurname'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phone_number'] ?? map['phoneNumber'] ?? '',
      phoneVerified: map['phone_verified'] ?? map['phoneVerified'] ?? 'pending',
      emailVerified: map['email_verified'] ?? map['emailVerified'] ?? 'pending',
    );
  }

  @override
  String toString() {
    return 'User{id: $id, nameSurname: $nameSurname, email: $email, phoneNumber: $phoneNumber, phoneVerified: $phoneVerified, emailVerified: $emailVerified}';
  }
}