class RestTableGroup {
  int? tableGroupId;
  String? name;
  int? receiptPrinterId; // default 11

  RestTableGroup({
    this.tableGroupId,
    this.name,
    this.receiptPrinterId = 11,
  });

  factory RestTableGroup.fromJson(dynamic d) {
    return RestTableGroup(
      tableGroupId: d['tableGroupId'],
      name: d['name'],
      receiptPrinterId: d['receiptPrinterId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tableGroupId': tableGroupId,
        'name': name,
        'receiptPrinterId': receiptPrinterId,
      };
}
