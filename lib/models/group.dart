import 'package:zabor/models/menu_item.dart';

class Group {
  int? id;
  String? name;
  // int? groupId;
  String? monopenTime;
  String? moncloseTime;
  String? tueopenTime;
  String? tuecloseTime;
  String? wedopenTime;
  String? wedcloseTime;
  String? thuopenTime;
  String? thucloseTime;
  String? friopenTime;
  String? fricloseTime;
  String? satopenTime;
  String? satcloseTime;
  String? sunopenTime;
  String? suncloseTime;
  List<MItem>? items;

  Group({
    this.id,
    this.name,
    this.monopenTime,
    this.moncloseTime,
    this.tueopenTime,
    this.tuecloseTime,
    this.wedopenTime,
    this.wedcloseTime,
    this.thuopenTime,
    this.thucloseTime,
    this.friopenTime,
    this.fricloseTime,
    this.satopenTime,
    this.satcloseTime,
    this.sunopenTime,
    this.suncloseTime,
    this.items,
  });

  factory Group.fromJson(dynamic d) {
    List<MItem>? items;
    if (d['items'] != null) {
      List<dynamic> snap = [];
      snap.addAll(d['items']);
      items = snap.map((e) => MItem.fromJson(e)).toList();
    }

    return Group(
      name: d['name'],
      // groupId: d['groupid'],
      monopenTime: d['monopen_time'],
      moncloseTime: d['monclose_time'],
      tueopenTime: d['tueopen_time'],
      tuecloseTime: d['tueclose_time'],
      wedopenTime: d['wedopen_time'],
      wedcloseTime: d['wedclose_time'],
      thuopenTime: d['thuopen_time'],
      thucloseTime: d['thuclose_time'],
      friopenTime: d['friopen_time'],
      fricloseTime: d['friclose_time'],
      satopenTime: d['satopen_time'],
      satcloseTime: d['satclose_time'],
      sunopenTime: d['sunopen_time'],
      suncloseTime: d['sunclose_time'],
      items: items,
    );
  }
}
