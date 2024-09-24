import 'dart:convert';
import 'dart:core';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/models/cart.dart';
import 'package:zabor/models/compliment_item.dart';
import 'package:zabor/models/keep_item.dart';
import 'package:zabor/models/petty_cash_close.dart';
import 'package:zabor/models/rest_customer.dart';
import 'package:zabor/models/rest_discount.dart';
import 'package:zabor/models/rest_member_type.dart';
import 'package:zabor/models/rest_order.dart';
import 'package:zabor/models/rest_order_item.dart';
import 'package:zabor/models/rest_order_payment.dart';
import 'package:zabor/models/restaurant.dart';
import 'package:zabor/models/petty_cash.dart';
import 'package:zabor/models/restaurant_open_close_time.dart';

import '../models/order.dart';
import '../models/rest_table.dart';
import '../models/tax.dart';
import '../models/user.dart';

///
/// Database handler for sqflite
///

class DatabaseHandler {
  final String tbRestTable = 'rest_table';
  final String tbRestCustomer = 'rest_customer';
  final String tbRestMemberType = 'rest_member_type';
  final String tbRestTableGroup = 'rest_table_group';
  final String tbRestOrder = 'rest_order';
  final String tbRestOrderItem = 'rest_order_item';
  final String tbRestUserType = 'rest_user_type';
  final String tbRestDiscount = 'rest_discount';
  final String tbRestComplimentItem = 'rest_compliment_item';
  final String tbRestCartItem = 'rest_cart_item';
  final String tbRestCart = 'rest_cart';
  final String tbRestResponse = 'rest_response';
  final String tbKeepItem = 'keep_item';
  final String tbRestPayment = 'rest_payment';
  final String tbPettyCash = 'petty_cash'; //Adicionada codepaeza 20/05/2023
  final String tbPettyCloseCash =
      'petty_close_cash'; //Adicionada codepaeza 21/05/2023
  final String tbUser = 'users';
  final String tbCashierShifts = 'cashier_shifts';
  final String tbSetting = 'setting';

  /// update 2024/07/18
  final String tbCart = 'cart';
  final String tbRestaurant = 'restaurant';
  final String tbResOpenCloseTime = 'res_openclose_time';
  final String tbOrders = 'orders';

