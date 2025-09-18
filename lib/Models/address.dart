class Address {
  final int? id;
  final String city;
  final String district;
  final String neighbourhood;
  final String streetName;
  final String buildingNumber;
  final String apartmentNumber;
  final String addressName;

  Address({
    this.id,
    required this.city,
    required this.district,
    required this.neighbourhood,
    required this.streetName,
    required this.buildingNumber,
    required this.apartmentNumber,
    required this.addressName,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'city': city,
      'district': district,
      'neighbourhood': neighbourhood,
      'street_name': streetName,
      'building_number': buildingNumber,
      'apartment_number': apartmentNumber,
      'address_name': addressName,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'],
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      neighbourhood: map['neighbourhood'] ?? '',
      streetName: map['street_name'] ?? '',
      buildingNumber: map['building_number']?.toString() ?? '',
      apartmentNumber: map['apartment_number']?.toString() ?? '',
      addressName: map['address_name'] ?? '',
    );
  }
} 