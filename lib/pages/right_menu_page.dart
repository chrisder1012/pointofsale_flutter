import 'package:flutter/material.dart';
import 'package:zabor/models/restaurant.dart';

import '../config/config.dart';
import '../models/customization.dart';
import '../models/customization_item.dart';
import '../models/group.dart';
import '../models/item.dart';
import '../models/menu_item.dart';
import '../utils/utils.dart';
import 'customization_option.dart';

class RightMenuPage extends StatefulWidget {
  RightMenuPage({
    Key? key,
    required this.groups,
    required this.menuItems,
    required this.isMenuLoaded,
    required this.mapItem,
    required this.customization,
    required this.responses,
    this.onItemSeleted,
  }) : super(key: key);

  final List<Group>? groups;
  final List<MItem>? menuItems;
  final bool? isMenuLoaded;
  final Map<MItem, int>? mapItem;
  final List<Customization>? customization;
  final Responses? responses;
  final Function(Item, Group)? onItemSeleted;

  @override
  State<RightMenuPage> createState() => _RightMenuPageState();
}

class _RightMenuPageState extends State<RightMenuPage> {
  var _categoryIndex = 0;
  // var scaleWidth = 0.0;
  // var scaleHeight = 0.0;
  // var isPortrait = false;

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait) {
      scaleWidth = width / Config().defaultWidth;
      scaleHeight = height / Config().defaultHeight;
    } else {
      scaleWidth = width / Config().defaultHeight;
      scaleHeight = height / Config().defaultWidth;
    }

    if (widget.groups!.isNotEmpty) {
      widget.menuItems!.clear();
      widget.menuItems!.addAll(widget.groups![_categoryIndex].items!);
    }

    return !widget.isMenuLoaded!
        ? const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            ),
          )
        : Container(
            color: Colors.grey[900],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isPortrait ? 3 : 6,
                    crossAxisSpacing: 1.0,
                    mainAxisSpacing: 1.0,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: widget.groups!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _categoryIndex = index;
                          // _isFirst = true;
                        });
                      },
                      child: Container(
                        // height: _setScaleHeight(60),
                        width:
                            isPortrait ? setScaleWidth(70) : setScaleWidth(100),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _categoryIndex == index
                                ? Colors.orangeAccent
                                : Colors.white,
                            width: _categoryIndex == index ? 3 : 2,
                          ),
                        ),
                        margin: const EdgeInsets.all(0.5),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            widget.groups![index].name!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize:
                                  isPortrait ? setFontSize(5) : setFontSize(12),
                              // ? setFontSize(10)
                              // : setFontSize(14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Divider(
                  color: Colors.black,
                  height: 2,
                ),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const ScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isPortrait ? 2 : 5,
                      crossAxisSpacing: 1.0,
                      mainAxisSpacing: 1.0,
                      childAspectRatio: 1,
                    ),
                    itemCount: widget.menuItems!.length,
                    itemBuilder: (context, idx) {
                      var count = widget.mapItem![widget.menuItems![idx]];
                      return GestureDetector(
                        onTap: () async {
                          print(widget.menuItems![idx].itemQuantity);

                          if (widget.menuItems![idx].itemQuantity == 0) {
                            // openSnacbar(context, t1ZeroStock);
                            return;
                          }
                          try {
                            if (widget.menuItems![idx].customizations !=
                                'null') {
                              var customizations = widget
                                  .menuItems![idx].customizations!
                                  .split(',');
                              List<Customization> newCusList = [];

                              for (var element in widget.customization!) {
                                if (customizations.isNotEmpty) {
                                  for (var idString in customizations) {
                                    if (int.tryParse(idString) ==
                                        element.cusid) {
                                      newCusList.add(element);
                                    }
                                  }
                                }
                              }
                              //}
                              // }
                              //catch (Exception) {
                              //List<Customization> newCusList = [1];
                              //}

                              List<CustomizationItem>? custItems;
                              if (newCusList.length > 0) {
                                custItems = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CustomizationOptionPage(
                                      customizations: newCusList,
                                    ),
                                    //fullscreenDialog: true,
                                    fullscreenDialog: false,
                                  ),
                                );
                              }
                              setState(() {
                                widget.mapItem![widget.menuItems![idx]] =
                                    count! + 1;
                                // _hasRecord = true;
                              });
                              _addCart(widget.menuItems![idx], custItems, '');
                            } else {
                              _addCart(widget.menuItems![idx], null, '');
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            // color: (count! > 0)
                            //     ? Colors.orange[100]
                            //     : Colors.white,
                          ),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: (widget.menuItems![idx].itemPic ==
                                                null ||
                                            widget.menuItems![idx].itemPic! ==
                                                'null')
                                        ? Container(
                                            margin: const EdgeInsets.all(4),
                                            child: Text(
                                              '${widget.menuItems![idx].itemDes!}\n',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: isPortrait
                                                    ? setFontSize(6)
                                                    : setFontSize(12),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            // margin: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                    Config().apiBaseUrl +
                                                        widget.menuItems![idx]
                                                            .itemPic!),
                                              ),
                                            ),
                                          ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 4),
                                      alignment: Alignment.bottomCenter,
                                      child: Text(
                                        '${widget.menuItems![idx].itemName!}\n',
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isPortrait
                                              ? setFontSize(6)
                                              : setFontSize(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 4, right: 4),
                                  child: CircleAvatar(
                                    radius: isPortrait ? 8 : 15,
                                    backgroundColor: Config().appColor,
                                    child: Text(
                                      '${widget.menuItems![idx].itemQuantity!}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: isPortrait
                                              ? setFontSize(4)
                                              : setFontSize(8),
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }

  // Add cart
  _addCart(MItem cartItem, List<CustomizationItem>? customItems, String note) {
    Item tempCartItem = Item();
    tempCartItem.itemId = cartItem.itemId;
    tempCartItem.itemName = cartItem.itemName;
    tempCartItem.itemPrice = cartItem.itemPrice;
    tempCartItem.customization = [];
    if (customItems != null) {
      tempCartItem.customization!.addAll(customItems);
    }
    tempCartItem.quantity = 1;
    tempCartItem.taxvalue = (cartItem.isCity!
            ? double.parse(widget.responses!.grandTax!)
            : 0.0) +
        (cartItem.isFood! ? double.parse(widget.responses!.foodTax!) : 0.0) +
        (cartItem.isState! ? double.parse(widget.responses!.drinkTax!) : 0.0);
    tempCartItem.taxtype = cartItem.taxtype;
    tempCartItem.isCity = cartItem.isCity;
    // tempCartItem.is_show = cartItem.isShow;
    tempCartItem.isFood = cartItem.isFood;
    tempCartItem.isState = cartItem.isState;
    // tempCartItem.is_note = cartItem.isNote;
    tempCartItem.print2 = cartItem.print2;
    tempCartItem.print3 = cartItem.print3;
    tempCartItem.print4 = cartItem.print4;
    tempCartItem.print5 = cartItem.print5;
    tempCartItem.note = '';
    widget.onItemSeleted!(tempCartItem, widget.groups![_categoryIndex]);
    // widget.orderingItems!.add(tempCartItem);
    // _selectedItems.add(tempCartItem);
  }
}
