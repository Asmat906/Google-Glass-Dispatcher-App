class Experts {
  String name;
  String lastName;
  String email;
  List expertId;
  String id;
  Experts(this.name, this.lastName,this.email,this.expertId,this.id,);
  Map toJson() => {
        'name': name,
        'lastNmae': lastName,
        'email': email,
        'expertId': expertId,
        'id':id,
      };
     factory Experts.fromJson(dynamic json) {
    return Experts(
     json['name'] as String,
     json['lastNmae'] as String,
     json['email'] as String,
     json['expertId'] as List,
     json['id'] as String);
  }
  @override
  String toString() {
    return ' ${this.name}, ${this.lastName} ,${this.email},${this.expertId},${this.id}';
  }
  
}
class Customer {
  dynamic name;
  dynamic address;
  dynamic email;
  dynamic phone;
  dynamic id;
  Customer(this.name, this.address,this.email,this.phone,this.id);
  Map toJson() => {
        'name': name,
        'address': address,
        'email': email,
        'phone': phone,
        'id': id,
      };
      factory Customer.fromJson(dynamic json) {
    return Customer(
     json['name'] as String,
     json['address'] as String,
     json['email'] as String,
     json['phone'] as String,
     json['id'] as String);
  }
  @override
  String toString() {
    return ' ${this.name}, ${this.address} ,${this.email},${this.phone},${this.id}';
  }
}
class Experties {
  dynamic name;
  Experties(this.name, );
  Map toJson() => {
        'name': name,
      };
      factory Experties.fromJson(dynamic json) {
    return Experties(
     json['name'] as String);
  }
  @override
  String toString() {
    return ' ${this.name}';
  }
}
class Order {
  dynamic id;
  dynamic todo;
  dynamic duration;
  dynamic startTime;
  
  dynamic addressId;
  dynamic addressIdExp;
  
  Order(this.id, this.todo,this.duration,this.startTime,this.addressId,this.addressIdExp);
  Map toJson() => {
        'id': id,
        'todo': todo,
        'duration': duration,
        'startTime': startTime,
        'addressId': addressId,
        'addressIdExp': addressIdExp,
      };
}
class Technician {
   dynamic name;
  dynamic email;
  dynamic phone;
 // dynamic id;
  dynamic techmail;
  dynamic shortcut;
  //Technician(this.name, this.email,this.phone,this.id,this.techmail,this.shortcut,);
  Technician(this.name, this.email,this.phone,this.techmail,this.shortcut,);
  Map toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        //'id': id,
        'techmail': techmail,
        'shortcut': shortcut,
        
      };
     factory Technician.fromJson(dynamic json) {
    return Technician(
     json['name'] as String,
     json['email'] as String,
     json['phone'] as String,
     //json['id'] as dynamic,
     json['techmail'] as String,
     json['shortcut'] as String,
     );
  }
  @override
  String toString() {
    // return ' ${this.name}, ${this.email} ,${this.phone},${this.id}${this.techmail},${this.shortcut}';
    return ' ${this.name}, ${this.email} ,${this.phone},${this.techmail},${this.shortcut}';
  
  }
  

}