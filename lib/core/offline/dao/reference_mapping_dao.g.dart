// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_mapping_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferenceMappingDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReferenceMappingTableTable get referenceMappingTable =>
      attachedDatabase.referenceMappingTable;
  ReferenceMappingDaoManager get managers => ReferenceMappingDaoManager(this);
}

class ReferenceMappingDaoManager {
  final _$ReferenceMappingDaoMixin _db;
  ReferenceMappingDaoManager(this._db);
  $$ReferenceMappingTableTableTableManager get referenceMappingTable =>
      $$ReferenceMappingTableTableTableManager(
          _db.attachedDatabase, _db.referenceMappingTable);
}
