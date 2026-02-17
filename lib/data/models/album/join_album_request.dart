class JoinAlbumRequest {
  final String inviteCode;

  JoinAlbumRequest({required this.inviteCode});

  Map<String, dynamic> toJson() => {'inviteCode': inviteCode};
}