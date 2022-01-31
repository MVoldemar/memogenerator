import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:memogenerator/data/models/position.dart';

part 'text_with_position.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TextWithPosition extends Equatable {
  final String id;
  final String text;
  final Position position;
  final double? fontSize;
  @JsonKey(toJson: colorToJson , fromJson: colorFromJson)
  final Color? color;
  @JsonKey(toJson: weightToJson , fromJson: weightFromJson)
  final FontWeight? fontWeight;

  TextWithPosition({
    required this.id,
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
    required this.fontWeight,

  });

  factory TextWithPosition.fromJson(final Map<String, dynamic> json) =>
      _$TextWithPositionFromJson(json);

  Map<String, dynamic> toJson() => _$TextWithPositionToJson(this);

  @override
  List<Object?> get props => [id, text, position, fontSize, color, fontWeight];
}

int? weightToJson(final FontWeight? fontWeight){
  return fontWeight == null ? null : fontWeight.index;
}

FontWeight? weightFromJson(final int? weightInt){
  if(weightInt == null) {
    return null;
  }
  final FontWeight fontWeight;
  switch(weightInt){
    case 0 : fontWeight = FontWeight.w100;
    return fontWeight;
    case 1 : fontWeight = FontWeight.w200;
    return fontWeight;
    case 2 : fontWeight = FontWeight.w300;
    return fontWeight;
    case 3 : fontWeight = FontWeight.w400;
    return fontWeight;
    case 4 : fontWeight = FontWeight.w500;
    return fontWeight;
    case 5 : fontWeight = FontWeight.w600;
    return fontWeight;
    case 6 : fontWeight = FontWeight.w700;
    return fontWeight;
    case 7 : fontWeight = FontWeight.w800;
    return fontWeight;
    case 8 : fontWeight = FontWeight.w900;
    return fontWeight;
  }
 // return intColor == null ? null : Color(intColor);
}

String? colorToJson(final  Color? color) {
  return color == null ? null : color.value.toRadixString(16);

}
Color? colorFromJson(final String? colorString){
  if(colorString == null) {
    return null;
  }
  final intColor = int.tryParse(colorString, radix: 16);
  return intColor == null ? null : Color(intColor);
}