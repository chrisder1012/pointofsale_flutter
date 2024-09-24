import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zabor/config/config.dart';
import 'package:zabor/utils/utils.dart';

import '../db/database_handler.dart';
import '../models/user.dart';
import '../utils/next_screen.dart';
import 'sign_in2.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final _pageController = PageController();

  List<String> _images = [
    'onboarding-1.jpg',
    'onboarding-2.jpg',
    'onboarding-3.jpg'
  ];
  List<String> _texts = [
    "Every contact we have with a customer influences whether or not they'll come back. We have to be great every time or we'll lose them.",
    "If you do build a great experience, customers tell each other about that. Word of mouth is very powerful.",
    "Serve customers the best-tasting food at a good value in a clean, comfortable restaurant, and they'll keep coming back."
  ];

  List<User> _employeeList = [
    User(
      id: 110,
      email: 'rafaeltorress@gmail.com',
      name: 'Rafael Torres',
      password: '123456',
      profileimage: 'person1.jpeg',
      restaurantId: 39,
      role: 'owner',
      status: 1,
    ),
    // User(
    //   id: 002,
    //   email: 'ar.dev0927@gmail.com',
    //   name: 'Yan Li',
    //   password: '222222',
    //   profileimage: 'person1.jpeg',
    //   restaurantId: 39,
    //   role: 'employee',
    //   status: 1,
    // ),
  ];

  int _selectedIndex = 0;
  final DatabaseHandler _dbHandler = DatabaseHandler();

  @override
  void initState() {
    super.initState();

    // load users
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if (isPortrait) {
      scaleWidth = width / Config().defaultWidth;
      scaleHeight = height / Config().defaultHeight;
    } else {
      scaleWidth = width / Config().defaultHeight;
      scaleHeight = height / Config().defaultWidth;
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Image.asset(
                      'assets/images/${_images[index]}',
                      width: width,
                      height: height,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: height / 5),
                        child: Text(
                          _texts[index],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
              onPageChanged: (value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _pageIndicators(context),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          width: width / 4,
                          height: setScaleHeight(30),
                          child: _selectedIndex == 2
                              ? SizedBox()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    nextScreenReplace(context,
                                        const SignIn2Page(isFirst: true));
                                  },
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ),
                        SizedBox(
                          width: width / 4,
                          height: setScaleHeight(30),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Config().appColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (_selectedIndex != 2) {
                                _pageController.nextPage(
                                    duration: Duration(seconds: 1),
                                    curve: Curves.ease);
                              } else {
                                nextScreenReplace(
                                    context, const SignIn2Page(isFirst: true));
                              }
                            },
                            child: Text(
                              _selectedIndex == 2 ? 'Get Started' : 'Next',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pageIndicators(BuildContext context) {
    List<Container> _indicators = [];

    for (int i = 0; i < 3; i++) {
      _indicators.add(
        Container(
          width: i == _selectedIndex ? 15 * 3 : 15,
          height: 15,
          margin: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: i == _selectedIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
            borderRadius: i == _selectedIndex
                ? BorderRadius.circular(60)
                : BorderRadius.circular(30),
          ),
        ),
      );
    }
    return _indicators;
  }

  /// Load users from db
  _loadUsers() async {
    var users = await _dbHandler.retrieveAllUsers();
    if (users.isEmpty) {
      _addUsersToDB();
    }
  }

  // Add users to db
  _addUsersToDB() async {
    for (var emp in _employeeList) {
      await _dbHandler.insertUser(emp);
    }
  }
}
