class RFIDGardenResult{
  bool isSuccess;
  bool isOneTree;
  int maxTreeCount;
  int minTreeCount;

  RFIDGardenResult({required this.isOneTree, required this.maxTreeCount, required this.minTreeCount, required this.isSuccess});
}