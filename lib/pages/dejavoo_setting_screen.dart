import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/blocs/dejavoo_terminal_bloc.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/utils/utils.dart';

import '../blocs/sign_in_bloc.dart';
import '../services/services.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';
import 'restaurant_type.dart';

class DejavooSettingScreen extends StatefulWidget {
  DejavooSettingScreen({Key? key, this.isFirst = true}) : super(key: key);
  final bool isFirst;

  @override
  State<DejavooSettingScreen> createState() => _DejavooSettingScreenState();
}

class _DejavooSettingScreenState extends State<DejavooSettingScreen> {
  final _deviceNameController = TextEditingController();
  final _deviceTPNController = TextEditingController();

  bool _isLoading = false;
  bool _isSkipped = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Dejavoo Link',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: width / 3,
                child: TextField(
                  controller: _deviceNameController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Device name",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: width / 3,
                child: TextField(
                  controller: _deviceTPNController,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "TPN",
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isSkipped,
                    onChanged: (value) {
                      setState(
                        () {
                          _isSkipped = value!;
                        },
                      );
                    },
                  ),
                  Text("Only use cash"),
                ],
              ),
              const SizedBox(height: 56),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: Size(width / 4, setScaleHeight(40)),
                      backgroundColor: Config().appColor),
                  onPressed: () {
                    FocusScope.of(context).requestFocus(FocusNode());

                    if (_isSkipped) {
                      gotoHomePage();
                    } else {
                      if (_deviceNameController.text.isNotEmpty &&
                          _deviceTPNController.text.isNotEmpty) {
                        _handleLinkDejavooDevice(_deviceNameController.text,
                            _deviceTPNController.text);
                      }
                    }
                  },
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Link",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  _handleLinkDejavooDevice(String deviceName, String tpn) async {
    final DejavooTerminalBloc dtb =
        Provider.of<DejavooTerminalBloc>(context, listen: false);

    await AppService().checkInternet().then((hasInternet) async {
      if (hasInternet == false) {
        openSnacbar(context, 'no internet');
      } else {
        setState(() {
          _isLoading = true;
        });
        dtb.linkDevice(deviceName, tpn, Config.restaurantId!).then((_) async {
          openSnacbar(context, dtb.message);

          _deviceNameController.clear();
          _deviceTPNController.clear();

          setState(() {
            _isLoading = false;
          });

          await Future.delayed(Duration(seconds: 1));

          var pref = await SharedPreferences.getInstance();

          if (!dtb.hasError) {
            pref.setBool("dejavoo", true);

            if (widget.isFirst) {
              gotoHomePage();
            } else {
              Navigator.pop(context);
            }
          } else {
            if (dtb.message == "TPN is already linked with a device") {
              pref.setBool("dejavoo", true);

              if (widget.isFirst) {
                gotoHomePage();
              } else {
                Navigator.pop(context);
              }
            }
          }
        });
      }
    });
  }

  gotoHomePage() {
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.isSignedIn == true) {
      sb.getDataFromSp();
      sb.getUserFromSp();
    }
    nextScreenReplace(context, const RestaurantTypePage());
  }
}
