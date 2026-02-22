/// 앨범 내 사용자 역할
enum AlbumRole {
  /// 최초 생성자 (앨범 삭제 가능)
  owner,

  /// 관리자 (생성자가 권한 부여, 공유/설정 가능)
  admin,

  /// 일반 회원 (사진 업로드/댓글 작성)
  member,

  /// 비회원 (링크로 접근, 조회만 가능)
  guest,
}

/// AlbumRole 확장 메서드
extension AlbumRoleExtension on AlbumRole {
  /// 관리 권한 여부 (공유, 설정 변경)
  bool get canManage => this == AlbumRole.owner || this == AlbumRole.admin;

  /// 삭제 권한 여부
  bool get canDelete => this == AlbumRole.owner;

  /// 사진 업로드 권한 여부
  bool get canUpload => this != AlbumRole.guest;

  /// 댓글 작성 권한 여부
  bool get canComment => this != AlbumRole.guest;

  /// 역할 표시 텍스트
  String get displayName {
    switch (this) {
      case AlbumRole.owner:
        return '생성자';
      case AlbumRole.admin:
        return '관리자';
      case AlbumRole.member:
        return '멤버';
      case AlbumRole.guest:
        return '게스트';
    }
  }
}