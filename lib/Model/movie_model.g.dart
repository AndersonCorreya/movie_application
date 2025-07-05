// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MovieAdapter extends TypeAdapter<Movie> {
  @override
  final int typeId = 0;

  @override
  Movie read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Movie(
      id: fields[0] as int,
      title: fields[1] as String,
      posterUrl: fields[2] as String,
      backdropUrl: fields[3] as String?,
      rating: fields[4] as double?,
      releaseDate: fields[5] as String?,
      overview: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Movie obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.posterUrl)
      ..writeByte(3)
      ..write(obj.backdropUrl)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.releaseDate)
      ..writeByte(6)
      ..write(obj.overview);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MovieAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
