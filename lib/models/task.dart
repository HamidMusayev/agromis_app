class Task {
  int? id;
  int typeId;
  int gardenId;
  int? createUserId;
  int? readedRFIDCount;
  int? readState; //1 başlamamış	2 başlamış 3 bitmiş
  String startDate;
  String endDate;
  String name;
  String? type;
  String description;
  String? gardenName;
  String? createdUser;

  Task(
      this.id,
      this.typeId,
      this.gardenId,
      this.createUserId,
      this.readedRFIDCount,
      this.readState,
      this.startDate,
      this.endDate,
      this.name,
      this.type,
      this.description,
      this.gardenName,
      this.createdUser);

  Task.tosend(
      {required this.typeId,
      required this.gardenId,
      required this.startDate,
      required this.endDate,
      required this.name,
      required this.description});
}
