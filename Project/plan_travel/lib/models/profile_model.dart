class ProfileModel {
  final String nickname;
  final String? profileImagePath;

  ProfileModel({
    required this.nickname,
    this.profileImagePath,
  });

  // แปลงเป็น Map สำหรับบันทึกลง SharedPreferences (หรือ JSON)
  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'profileImagePath': profileImagePath,
    };
  }

  // สร้าง Object จาก Map
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      nickname: map['nickname'] ?? '',
      profileImagePath: map['profileImagePath'],
    );
  }
}
