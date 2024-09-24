class RestUserType {
  int? id;
  String? name;
  int? firstPage; // default 0

  RestUserType({
    this.id,
    this.name,
    this.firstPage = 0,
  });

  factory RestUserType.fromJson(dynamic d) {
    return RestUserType(
      id: d['id'],
      name: d['name'],
      firstPage: d['firstPage'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'firstPage': firstPage,
      };
}
