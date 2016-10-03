class Field {
  final String id;
  final String label;
  final String title;
  final Type type;
  final bool foreignKey;
  final bool logChanges;
  const Field({this.id: '', this.label: '', this.title: '', this.type: Object, this.logChanges: false, this.foreignKey: false});
}
