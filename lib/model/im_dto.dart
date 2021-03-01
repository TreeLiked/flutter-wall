import 'package:iap_app/model/account/account_profile.dart';
import 'package:json_annotation/json_annotation.dart';

part 'im_dto.g.dart';

@JsonSerializable()
class ImDTO<D> {
  int command;
  D data;

  ImDTO();

  Map<String, dynamic> toJson() => _$ImDTOToJson(this);

  factory ImDTO.fromJson(Map<String, dynamic> json) => _$ImDTOFromJson(json);
}