  final String sqlRestTable =
      "CREATE TABLE rest_table (id integer primary key, name text, num integer, tableGroupId integer, isOpen integer default 0, sequence integer default 0, description text)";
  final String sqlRestCustomer =
      "CREATE TABLE rest_customer (id integer primary key autoincrement, name text, address1 text, address2 text, address3 text,zipCode text, tel text, email text, expenseAmount real, memberTypeId integer default 0, prepaidAmount real default 0, rewardPoint real default 0, deliveryFee real)";
  final String sqlRestMemberType =
      "CREATE TABLE rest_member_type (id integer primary key autoincrement, name text, discountId int, memberPriceId int, isPrepaid boolean,  isReward boolean, rewardPointUnit real)";
  // final String sqlUsers =
  //     "CREATE TABLE rest_user ( id integer primary key, name text, email text, password text, profileimage text, address text, city text, latitude text, longitude text, dob text, about text, phone text, role integer, status integer default 1, pref_lang text, fb_token text, google_token text, instagram_token text, twitter_token text, token text, reset_token text, platform text, device_token text, created_date text, restaurantId integer, owner_id integer)";
  final String sqlUsers =
      "CREATE TABLE users ( id integer primary key, name text, email text, password text, profileimage text, role integer, status integer default 1, restaurantId integer)";
  final String sqlRestTableGroup =
      "CREATE TABLE rest_table_group (tableGroupId integer primary key, name text,receiptPrinterId integer default 11)";
  final String sqlRestOrder =
      "CREATE TABLE rest_order (id integer primary key, cartId integer, userId integer, resId integer, foodTax real, drinkTax real, tax real, convienenceFee real, total real, cod integer, orderTime text, endTime text, customerId integer, customerName text, orderNum text,invoiceNum text, tableId integer, tableName text, tableGroupId integer, personNum integer, status integer, openOrderStatus integer, printReceipt integer, remark text, waiterName text, cashierName text, cancelReason text, cancelPerson text, minimumCharge real, subTotal real, discountAmt real, serviceAmt real, rounding real, tax1Amt real, tax1TotalAmt real, tax1Name text, tax2Amt real, tax2TotalAmt real, tax2Name text, tax3Amt real, tax3TotalAmt real, tax3Name text, deliveryFee real, serviceFeeName text, servicePercentage real,discountReason text,discountPercentage real, amount real, minimumChargeType integer, minimumChargeSet real, processFee real, cashDiscount real, splitType integer default 0, receiptNote text, orderCount integer default 0,receiptPrinterId integer,deliveryStatus integer default 0,deliveryTime text,deliveriedTime text,deliveryman text, deliveryArriveDate text, deliveryArriveTime text, customerPhone text, orderType integer, orderMemberType integer,refundReason text, taxStatus integer, customerOrderStatus integer, refundTime text, kitchenBarcode text, hasRefund integer default 0, hasVoidItem integer default 0, hasAllItemServed integer default 0, hasAllItemCooked integer default 0, hasCookedItem integer default 0, hasHoldItem integer default 0, hasFiredItem integer default 0, updateTimeStamp text, cashCloseOutId integer default 0, kdsOrderTime text, transactionTime text, transactionReason text)";
  final String sqlRestOrderItem =
      "CREATE TABLE rest_order_item (id integer primary key, taxtype text, isShow boolean, isFood boolean, isState boolean, isCity boolean, isNote boolean, note text, quantity integer, taxvalue real, orderId integer, billId integer default 0, departmentName text, categoryName text, categorySequence integer, itemId integer, itemName text,kitchenItemName text, price real, cost real default 0, qty real, remark text, orderTime text, endTime text, cancelReason text, status integer, discountable integer default 1, discountAmt real, discountPercentage real, discountName text, discountType integer default 0, isGift integer, giftRewardPoint real, kitchenBarcode text,localPrinter integer default 0,  printerIds text, printSeparate text, sequence integer, unit text, courseId integer, courseName text, staffName text)";
  final String sqlRestUserType =
      "CREATE TABLE rest_user_type (id integer primary key, name text, firstPage integer default 0)";
  final String sqlRestDiscount =
      "CREATE TABLE rest_discount (id integer primary key autoincrement, reason text, isPercentage integer, amount real)";
  final String sqlRestComplimentItem =
      "CREATE TABLE rest_compliment_item (id integer primary key autoincrement, orderId integer, cartItemId integer, option_name text, option_price real, ci_id integer)";
  final String sqlRestCartItem =
      "CREATE TABLE rest_cart_item (id integer primary key autoincrement, item_id integer, item_name text, item_price real, customizations text, taxtype text, item_quantity integer, item_pic text, item_des text, is_show boolean, is_food boolean, is_state boolean, is_city boolean, is_note boolean, note text, quantity integer, taxvalue real)";
  final String sqlRestCart =
      "CREATE TABLE rest_cart (id integer, user_id integer, res_id integer, food_tax real, drink_tax real, tax real, total real, subtotal real, cod integer)";
  final String sqlRestResponse =
      "CREATE TABLE rest_response (min_order_value integer, max_order_value integer, convenience_fee_type text, convenience_fee real, cod integer, name text, status integer, longitude real, latitude real, food_tax text, drink_tax text, grand_tax text, id integer, res_id integer, monopen_time text, monclose_time text, tueopen_time text, tueclose_time text, wedopen_time text, wedclose_time text, thuopen_time text, thuclose_time text, friopen_time text, friclose_time text, satopen_time text, satclose_time text, sunopen_time text, sunclose_time text, created_at text)";
  final String sqlKeepItem =
      "CREATE TABLE keep_item (id integer primary key autoincrement, item text, note text, time text)";
  final String sqlRestPayment =
      "CREATE TABLE rest_payment (id integer primary key autoincrement, order_id integer, items text, payment_type integer, table_name text, amount real, time text)";
  final String sqlCart =
      "CREATE TABLE cart (id integer primary key autoincrement, user_id integer, res_id integer, cart text, food_tax real, drink_tax real, convenience_fee real, sub_total real, tax real, total real, ordered integer default 0, created_at text, table_id integer )";

