import 'package:drift/drift.dart';

class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().nullable()();
  TextColumn get role => text().nullable()();
  BoolColumn get viewAllVisits => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Countries extends Table {
  TextColumn get id => text()();
  TextColumn get nameEn => text()();
  TextColumn get nameEs => text().nullable()();
  TextColumn get nameFr => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get countryId => text()();
  TextColumn get coreAreaId => text()();
  TextColumn get activityId => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class VisitTrees extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text()();
  TextColumn get treeSpeciesId => text()();
  IntColumn get count => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class VisitMedia extends Table {
  TextColumn get id => text()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get visitId => text()();
  TextColumn get kind => text()();
  TextColumn get storagePath => text().nullable()();
  TextColumn get sha256 => text()();
  TextColumn get contentType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get uploadStatus => text().withDefault(const Constant('pending'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class OutboxEvents extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get clientUuid => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()(); // jsonb
  TextColumn get status => text()(); // enum
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  
  @override
  Set<Column> get primaryKey => {key};
}

class Translations extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get field => text()();
  TextColumn get locale => text()();
  TextColumn get value => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}
