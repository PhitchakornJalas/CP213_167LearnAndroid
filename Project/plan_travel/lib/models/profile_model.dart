class ProfileModel {
  final String nickname;
  final String? photoUrl; // เปลี่ยนจาก profileImagePath เป็น photoUrl ตาม Schema
  final String? accountName;
  final String? promptPay;
  final String? email;

  ProfileModel({
    required this.nickname,
    this.photoUrl,
    this.accountName,
    this.promptPay,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'photoUrl': photoUrl,
      'accountName': accountName,
      'promptPay': promptPay,
      'email': email,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      nickname: map['nickname'] ?? map['email'],
      photoUrl: map['photoUrl'],
      accountName: map['accountName'],
      promptPay: map['promptPay'],
      email: map['email'],
    );
  }

  ProfileModel copyWith({
    String? nickname,
    String? photoUrl,
    String? accountName,
    String? promptPay,
    String? email,
  }) {
    return ProfileModel(
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      accountName: accountName ?? this.accountName,
      promptPay: promptPay ?? this.promptPay,
      email: email ?? this.email,
    );
  }
}
