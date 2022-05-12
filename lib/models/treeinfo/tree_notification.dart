class TreeNotification {
  final int pinNotification;
  final String title;
  final String description;
  final String createdUserCode;
  final String createdUser;
  final String createdDate;
  final int type;
  final int completed;

  int? pinAlanDet;
  int? pinAlan;

  TreeNotification(
    this.pinNotification,
    this.title,
    this.description,
    this.createdUserCode,
    this.createdUser,
    this.createdDate,
    this.type,
    this.completed,
  );

  TreeNotification.tosend({
    this.pinNotification = 0,
    required this.title,
    required this.description,
    required this.createdUserCode,
    this.createdUser = '',
    this.createdDate = '',
    required this.type,
    this.completed = 0,
    this.pinAlanDet = 0,
    this.pinAlan = 0,
  });
}
