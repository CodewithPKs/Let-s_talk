class Status {
  final String uid;
  final String userName;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createdAt;
  final String profilePic;
  final String statusId;
  final List<String> whoCanSee;

  Status({
    required this.uid,
    required this.userName,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.profilePic,
    required this.statusId,
    required this.whoCanSee
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName' : userName,
      'phoneNumber' : phoneNumber,
      'photoUrl' : photoUrl,
      'createdAt' : createdAt,
      'profilePic' : profilePic,
      'statusId' : statusId,
      'whoCanSee' : whoCanSee,
    };
  }
  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      profilePic: map['profilePic'] ?? '',
      statusId: map['statusId'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }
}