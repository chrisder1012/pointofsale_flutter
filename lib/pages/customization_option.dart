import 'package:flutter/material.dart';
import 'package:zabor/models/customization.dart';
import 'package:zabor/utils/t1_string.dart';
import 'package:easy_localization/easy_localization.dart';

import '../config/config.dart';
import '../models/customization_item.dart';
import '../utils/utils.dart';

class CustomizationOptionPage extends StatefulWidget {
  const CustomizationOptionPage({Key? key, required this.customizations})
      : super(key: key);
  final List<Customization> customizations;

  @override
  State<CustomizationOptionPage> createState() =>
      _CustomizationOptionPageState();
}

class _CustomizationOptionPageState extends State<CustomizationOptionPage> {
  List<CustomizationItem> selectedCustomizationItem = [];
  // bool isPortrait = false;
  double _width = 0.0;
  double _height = 0.0;
  List<int> complements_group_selected = [];
  List<int> complements_groups = [];
  // double scaleWidth = 0.0;
  // double scaleHeight = 0.0;

  int _complimentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTotalGroups();
  }

  getTotalGroups() {
    int i = 0;
    widget.customizations.forEach((element) {
      complements_groups.add(i);
      i++;
    });
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait) {
      scaleWidth = _width / Config().defaultWidth;
      scaleHeight = _height / Config().defaultHeight;
    } else {
      scaleWidth = _width / Config().defaultHeight;
      scaleHeight = _height / Config().defaultWidth;
    }

    return Scaffold(
      appBar: _appbar(),
      body: _body2(),
    );
  }

  _appbar() {
    return AppBar(
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context, null);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          )),
      backgroundColor: Config().appColor,
      title: /*const*/ Text(
        t1Compliments.tr(),
      ),
    );
  }

  _body2() {
    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          _header(),
          _content(),
          SizedBox(
            height: setScaleHeight(isPortrait ? 40 : 50),
            width: _width,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(
                    context,
                    selectedCustomizationItem.isEmpty
                        ? null
                        : selectedCustomizationItem);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.orange[400]),
              child: Text(
                t1Done.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: setFontSize(isPortrait ? 16 : 22),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _header() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const ScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isPortrait ? 3 : 6,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
        childAspectRatio: 3,
      ),
      itemCount: widget.customizations.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _complimentIndex = index;
            });
          },
          child: Container(
            // height: _setScaleHeight(60),
            width: isPortrait ? setScaleWidth(40) : setScaleWidth(60),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _complimentIndex == index
                    ? Colors.orange[400]!
                    : Colors.white,
                width: 2,
              ),
            ),
            margin: const EdgeInsets.all(0.5),
            child: Center(
              child: Text(
                "${widget.customizations[index].name!} ( Max: ${widget.customizations[index].max.toString() == 'null' ? widget.customizations[index].items!.length.toString() : widget.customizations[index].max.toString()} )",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isPortrait ? setFontSize(10) : setFontSize(14),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  _content() {
    print("_complimentIndex: $_complimentIndex");
    return Expanded(
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Wrap(
              children: List<Widget>.generate(
                widget.customizations[_complimentIndex].items!.length,
                (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ChoiceChip(
                      backgroundColor: Colors.orange[400],
                      selectedColor: Colors.black87,
                      padding: const EdgeInsets.all(16),
                      labelStyle: const TextStyle(color: Colors.white),
                      label: Text(
                          "${widget.customizations[_complimentIndex].items![index].optionName} (${'\$${widget.customizations[_complimentIndex].items![index].optionPrice}'})",
                          style: TextStyle(fontSize: isPortrait ? 18 : 22)),
                      selected: selectedCustomizationItem.contains(widget
                          .customizations[_complimentIndex].items![index]),
                      onSelected: (bool selected) {
                        setState(() {
                          int tempMax = 0;
                          for (int count = 0;
                              count <
                                  widget.customizations[_complimentIndex].items!
                                      .length;
                              count++) {
                            if (selectedCustomizationItem.contains(widget
                                .customizations[_complimentIndex]
                                .items![count])) {
                              tempMax++;
                            }
                          }

                          bool alreadySelected =
                              selectedCustomizationItem.contains(widget
                                  .customizations[_complimentIndex]
                                  .items![index]);
                          if (alreadySelected) {
                            tempMax = tempMax - 1;
                          } else {
                            tempMax = tempMax;
                          }
                          if (widget.customizations[_complimentIndex].max
                                  .toString() ==
                              'null') {
                            addRemoveItem(widget
                                .customizations[_complimentIndex]
                                .items![index]);
                          } else if (tempMax >=
                              widget.customizations[_complimentIndex].max!) {
                            if (!complements_group_selected
                                .contains(_complimentIndex)) {
                              complements_group_selected.add(_complimentIndex);
                            }

                            getNextGroupId();
                          } else {
                            complements_group_selected.remove(_complimentIndex);

                            // Check if max is reached and we can't select more items from current group
                            // if(tempMax + 1 == widget.customizations[_complimentIndex].max){
                            //   // if(!complements_group_selected.contains(_complimentIndex)){
                            //   //   complements_group_selected.add(_complimentIndex);
                            //   // }
                            //   getNextGroupId();
                            // }
                            // working
                            addRemoveItem(widget
                                .customizations[_complimentIndex]
                                .items![index]);

                            if (tempMax + 1 ==
                                widget.customizations[_complimentIndex].max) {
                              if (!complements_group_selected
                                  .contains(_complimentIndex)) {
                                complements_group_selected
                                    .add(_complimentIndex);
                              }
                              getNextGroupId();
                            }
                          }
                        });
                      },
                    ),
                  );
                },
              ).toList(),
            )
          ],
        ),
      ),
    );
  }

  getNextGroupId() {
    List<int> result = complements_groups
        .where((item) => !complements_group_selected.contains(item))
        .toList();
    if (result.isNotEmpty) {
      setState(() {
        _complimentIndex = result[0];
      });
    }
  }

  _body() {
    return SafeArea(
      child: Column(children: [
        Expanded(
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getHeaders())),
        ),
        SizedBox(
          height: setScaleHeight(isPortrait ? 50 : 60),
          width: _width,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(
                  context,
                  selectedCustomizationItem.isEmpty
                      ? null
                      : selectedCustomizationItem);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              t1Done.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: setFontSize(isPortrait ? 16 : 22),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> getHeaders() {
    List<Widget> widgets = [];
    for (int i = 0; i < widget.customizations.length; i++) {
      widgets.add(Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                "${widget.customizations[i].name!} ( Max: ${widget.customizations[i].max.toString() == 'null' ? widget.customizations[i].items!.length.toString() : widget.customizations[i].max.toString()} )",
                style: TextStyle(
                    fontSize: setFontSize(isPortrait ? 14 : 20),
                    fontWeight: FontWeight.bold)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                children: List<Widget>.generate(
                  widget.customizations[i].items!.length,
                  (int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ChoiceChip(
                        backgroundColor: Colors.red[300],
                        selectedColor: Colors.black87,
                        padding: const EdgeInsets.all(8),
                        labelStyle: const TextStyle(color: Colors.white),
                        label: Text(
                            "${widget.customizations[i].items![index].optionName} (${'\$${widget.customizations[i].items![index].optionPrice}'})",
                            style: TextStyle(fontSize: isPortrait ? 12 : 18)),
                        selected: selectedCustomizationItem
                            .contains(widget.customizations[i].items![index]),
                        onSelected: (bool selected) {
                          setState(() {
                            int tempMax = 0;
                            for (int count = 0;
                                count < widget.customizations[i].items!.length;
                                count++) {
                              if (selectedCustomizationItem.contains(
                                  widget.customizations[i].items![count])) {
                                tempMax++;
                              }
                            }

                            bool alreadySelected =
                                selectedCustomizationItem.contains(
                                    widget.customizations[i].items![index]);
                            if (alreadySelected) {
                              tempMax = tempMax - 1;
                            } else {
                              tempMax = tempMax;
                            }
                            if (widget.customizations[i].max.toString() ==
                                'null') {
                              addRemoveItem(
                                  widget.customizations[i].items![index]);
                            } else if (tempMax >=
                                widget.customizations[i].max!) {
                            } else {
                              addRemoveItem(
                                  widget.customizations[i].items![index]);
                            }
                          });
                        },
                      ),
                    );
                  },
                ).toList(),
              )
            ],
          )
        ],
      ));
    }
    return widgets;
  }

  List<Widget> getItems(int outerIndex) {
    List<Widget> widgets = [];
    for (int index = 0;
        index < widget.customizations[outerIndex].items!.length;
        index++) {
      widgets.add(ListTile(
          leading: Image.asset(
            selectedCustomizationItem
                    .contains(widget.customizations[outerIndex].items![index])
                ? 'assets/images/3.0x/check.png'
                : 'assets/images/3.0x/uncheck.png',
            height: 22,
          ),
          title:
              Text(widget.customizations[outerIndex].items![index].optionName!),
          trailing: Text(
              '\$${widget.customizations[outerIndex].items![index].optionPrice}'),
          onTap: () => {
                addRemoveItem(widget.customizations[outerIndex].items![index])
              }));
    }
    return widgets;
  }

  addRemoveItem(CustomizationItem customizationItem) {
    setState(() {
      if (selectedCustomizationItem.contains(customizationItem)) {
        selectedCustomizationItem
            .removeWhere((element) => element == customizationItem);
      } else {
        selectedCustomizationItem.add(customizationItem);
      }
    });
  }

  Row buildCloseButtonWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context, null);
          },
        ),
      ],
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    Key? key,
    this.title,
    this.onPressed,
  }) : super(key: key);

  final String? title;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: SizedBox(
        height: 120,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(
            title!,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 30),
          ),
        ),
      ),
    );
  }
}
