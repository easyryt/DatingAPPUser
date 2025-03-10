class MessagesModel {
  bool? status;
  Data? data;

  MessagesModel({this.status, this.data});

  MessagesModel.fromJson(Map<String, dynamic> json) {
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
  Conversation? conversation;
  List<Messages>? messages;

  Data({this.conversation, this.messages});

  Data.fromJson(Map<String, dynamic> json) {
    conversation = json['conversation'] != null
        ? Conversation.fromJson(json['conversation'])
        : null;
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (conversation != null) {
      data['conversation'] = conversation!.toJson();
    }
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conversation {
  String? sId;
  User? user;
  Partner? partner;
  String? updatedAt;
  String? createdAt;
  int? iV;
  String? lastMessage;

  Conversation(
      {this.sId,
      this.user,
      this.partner,
      this.updatedAt,
      this.createdAt,
      this.iV,
      this.lastMessage});

  Conversation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    partner =
        json['partner'] != null ? Partner.fromJson(json['partner']) : null;
    updatedAt = json['updatedAt'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    lastMessage = json['lastMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (partner != null) {
      data['partner'] = partner!.toJson();
    }
    data['updatedAt'] = updatedAt;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['lastMessage'] = lastMessage;
    return data;
  }
}

class User {
  String? sId;
  String? avatarName;

  User({this.sId, this.avatarName});

  User.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    avatarName = json['avatarName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['avatarName'] = avatarName;
    return data;
  }
}

class Partner {
  String? sId;

  Partner({this.sId});

  Partner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    return data;
  }
}

class Messages {
  String? sId;
  String? conversationId;
  String? senderId;
  String? receiverId;
  String? content;
  String? status;
  String? senderType;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Messages(
      {this.sId,
      this.conversationId,
      this.senderId,
      this.receiverId,
      this.content,
      this.status,
      this.senderType,
      this.createdAt,
      this.updatedAt,
      this.iV});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    conversationId = json['conversationId'];
    senderId = json['senderId'];
    receiverId = json['receiverId'];
    content = json['content'];
    status = json['status'];
    senderType = json['senderType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['conversationId'] = conversationId;
    data['senderId'] = senderId;
    data['receiverId'] = receiverId;
    data['content'] = content;
    data['status'] = status;
    data['senderType'] = senderType;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
