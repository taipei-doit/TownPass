import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

@JsonSerializable(explicitToJson: true)
class AccountResponse {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'reasonPhrase')
  final String reasonPhrase;

  @JsonKey(name: 'data')
  final Account account;

  @JsonKey(name: 'extra')
  final String? extra;

  @JsonKey(name: 'version')
  final String version;

  const AccountResponse({
    required this.name,
    required this.status,
    required this.reasonPhrase,
    required this.account,
    required this.extra,
    required this.version,
  });

  factory AccountResponse.fromJson(Map<String, dynamic> json) => _$AccountResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AccountResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Account {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'account')
  final String account;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'realName')
  final String realName;

  @JsonKey(name: 'idNo')
  final String idNumber;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'phoneNo')
  final String phoneNumber;

  @JsonKey(name: 'birthday')
  final String birthday;

  @JsonKey(name: 'memberType')
  final String memberType;

  @JsonKey(name: 'verifyLevel')
  final String verifyLevel;

  @JsonKey(name: 'addresses')
  final List<Address> addressList;

  @JsonKey(name: 'residentAddress')
  final String residentAddress;

  @JsonKey(name: 'citizen')
  final bool citizen;

  @JsonKey(name: 'nativePeople')
  final bool nativePeople;

  @JsonKey(name: 'cityInternetUid')
  final String cityInternetUid;

  const Account({
    required this.id,
    required this.account,
    required this.username,
    required this.realName,
    required this.idNumber,
    required this.email,
    required this.phoneNumber,
    required this.birthday,
    required this.memberType,
    required this.verifyLevel,
    required this.addressList,
    required this.residentAddress,
    required this.citizen,
    required this.nativePeople,
    required this.cityInternetUid,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Address {
  @JsonKey(name: 'zip3')
  final int zip3;

  @JsonKey(name: 'city')
  final String city;

  @JsonKey(name: 'town')
  final String town;

  @JsonKey(name: 'village')
  final String village;

  @JsonKey(name: 'street')
  final String street;

  @JsonKey(name: 'usageType')
  final String usageType;

  @JsonKey(name: 'seq')
  final int seq;

  @JsonKey(name: 'priority')
  final bool priority;

  const Address({
    required this.zip3,
    required this.city,
    required this.town,
    required this.village,
    required this.street,
    required this.usageType,
    required this.seq,
    required this.priority,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
