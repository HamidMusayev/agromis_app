class Request {
  int createusercode;
  bool isonetree;
  int infotype;
  String title;
  String description;
  String epc;
  bool isselectedall; //sıraya aid isə
  List<int> selectedtrees; //sıraya aid isə
  List<String> pictures;

  Request(
      {required this.createusercode,
      required this.isonetree,
      required this.infotype,
      required this.title,
      required this.description,
      required this.epc,
      required this.isselectedall,
      required this.selectedtrees,
      required this.pictures});
}
