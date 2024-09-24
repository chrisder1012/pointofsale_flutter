class TerminalLocation {
  TerminalLocation({
    required this.id,
    required this.object,
    required this.address,
    required this.displayName,
    this.livemode = false,
    this.metadata = const {},
  });

  String id;
  String object;
  Address address;
  String displayName;
  bool livemode;
  Map<String, dynamic> metadata;

  factory TerminalLocation.fromJson(Map<String, dynamic> json) =>
      TerminalLocation(
        id: json["id"],
        object: json["object"],
        address: Address.fromJson(json["address"]),
        displayName: json["display_name"],
        livemode: json["livemode"],
        metadata: Map.from(json["metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "object": object,
        "address": address.toJson(),
        "display_name": displayName,
        "livemode": livemode,
        "metadata": metadata,
      };
}

class Address {
  Address({
    required this.city,
    required this.country,
    required this.line1,
    required this.line2,
    required this.postalCode,
    required this.state,
  });

  String city;
  String country;
  String line1;
  String line2;
  String postalCode;
  String state;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        city: json["city"],
        country: json["country"],
        line1: json["line1"],
        line2: json["line2"],
        postalCode: json["postal_code"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "city": city,
        "country": country,
        "line1": line1,
        "line2": line2,
        "postal_code": postalCode,
        "state": state,
      };
}
