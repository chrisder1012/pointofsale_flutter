class User {
  int? id;
  String? name;
  String? email;
  String? password;
  String? profileimage;
  String? address;
  String? city;
  String? latitude;
  String? longitude;
  String? dob;
  String? about;
  String? phone;
  String? role;
  int? status;
  String? prefLang;
  String? fbToken;
  String? googleToken;
  String? instragramToken;
  String? twitterToken;
  String? token;
  String? resetToken;
  String? platform;
  String? deviceToken;
  String? createdDate;
  int? restaurantId;
  int? ownerId;

  User({
    this.id,
    this.email,
    this.name,
    this.password,
    this.profileimage,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.dob,
    this.about,
    this.phone,
    this.role,
    this.status,
    this.prefLang,
    this.fbToken,
    this.googleToken,
    this.instragramToken,
    this.twitterToken,
    this.token,
    this.resetToken,
    this.platform,
    this.deviceToken,
    this.createdDate,
    this.restaurantId,
    this.ownerId,
  });

  factory User.fromJson(dynamic d) {
    return User(
      id: d['id'],
      name: d['name'],
      email: d['email'],
      password: d['password'],
      profileimage: d['profileimage'],
      address: d['address'],
      city: d['city'],
      latitude: d['latitude'],
      longitude: d['longitude'],
      dob: d['dob'],
      about: d['about'],
      phone: d['phone'],
      role: d['role'],
      status: d['status'],
      prefLang: d['pref_lang'],
      fbToken: d['fb_token'],
      googleToken: d['google_token'],
      instragramToken: d['instragram_token'],
      twitterToken: d['twitter_token'],
      token: d['token'],
      resetToken: d['reset_token'],
      platform: d['platform'],
      deviceToken: d['device_token'],
      createdDate: d['created_date'],
      restaurantId: d['restaurantId'],
      ownerId: d['owner_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
        'profileimage': profileimage,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'dob': dob,
        'about': about,
        'phone': phone,
        'role': role,
        'status': status,
        'pref_lang': prefLang,
        'fb_token': fbToken,
        'google_token': googleToken,
        'instragram_token': instragramToken,
        'twitter_token': twitterToken,
        'token': token,
        'reset_token': resetToken,
        'platform': platform,
        'device_token': deviceToken,
        'created_date': createdDate,
        'restaurantId': restaurantId,
        'owner_id': ownerId,
      };
}
