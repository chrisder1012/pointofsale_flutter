class ResOpenCloseTime {
  int? id;
  int? res_id;
  String? monopen_time;
  String? monclose_time;
  String? tueopen_time;
  String? tueclose_time;
  String? wedopen_time;
  String? wedclose_time;
  String? thuopen_time;
  String? thuclose_time;
  String? friopen_time;
  String? friclose_time;
  String? satopen_time;
  String? satclose_time;
  String? sunopen_time;
  String? sunclose_time;
  String? created_at;

  ResOpenCloseTime({
    this.id,
    this.res_id,
    this.monclose_time,
    this.created_at,
    this.friclose_time,
    this.friopen_time,
    this.monopen_time,
    this.satclose_time,
    this.satopen_time,
    this.sunclose_time,
    this.sunopen_time,
    this.thuclose_time,
    this.thuopen_time,
    this.tueclose_time,
    this.tueopen_time,
    this.wedclose_time,
    this.wedopen_time,
  });

  factory ResOpenCloseTime.fromJson(dynamic d) {
    return ResOpenCloseTime(
      id: d['id'],
      res_id: d['res_id'],
      monopen_time: d['monopen_time'],
      monclose_time: d['monclose_time'],
      tueopen_time: d['tueopen_time'],
      tueclose_time: d['tueclose_time'],
      wedopen_time: d['wedopen_time'],
      wedclose_time: d['wedclose_time'],
      thuopen_time: d['thuopen_time'],
      thuclose_time: d['thuclose_time'],
      friopen_time: d['friopen_time'],
      friclose_time: d['friclose_time'],
      satopen_time: d['satopen_time'],
      satclose_time: d['satclose_time'],
      sunopen_time: d['sunopen_time'],
      sunclose_time: d['sunclose_time'],
      created_at: d['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'res_id': res_id,
        'monopen_time': monopen_time,
        'monclose_time': monclose_time,
        'tueopen_time': tueopen_time,
        'tueclose_time': tueclose_time,
        'wedopen_time': wedopen_time,
        'wedclose_time': wedclose_time,
        'thuopen_time': thuopen_time,
        'thuclose_time': thuclose_time,
        'friopen_time': friopen_time,
        'friclose_time': friclose_time,
        'satopen_time': satopen_time,
        'satclose_time': satclose_time,
        'sunopen_time': sunopen_time,
        'sunclose_time': sunclose_time,
        'created_at': created_at,
      };
}
