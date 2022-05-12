class CustomDate {
  String day;
  String month;
  String year;
  String curDate = DateTime.now().toIso8601String();

  CustomDate(this.day, this.month, this.year);

  static CustomDate getCurDate() {
    CustomDate date = CustomDate('', '', '');
    DateTime curDate = DateTime.now();

    final List<String> months = [
      'Yanvar',
      'Fevral',
      'Mart',
      'Aprel',
      'May',
      'İyun',
      'İyul',
      'Avqust',
      'Senytabr',
      'Oktyabr',
      'Noyabr',
      'Dekabr'
    ];

    date.month = months[curDate.month - 1];
    date.day = curDate.day.toString();
    date.year = curDate.year.toString();
    date.curDate = '${date.day} ${date.month} ${date.year}';

    return date;
  }
}
