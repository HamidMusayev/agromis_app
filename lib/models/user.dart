class User {
  String name;
  String surname;
  String email;
  String password;
  int? id;

  User(this.name, this.surname, this.email, this.password);
  User.withid(this.id, this.name, this.surname, this.email, this.password);

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        surname = json['surname'],
        email = json['email'],
        password = json['password'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'email': email,
        'password': password
      };
}
