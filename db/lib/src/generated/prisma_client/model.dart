class User {
  const User({
    this.id,
    this.email,
    this.name,
  });

  factory User.fromJson(Map json) => User(
        id: json['id'],
        email: json['email'],
        name: json['name'],
      );

  final int? id;

  final String? email;

  final String? name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };
}

class CreateManyUserAndReturnOutputType {
  const CreateManyUserAndReturnOutputType({
    this.id,
    this.email,
    this.name,
  });

  factory CreateManyUserAndReturnOutputType.fromJson(Map json) =>
      CreateManyUserAndReturnOutputType(
        id: json['id'],
        email: json['email'],
        name: json['name'],
      );

  final int? id;

  final String? email;

  final String? name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };
}

class Client {
  const Client({
    this.id,
    this.name,
    this.description,
    this.tenantId,
  });

  factory Client.fromJson(Map json) => Client(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        tenantId: json['tenantId'],
      );

  final String? id;

  final String? name;

  final String? description;

  final String? tenantId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tenantId': tenantId,
      };
}

class CreateManyClientAndReturnOutputType {
  const CreateManyClientAndReturnOutputType({
    this.id,
    this.name,
    this.description,
    this.tenantId,
  });

  factory CreateManyClientAndReturnOutputType.fromJson(Map json) =>
      CreateManyClientAndReturnOutputType(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        tenantId: json['tenantId'],
      );

  final String? id;

  final String? name;

  final String? description;

  final String? tenantId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'tenantId': tenantId,
      };
}
