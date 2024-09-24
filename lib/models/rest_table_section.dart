class RestTableSection {
  int? sectionId;
  String? sectionName;
  String? numberOfTable;
  String? createdAt;
  String? modifiedAt;
  int? restaurantId;

  RestTableSection({
    this.sectionId,
    this.sectionName,
    this.numberOfTable,
    this.createdAt,
    this.modifiedAt,
    this.restaurantId,
  });

  factory RestTableSection.fromJson(dynamic d) {
    return RestTableSection(
      sectionId: d['section_id'],
      sectionName: d['section_name'],
      numberOfTable: d['no_of_table'],
      createdAt: d['created_at'],
      modifiedAt: d['modified_at'],
      restaurantId: d['restro_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'section_id': sectionId,
    'section_name': sectionName,
    'no_of_table': numberOfTable,
    'created_at': createdAt,
    'modified_at': modifiedAt,
    'restro_id': restaurantId,
  };
}