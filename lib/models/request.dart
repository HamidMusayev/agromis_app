class Request{
  int createusercode;
  bool isonetree;
  int infotype;
  String title;
  String description;
  String epc;
  bool isselectedall;//sıraya aid isə
  List<int> selectedtrees;//sıraya aid isə
  List<String> pictures;

  Request({this.createusercode, this.isonetree, this.infotype, this.title, this.description, this.epc, this.isselectedall, this.selectedtrees, this.pictures});
}