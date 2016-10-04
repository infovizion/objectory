/// Warning! That file is generated. Do not edit it manually
part of domain_model;

class $User {
  static String get name => 'name';
  static String get email => 'email';
  static String get login => 'login';
  static final List<String> allFields = [name, email, login];
}

class $UserTable {
  static Field get name =>
      const Field(id: 'name',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Field get email =>
      const Field(id: 'email',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Field get login =>
      const Field(id: 'login',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Map<String,Field> get fields =>
      {'name': name,'email': email,'login': login};
}

class User extends PersistentObject {
  String get collectionName => 'User';
  List<String> get $allFields => $User.allFields;
  Map<String,Field> get $fields => $UserTable.fields;
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  String get login => getProperty('login');
  set login (String value) => setProperty('login',value);
}

class $Person {
  static String get firstName => 'firstName';
  static String get lastName => 'lastName';
  static String get father => 'father';
  static String get mother => 'mother';
  static final List<String> allFields = [firstName, lastName, father, mother];
}

class $PersonTable {
  static Field get firstName =>
      const Field(id: 'firstName',label: '',title: '',
          type: String,logChanges: true, foreignKey: false);
  static Field get lastName =>
      const Field(id: 'lastName',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Field get father =>
      const Field(id: 'father',label: '',title: '',
          type: Person,logChanges: false, foreignKey: true);
  static Field get mother =>
      const Field(id: 'mother',label: '',title: '',
          type: Person,logChanges: false, foreignKey: true);
  static Map<String,Field> get fields =>
      {'firstName': firstName,'lastName': lastName,'father': father,'mother': mother};
}

class Person extends PersistentObject {
  String get collectionName => 'Person';
  List<String> get $allFields => $Person.allFields;
  Map<String,Field> get $fields => $PersonTable.fields;
  String get firstName => getProperty('firstName');
  set firstName (String value) => setProperty('firstName',value);
  String get lastName => getProperty('lastName');
  set lastName (String value) => setProperty('lastName',value);
  Person get father => getLinkedObject('father', Person);
  set father (Person value) => setLinkedObject('father',value);
  Person get mother => getLinkedObject('mother', Person);
  set mother (Person value) => setLinkedObject('mother',value);
}

class $Author {
  static String get name => 'name';
  static String get email => 'email';
  static String get age => 'age';
  static final List<String> allFields = [name, email, age];
}

class $AuthorTable {
  static Field get name =>
      const Field(id: 'name',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Field get email =>
      const Field(id: 'email',label: '',title: '',
          type: String,logChanges: false, foreignKey: false);
  static Field get age =>
      const Field(id: 'age',label: '',title: '',
          type: int,logChanges: false, foreignKey: false);
  static Map<String,Field> get fields =>
      {'name': name,'email': email,'age': age};
}

class Author extends PersistentObject {
  String get collectionName => 'Author';
  List<String> get $allFields => $Author.allFields;
  Map<String,Field> get $fields => $AuthorTable.fields;
  String get name => getProperty('name');
  set name (String value) => setProperty('name',value);
  String get email => getProperty('email');
  set email (String value) => setProperty('email',value);
  int get age => getProperty('age');
  set age (int value) => setProperty('age',value);
}

registerClasses() {
  objectory.registerClass(User,()=>new User(),()=>new List<User>(), {});
  objectory.registerClass(Person,()=>new Person(),()=>new List<Person>(), {'father': Person, 'mother': Person});
  objectory.registerClass(Author,()=>new Author(),()=>new List<Author>(), {});
}


 /// Postgresql DB Schema 
/*
CREATE SEQUENCE "User_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
CREATE TABLE "User" (
  "id" integer NOT NULL DEFAULT nextval('"User_id_seq"'::regclass),
  "name" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "email" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "login" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  CONSTRAINT "User_px" PRIMARY KEY ("id")
);

CREATE SEQUENCE "Person_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
CREATE TABLE "Person" (
  "id" integer NOT NULL DEFAULT nextval('"Person_id_seq"'::regclass),
  "firstName" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "lastName" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "father" character varying(255),
  "mother" character varying(255),
  CONSTRAINT "Person_px" PRIMARY KEY ("id")
);

CREATE SEQUENCE "Author_id_seq"  INCREMENT 1  MINVALUE 1 MAXVALUE 9223372036854775807 START 1 CACHE 1;
CREATE TABLE "Author" (
  "id" integer NOT NULL DEFAULT nextval('"Author_id_seq"'::regclass),
  "name" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "email" CHARACTER VARYING (255) NOT NULL DEFAULT ,
  "age" integer,
  CONSTRAINT "Author_px" PRIMARY KEY ("id")
);

*/
