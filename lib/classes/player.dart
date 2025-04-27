import 'package:uuid/uuid.dart';

class Player {
  final String id; // Identifiant unique
  final String firstName;
  final String lastName;
  final String birthdate;
  final String address;
  final String phone;
  final String email;
  final String arrivalDate;
  final String position;
  final String preferredFoot;

  Player({
    String? id, // Si l'id n'est pas fourni, il sera généré automatiquement
    required this.firstName,
    required this.lastName,
    required this.birthdate,
    required this.address,
    required this.phone,
    required this.email,
    required this.arrivalDate,
    required this.position,
    required this.preferredFoot,
  }) : id = id ?? Uuid().v4(); // Génération d'un identifiant unique

  // Convertir en JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'birthdate': birthdate,
    'address': address,
    'phone': phone,
    'email': email,
    'arrivalDate': arrivalDate,
    'position': position,
    'preferredFoot': preferredFoot,
  };

  // Créer un Player depuis JSON
  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'], // Assurez-vous que l'id est bien inclus dans le JSON
    firstName: json['firstName'],
    lastName: json['lastName'],
    birthdate: json['birthdate'],
    address: json['address'],
    phone: json['phone'],
    email: json['email'],
    arrivalDate: json['arrivalDate'],
    position: json['position'],
    preferredFoot: json['preferredFoot'],
  );
}
