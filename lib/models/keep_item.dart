class KeepItem {
  int? id;
  String? item;
  String? note;
  String? time;

  KeepItem({this.id, this.item, this.note, this.time});

  factory KeepItem.fromJson(dynamic d) {
    return KeepItem(
      id: d['id'],
      item: d['item'],
      note: d['note'],
      time: d['time'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'item': item,
        'note': note,
        'time': time,
      };
}
