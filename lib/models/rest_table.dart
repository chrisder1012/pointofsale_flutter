class RestTable {
  int? id;
  String? name;
  int? num;
  int? tableGroupId;
  int? isOpen; // default 0
  int? sequence; // default 0
  String? description;

  RestTable({
    this.id,
    this.name,
    this.num,
    this.tableGroupId,
    this.isOpen = 0,
    this.sequence = 0,
    this.description,
  });

  factory RestTable.fromJson(dynamic d) {
    return RestTable(
      id: d['id'],
      name: d['name'],
      num: d['num'],
      tableGroupId: d['tableGroupId'],
      isOpen: d['isOpen'],
      sequence: d['sequence'],
      description: d['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'num': num,
        'tableGroupId': tableGroupId,
        'isOpen': isOpen,
        'sequence': sequence,
        'description': description,
      };
}
