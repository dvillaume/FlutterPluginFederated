class Address {
  final String country;
  final String city;

  Address({required this.country, required this.city});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'] ?? '',
      city: json['city'] ?? '',
    );
  }
}

class Site {
  final String name;
  final Address address;

  Site({required this.name, required this.address});

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      name: json['name'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
    );
  }
}

class Identity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String locale;
  final String mfaMethod;
  final String? avatarUrl;
  final String displayName;
  final Site site;
  final String domain;
  final String alternateLogin;
  final String accountSipPassword;
  final String accountLogin;
  final String sipAccessFqdn;

  Identity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.locale,
    required this.mfaMethod,
    this.avatarUrl,
    required this.displayName,
    required this.site,
    required this.domain,
    required this.alternateLogin,
    required this.accountSipPassword,
    required this.accountLogin,
    required this.sipAccessFqdn,
  });

  factory Identity.fromJson(Map<String, dynamic> json) {
    return Identity(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      locale: json['locale'] ?? '',
      mfaMethod: json['mfaMethod'] ?? '',
      avatarUrl: json['avatarUrl'],
      displayName: json['displayName'] ?? '',
      site: Site.fromJson(json['site'] ?? {}),
      domain: json['domain'] ?? '',
      alternateLogin: json['alternateLogin'] ?? '',
      accountSipPassword: json['accountSipPassword'] ?? '',
      accountLogin: json['accountLogin'] ?? '',
      sipAccessFqdn: json['sipAccessFqdn'] ?? '',
    );
  }
}
