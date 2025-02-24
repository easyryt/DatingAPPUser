class ProfileData {
  bool? status;
  Data? data;

  ProfileData({this.status, this.data});

  ProfileData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? name;
  String? email;
  String? password;
  String? gender;
  List<dynamic>? languages;
  String? intersted;
  String? fcmToken;
  String? role;
  int? walletAmount;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Data(
      {this.sId,
      this.name,
      this.email,
      this.password,
      this.gender,
      this.languages,
      this.intersted,
      this.fcmToken,
      this.role,
      this.walletAmount,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    password = json['password'];
    gender = json['gender'];
    if (json['languages'] != null) {
      languages = [];
      json['languages'].forEach((v) {
        languages!.add(json['languages']);
      });
    }
    intersted = json['intersted'];
    fcmToken = json['fcmToken'];
    role = json['role'];
    walletAmount = json['walletAmount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['email'] = email;
    data['password'] = password;
    data['gender'] = gender;
    if (languages != null) {
      data['languages'] = languages!.map((v) => v.toJson()).toList();
    }
    data['intersted'] = intersted;
    data['fcmToken'] = fcmToken;
    data['role'] = role;
    data['walletAmount'] = walletAmount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