  //Tablas adicionada por codepaeza para manejo de valores de arqueos inicial y final
  final String sqlPettyCash =
      "CREATE TABLE petty_cash (id integer, name text, valueEn real, valueCo real, quantity integer)";

  final String sqlPettyCloseCash =
      "CREATE TABLE petty_close_cash (id integer, nameClose text, valueCoClose real, valueEnClose real, quantityClose integer)";
  final String sqlCashierShifts =
      "CREATE TABLE cashier_shifts (id integer primary key autoincrement, restaurant_id integer, cashier_id integer, open_date_time text, drawer_cash_on_open real, close_date_time text, drawer_cash_on_close real, internal_comment text, created_by integer, updated_by integer, deleted_by integer, created_at text, updated_at text, deleted_at )";
  final String sqlSetting =
      "CREATE TABLE setting (id integer primary key autoincrement, email text, address text, contact text, city text, food_tax text, drink_tax text, grand_tax text, delivery_charge text, base_delivery_distance real, extra_delivery_charge real, driver_fee text, fb_link text, twitter_link text, insta_link text, created_date text)";
  final String sqlRestaurant =
      "CREATE TABLE restaurant (id integer primary key autoincrement, name text, email text, description text, description_es text, status integer, category integer, subcategory text, created_by integer, restaurantpic text, city text, address text, contact text, website text, latitude text, longitude text, avg_cost integer, claimed integer default 0, min_order_value integer, max_order_value integer, cod integer, stripe_acc text, cancel_charge integer, can_edit_pos integer, can_edit_menu integer, can_edit_reservation integer, can_edit_order integer, can_edit_discount integer, created_at text, ath_acc text, ath_secret text, stripe_fee integer, convenience_fee_type text, convenience_fee real, food_tax text, drink_tax text, grand_tax text, delivery_charge text, base_delivery_distance real, driver_fee text, currency_code text, imagesUploadedInfo text, default_display_language_code text)";
  final String sqlResOpenCloseTime =
      "CREATE TABLE res_openclose_time (id integer primary key autoincrement, res_id integer, monopen_time text, monclose_time text, tueopen_time text, tueclose_time text, wedopen_time text, wedclose_time text, thuopen_time text, thuclose_time text, friopen_time text, friclose_time text, satopen_time text, satclose_time text, sunopen_time text, sunclose_time text, created_at text)";
  final String sqlOrders =
      "CREATE TABLE orders (id integer primary key autoincrement, user_id integer, res_id integer, cart_id integer, order_hash text, cart text, food_tax real, drink_tax real, subtotal real, tax real, delivery_charge real, total real, discount real, without_discount real, delieverydate text, timeSlots text, order_code integer, code_verified integer, delivery_mode integer, delivered_by text, payment_mode integer, status text, payment_status integer, payment_data text, order_by text, cooking_time text, orderissue text, cancelled_by text, created_date text, tb_num integer, convenience_fee real, email real, shift_id integer, invoice_number text, res_name text)";

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, Config().dbName),
      onCreate: (database, version) async {
        await database.execute(sqlRestTable);
        await database.execute(sqlRestCustomer);
        await database.execute(sqlRestMemberType);
        await database.execute(sqlUsers);
        await database.execute(sqlRestTableGroup);
        await database.execute(sqlRestOrder);
        await database.execute(sqlRestOrderItem);
        await database.execute(sqlRestUserType);
        await database.execute(sqlRestDiscount);
        await database.execute(sqlRestComplimentItem);
        await database.execute(sqlRestResponse);
        await database.execute(sqlKeepItem);
        await database.execute(sqlRestPayment);
        await database
            .execute(sqlPettyCash); //Adicionada por codepaeza 20/05/2023
        await database
            .execute(sqlPettyCloseCash); //Adicionada por codepaeza 21/05/2023
        await database.execute(sqlCart);
        await database.execute(sqlCashierShifts);
        await database.execute(sqlSetting);
        await database.execute(sqlRestaurant);
        await database.execute(sqlResOpenCloseTime);
        await database.execute(sqlOrders);
      },
      version: 1,
    );
  }

  ///
  /// Delete all tables
  ///
  Future<void> deleteAllTables() async {
    final db = await initializeDB();
    await db.transaction((txn) async {
      var batch = txn.batch();
      batch.delete(tbRestTable);
      batch.delete(tbRestCustomer);
      batch.delete(tbRestMemberType);
      batch.delete(tbUser);
      batch.delete(tbRestTableGroup);
      batch.delete(tbRestOrder);
      batch.delete(tbRestOrderItem);
      batch.delete(tbRestUserType);
      // db.delete(sqlRestDiscount);
      batch.delete(tbRestComplimentItem);
      batch.delete(tbRestResponse);
      batch.delete(tbKeepItem);
      batch.delete(tbPettyCash); //Adicionado codepaeza 20/05/2023
      batch.delete(tbPettyCloseCash); //Adicionado codepaeza 20/05/2023
      batch.delete(tbCart);
      await batch.commit();
    });
  }

  ///
  /// Rest table
  ///
  // Insert rest table
  Future<int> insertRestTable(List<RestTable> tables) async {
    int result = 0;
    try {
      final db = await initializeDB();
      for (var table in tables) {
        result = await db.insert(tbRestTable, table.toJson());
      }
    } catch (e) {
      print(e);
    }

    return result;
  }

  // Retrieve rest table data
  Future<List<RestTable>> retireveRestTable() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(tbRestTable);
    return queryResult.map((e) => RestTable.fromJson(e)).toList();
  }

  // Delete rest table data
  Future<void> deleteRestTable(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestTable,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Delete rest tables from restaurant id
  Future<bool> deleteRestTablesByRestId(int restId) async {
    try {
      final db = await initializeDB();
      await db.delete(
        tbRestTable,
        where: "tableGroupId = ?",
        whereArgs: [restId],
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  // Update rest table
  Future<void> updateRestTable(Map<String, Object?> values, int id) async {
    final db = await initializeDB();
    await db.update(
      tbRestTable,
      values,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest Customer table
  ///
  // Insert rest customer
  Future<int> insertRestCustomer(List<RestCustomer> customers) async {
    int result = 0;
    final db = await initializeDB();
    for (var customer in customers) {
      result = await db.insert(tbRestCustomer, customer.toJson());
    }
    return result;
  }

  // Retrieve rest customer data
  Future<List<RestCustomer>> retireveRestCustomer() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestCustomer);
    return queryResult.map((e) => RestCustomer.fromJson(e)).toList();
  }

  // Delete rest customer data
  Future<void> deleteRestCustomer(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestCustomer,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest member type table
  ///
  // Insert rest member type
  Future<int> insertRestMemberType(List<RestMemberType> memberTypes) async {
    int result = 0;
    final db = await initializeDB();
    for (var membertype in memberTypes) {
      result = await db.insert(tbRestMemberType, membertype.toJson());
    }
    return result;
  }

  // Retrieve rest member type data
  Future<List<RestMemberType>> retireveRestMemberType() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestMemberType);
    return queryResult.map((e) => RestMemberType.fromJson(e)).toList();
  }

  // Delete rest member type data
  Future<void> deleteRestMemberType(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestMemberType,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest discount table
  ///
  // Insert rest discount
  Future<int> insertRestDiscount(List<RestDiscount> discounts) async {
    int result = 0;
    final db = await initializeDB();
    for (var discount in discounts) {
      result = await db.insert(tbRestDiscount, discount.toJson());
    }
    return result;
  }

  // Retrieve rest discount
  Future<List<RestDiscount>> retireveRestDiscount() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestDiscount);
    return queryResult.map((e) => RestDiscount.fromJson(e)).toList();
  }

  // Delete rest discount
  Future<void> deleteRestDiscount(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestDiscount,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest Order
  ///
  // Insert rest order
  Future<int> insertRestOrder(List<RestOrder> orders) async {
    int result = 0;
    final db = await initializeDB();
    for (var order in orders) {
      result = await db.insert(tbRestOrder, order.toJson());
    }
    return result;
  }

  // Update rest order
  Future<void> updateRestOrder(int id, int personNum) async {
    final db = await initializeDB();
    var values = {'personNum': personNum};
    await db.update(
      tbRestOrder,
      values,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest Order
  ///
  // Insert rest order
  Future<int> insertOrUpdateRestOrder(List<RestOrder> orders,
      {bool isUpdate = false}) async {
    int result = 0;
    final db = await initializeDB();
    for (var order in orders) {
      result = await db.insert(tbRestOrder, order.toJson());
    }
    return result;
  }

  // Retrieve rest orders
  Future<List<RestOrder>> retireveRestOrders() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(tbRestOrder);
    return queryResult.map((e) => RestOrder.fromJson(e)).toList();
  }

  // Retrieve rest order from id
  Future<RestOrder> retireveRestOrder(int id) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(
      tbRestOrder,
      where: "id = ?",
      whereArgs: [id],
    );
    return queryResult.map((e) => RestOrder.fromJson(e)).toList().first;
  }

  // Delete rest order
  Future<void> deleteRestOrder(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestOrder,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest Order Item
  ///
  // Insert rest order item
  Future<int> insertRestOrderItem(List<RestOrderItem> orderItems) async {
    int result = 0;
    final db = await initializeDB();
    for (var orderItem in orderItems) {
      result = await db.insert(tbRestOrderItem, orderItem.toJson());
    }
    return result;
  }

  // Retrieve rest order items
  Future<List<RestOrderItem>> retireveRestOrderItem() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestOrderItem);
    return queryResult.map((e) => RestOrderItem.fromJson(e)).toList();
  }

  // Retrieve rest order items from order id
  Future<List<RestOrderItem>> retireveRestOrderItemFromOrderId(
      int orderId) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(
      tbRestOrderItem,
      where: "orderId = ?",
      whereArgs: [orderId],
    );
    return queryResult.map((e) => RestOrderItem.fromJson(e)).toList();
  }

  // Delete rest order item from order
  Future<void> deleteRestOrderItemViaOrderId(int orderId) async {
    final db = await initializeDB();
    await db.delete(
      tbRestOrderItem,
      where: "orderId = ?",
      whereArgs: [orderId],
    );
  }

  // Delete rest order item
  Future<void> deleteRestOrderItem(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestOrderItem,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest compliment item
  ///
  // Insert compliment item
  Future<int> insertComplimentItem(List<ComplimentItem> cis) async {
    int result = 0;
    final db = await initializeDB();
    for (var ci in cis) {
      result = await db.insert(tbRestComplimentItem, ci.toJson());
    }
    return result;
  }

  // Retrieve cutomization item
  Future<List<ComplimentItem>> retireveComplimentItem() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestComplimentItem);
    return queryResult.map((e) => ComplimentItem.fromJson(e)).toList();
  }

  // Retrieve customizations items from order id
  Future<List<ComplimentItem>> retireveComplimentItemFromOrderId(
      int orderId) async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(
      tbRestComplimentItem,
      where: "orderId = ?",
      whereArgs: [orderId],
    );
    return queryResult.map((e) => ComplimentItem.fromJson(e)).toList();
  }

  // Delete cutomization item
  Future<void> deleteComplimentItem(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestComplimentItem,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Delete cutomization item order
  Future<void> deleteComplimentItemViaOrderId(int orderId) async {
    final db = await initializeDB();
    await db.delete(
      tbRestComplimentItem,
      where: "orderId = ?",
      whereArgs: [orderId],
    );
  }

  ///
  /// Rest Cart
  ///
  // Insert cart
  Future<int> insertRestCart(List<Cart> carts) async {
    int result = 0;
    final db = await initializeDB();
    for (var cart in carts) {
      result = await db.insert(tbRestCart, cart.toJson());
    }
    return result;
  }

  // Retrieve cart
  Future<List<Cart>> retireveRestCart() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(tbRestCart);
    return queryResult.map((e) => Cart.fromJson(e)).toList();
  }

  // Delete cart
  Future<void> deleteRestCart(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestCart,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest response
  ///
  // Insert rest response
  Future<int> insertRestResponse(List<Responses> responses) async {
    int result = 0;
    final db = await initializeDB();
    for (var res in responses) {
      result = await db.insert(tbRestResponse, res.toJson());
    }
    return result;
  }

  // Retrieve rest response
  Future<List<Responses>> retireveRestResponse() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestResponse);
    return queryResult.map((e) => Responses.fromJson(e)).toList();
  }

  // Delete rest response
  Future<void> deleteRestResponse(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestResponse,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Keep item
  ///
  // Insert item
  Future<int> insertKeepItem(List<KeepItem> items) async {
    int result = 0;
    final db = await initializeDB();
    for (var item in items) {
      result = await db.insert(tbKeepItem, item.toJson());
    }
    return result;
  }

  // Retrieve item
  Future<List<KeepItem>> retireveKeepItems() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(tbKeepItem);
    return queryResult.map((e) => KeepItem.fromJson(e)).toList();
  }

  // Delete item
  Future<void> deleteKeepItem(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbKeepItem,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  ///
  /// Rest Payment
  ///
  // Insert order payment
  Future<int> insertRestOrderPayment(List<RestOrderPayment> rops) async {
    int result = 0;
    final db = await initializeDB();
    for (var rop in rops) {
      result = await db.insert(tbRestPayment, rop.toJson());
    }
    return result;
  }

  // Retrieve order payment
  Future<List<RestOrderPayment>> retireveOrderPayments() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbRestPayment);
    return queryResult.map((e) => RestOrderPayment.fromJson(e)).toList();
  }

  // Delete order payment
  Future<void> deleteOrderPayment(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbRestPayment,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  //Adicionado codepaeza 20/05/2023

  ///
  /// Petty Amounts table
  ///
// Insert totals in petty amounts
  /* Future<int> insertPettyAmounts(List<PettyCashModel> totals) async {
    int result = 0;
    final db = await initializeDB();
    for (var total in totals) {
      result = await db.insert(tbPettyCash, total.toJson(), conflictAlgorithm:ConflictAlgorithm.replace);
    }
   return result;
  }*/
  Future<int> insertPettyAmounts(PettyCashModel petty) async {
    final db = await initializeDB();
    int id = await db.insert(
      tbPettyCash,
      petty.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

// Retrieve rest table data
  Future<List<PettyCashModel>> retirevePettyAmounts() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult = await db.query(tbPettyCash);
    //return queryResult.map((e) => PettyCashModel.fromJson(e)).toList();
    return List.generate(queryResult.length, (index) {
      return PettyCashModel(
        queryResult[index]['id'],
        queryResult[index]['name'],
        queryResult[index]['valueEn'],
        queryResult[index]['valueCo'],
        queryResult[index]['quantity'],
      );
    });
  }

// Delete rest table data
  //Future<void> deletePettyAmounts(int id) async {
  Future<void> deletePettyAmounts(PettyCashModel petty) async {
    final db = await initializeDB();
    await db.delete(
      tbPettyCash,
      where: "id = ?",
      whereArgs: [petty.id],
    );
  }

// Update rest table
  //Future<void> updatePettyAmounts(Map<String, Object> values, int id) async {
  Future<void> updatePettyAmounts(PettyCashModel pettypdt) async {
    final db = await initializeDB();
    await db.update(
      tbPettyCash,
      //values,
      pettypdt.toMap(),
      where: "id = ?",
      whereArgs: [pettypdt.id],
    );
  }

  ///
  /// Petty Close Amounts table
  ///
// Insert totals in petty amounts
  Future<int> insertPettyCloseAmounts(PettyCashCloseModel pettyClose) async {
    final db = await initializeDB();
    int id = await db.insert(
      tbPettyCloseCash,
      pettyClose.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

// Retrieve rest table data
  Future<List<PettyCashCloseModel>> retirevePettyCloseAmounts() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbPettyCloseCash);
    //return queryResult.map((e) => PettyCashModel.fromJson(e)).toList();
    return List.generate(queryResult.length, (index) {
      return PettyCashCloseModel(
        queryResult[index]['id'],
        queryResult[index]['nameClose'],
        queryResult[index]['valueEnClose'],
        queryResult[index]['valueCoClose'],
        queryResult[index]['quantityClose'],
      );
    });
  }

// Delete rest table data
  Future<void> deletePettyCloseAmounts(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbPettyCloseCash,
      where: "id = ?",
      whereArgs: [id],
    );
  }

// Update rest table
  Future<void> updatePettyCloseAmounts(
      Map<String, Object> values, int id) async {
    final db = await initializeDB();
    await db.update(
      tbPettyCloseCash,
      values,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  /// Insert cart
  Future<bool> insertCart(Cart cart) async {
    try {
      var itemMap = cart.cart?.map((e) => e.toJson()).toList();
      var jsonString = jsonEncode(itemMap);
      print('====== $jsonString ======');
      final db = await initializeDB();
      await db.execute(
          "INSERT INTO $tbCart(user_id, res_id, cart, food_tax, drink_tax, convenience_fee, sub_total, tax, total, created_at, table_id) VALUES(${cart.userId}, ${cart.resId}, '$jsonString', ${cart.foodTax}, ${cart.drinkTax}, ${cart.convienienceFee}, ${cart.subtotal}, ${cart.tax}, ${cart.total}, ${cart.createdAt}, ${cart.tableId})");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Retrieve carts all
  Future<Cart?> retireveCart(int cartId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db
          .query(tbCart, where: 'id = ? and ordered = 0', whereArgs: [cartId]);
      if (queryResult.isEmpty) return null;
      return queryResult.map((e) => Cart.fromJson(e)).toList().first;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get carts by ordered
  Future<List<Cart>> getCartsByOrdered() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbCart, where: 'ordered = 1');
    if (queryResult.isEmpty) return [];
    return queryResult.map((e) => Cart.fromJson(e)).toList();
  }

  /// Retrieve carts all
  Future<List<Cart>> retireveCarts() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> queryResult =
        await db.query(tbCart, where: 'ordered = 0');
    return queryResult.map((e) => Cart.fromJson(e)).toList();
  }

  /// Retrieve carts all
  Future<List<Cart>> retireveCartsFromUserRest(int userId, int resId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbCart,
        where: "user_id = ? and res_id = ?",
        whereArgs: [userId, resId],
      );
      return queryResult.map((e) => Cart.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Delete rest table data
  Future<void> deleteCart(int id) async {
    final db = await initializeDB();
    await db.delete(
      tbCart,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Delete rest table data
  Future<int> clearCarts() async {
    try {
      final db = await initializeDB();
      var rows = await db.delete(
        tbCart,
      );
      return rows;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  // Update cart
  Future<bool> updateCart(Map<String, Object?> values, int id) async {
    try {
      final db = await initializeDB();
      await db.update(
        tbCart,
        values,
        where: "id = ?",
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Insert User
  Future<bool> insertUser(User user) async {
    try {
      final db = await initializeDB();
      await db.execute(
          "INSERT INTO $tbUser(id, name, email, password, profileimage, role, restaurantId) VALUES(${user.id}, '${user.name}', '${user.email}', ${user.password}, '${user.profileimage}', '${user.role}', ${user.restaurantId})");

      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Retrieve User
  Future<List<User>> retrieveAllUsers() async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbUser,
      );
      return queryResult.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Retrieve User
  Future<User?> retrieveUser(int userId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbUser,
        where: 'id = ?',
        whereArgs: [userId],
      );
      return queryResult.map((e) => User.fromJson(e)).first;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Get current shift id
  Future<int> getCurrenShiftId(int restId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbCashierShifts,
        where: 'restaurant_id = ?',
        whereArgs: [restId],
      );
      if (queryResult.isEmpty) return 0;
      return queryResult.last['id'];
    } catch (e) {
      print(e);
      return -1;
    }
  }

  /// Get shift from id
  Future<Map<String, dynamic>?> getShift(int restId, int shiftId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbCashierShifts,
        where: 'restaurant_id = ? and id = ?',
        whereArgs: [restId, shiftId],
      );
      if (queryResult.isEmpty) return null;
      return queryResult.first;
    } catch (e) {
      print(e);
      return null;
    }
  }

  /// Check shift status
  Future<String> checkShiftStatus(int restId, int userId, int shiftId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbCashierShifts,
        where: 'restaurant_id = ? and id = ? and cashier_id = ?',
        whereArgs: [restId, shiftId, userId],
      );
      if (queryResult.isEmpty) return 'Empty';
      if (queryResult.last['drawer_cash_on_close'] != null) {
        return 'Closed';
      } else {
        return 'Opened';
      }
    } catch (e) {
      print(e);
      return 'Error';
    }
  }

  /// Insert shift
  Future<int> insertShift(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      int id = await db.insert(
        tbCashierShifts,
        map,
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Close shift
  Future<int> closeShift(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      var updateMap = {
        "close_date_time": map['close_date_time'],
        "drawer_cash_on_close": map['drawer_cash_on_close']
      };

      int id = await db.update(
        tbCashierShifts,
        updateMap,
        where: 'id = ?',
        whereArgs: [map['shift_id']],
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Insert shift
  Future<int> insertTax(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      int id = await db.insert(
        tbSetting,
        map,
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Get tax
  Future<List<Tax>> getTax() async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(
        tbSetting,
      );
      return queryResult.map((e) => Tax.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Insert restaurant
  Future<int> insertRestaurant(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      int id = await db.insert(
        tbRestaurant,
        map,
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Insert restaurant
  Future<List<Restaurant>> getRestaurant() async {
    try {
      final db = await initializeDB();

      var ret = await db.query(tbRestaurant, where: 'id = ?', whereArgs: [39]);
      return ret.map((e) => Restaurant.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Get cart from user_id
  Future<List<Map<String, Object?>>> GetCartFromUserId(int userId) async {
    try {
      final db = await initializeDB();
      var ret = await db.rawQuery(
        "SELECT r.min_order_value, r.max_order_value, r.ath_acc, r.cod, r.name, AS res_name, cart.user_id, cart.res_id, cart.food_tax, cart.drink_tax, cart.convenience_fee, cart.subtotal, cart.tax, cart.total, cart.cart, cart.id AS cart_id, cart.id, monopen_time text, monclose_time text, tueopen_time text, tueclose_time text, wedopen_time text, wedclose_time text, thuopen_time text, thuclose_time text, friopen_time text, friclose_time text, satopen_time text, satclose_time text, sunopen_time text, sunclose_time text, ordered integer, latitude text, longitude text FROM cart LEFT JOIN res_openclose_time AS roc ON roc.res_id = cart.res_id LEFT JOIN restaurant AS r ON r.id = cart.res_id WHERE user_id = ? and ordered = 0",
        [userId],
      );
      return ret;
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Insert restaurant open close time
  Future<int> insertResOpenCloseTime(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      int id = await db.insert(
        tbResOpenCloseTime,
        map,
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Get restaurant open close time
  Future<List<ResOpenCloseTime>> getResOpenCloseTime(int resId) async {
    try {
      final db = await initializeDB();

      var ret = await db
          .query(tbResOpenCloseTime, where: 'res_id = ?', whereArgs: [resId]);
      return ret.map((e) => ResOpenCloseTime.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /// Insert restaurant open close time
  Future<int> insertOrder(Map<String, dynamic> map) async {
    try {
      final db = await initializeDB();

      int id = await db.insert(
        tbOrders,
        map,
      );
      return id;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  /// Get carts by ordered
  Future<List<Order>> getOrders(int shiftId, int resId) async {
    try {
      final db = await initializeDB();
      final List<Map<String, dynamic>> queryResult = await db.query(tbOrders,
          where: 'shift_id = ? and res_id = ?', whereArgs: [shiftId, resId]);
      if (queryResult.isEmpty) return [];
      return queryResult.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }
}
