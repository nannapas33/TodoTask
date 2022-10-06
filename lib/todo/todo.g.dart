// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Todo _$$_TodoFromJson(Map<String, dynamic> json) => _$_Todo(
      json['id'] as String,
      json['todotask'] as String,
      json['completed'] as bool,
      json['favorited'] as bool,
    );

Map<String, dynamic> _$$_TodoToJson(_$_Todo instance) => <String, dynamic>{
      'id': instance.id,
      'todotask': instance.todotask,
      'completed': instance.completed,
      'favorited': instance.favorited,
    };
