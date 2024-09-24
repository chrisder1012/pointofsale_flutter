// Add rest customers if not exist
import '../models/rest_customer.dart';
import 'database_handler.dart';

Future<int> addRestCustomers() async {
  var dbHandler = DatabaseHandler();
  var customer1 = RestCustomer(
    name: 'Steven',
    address1: 'Address line 1',
    address2: 'Address line 2',
    tel: '12345678',
    email: '12345678@demo.com',
    expenseAmount: 0.0,
    memberTypeId: 1,
    deliveryFee: 2.0,
  );
  var customer2 = RestCustomer(
    name: 'Paul',
    address1: 'Address line 1',
    address2: 'Address line 2',
    tel: '12345679',
    email: '12345679@demo.com',
    expenseAmount: 0.0,
    memberTypeId: 0,
    deliveryFee: 2.0,
  );
  var customer3 = RestCustomer(
    name: 'Smith',
    address1: 'Address line 1',
    address2: 'Address line 2',
    tel: '12345671',
    email: '12345671@demo.com',
    expenseAmount: 0.0,
    memberTypeId: 2,
    deliveryFee: 2.0,
  );
  var customer4 = RestCustomer(
    name: 'Johnson',
    address1: 'Address line 1',
    address2: 'Address line 2',
    tel: '12345672',
    email: '12345672@demo.com',
    expenseAmount: 0.0,
    memberTypeId: 3,
    deliveryFee: 2.0,
  );
  List<RestCustomer> rcs = [customer1, customer2, customer3, customer4];
  return await dbHandler.insertRestCustomer(rcs);
}
