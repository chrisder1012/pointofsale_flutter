import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'elevated_button_widget.dart';

class CloseAppDialog {
  static Future closeAppDialog({required BuildContext context}) async {
    return await showGeneralDialog<dynamic>(
      // barrierLabel: 'Label',
      // context: context,
      // barrierDismissible: false,
      // barrierColor: Colors.black.withOpacity(0.8),
      // transitionDuration: const Duration(milliseconds: 350),
      // pageBuilder: (context, anim1, anim2) {
      //   return AlertDialog(
      //     backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //     content: Text(
      //       t.MESSAGES.APP_CLOSE,
      //       style:
      //           Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 15),
      //     ),
      //     actions: [
      //       TextButton(
      //           onPressed: () => Navigator.pop(context),
      //           child: Text(
      //             t.BUTTON.CANCEL,
      //             style: Theme.of(context).textTheme.labelLarge,
      //           )),
      //       TextButton(
      //           onPressed: () {
      //             final _audioHandler = getIt<AudioPlayerHandler>();
      //             _audioHandler.stop().then((value) => exit(0));
      //           },
      //           child: Text(
      //             t.BUTTON.CONFIRM,
      //             style: Theme.of(context).textTheme.labelLarge,
      //           )),
      //     ],
      //   );
      // },
      // transitionBuilder: (context, anim1, anim2, child) {
      //   return Transform.scale(
      //     scale: anim1.value,
      //     child: child,
      //   );
      // },
      barrierLabel: 'Label',
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return AppcloseDialogWidget();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: child,
        );
      },
    );
  }
}

class AppcloseDialogWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final outstanding = const Color(0xff2066AD);
    return Dialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    color: Theme.of(context).colorScheme.onBackground,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          color: Colors.grey.withOpacity(.2),
                          offset: const Offset(0, 0))
                    ]),
                margin:
                    const EdgeInsets.symmetric(horizontal: 18.5, vertical: 26),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 20,
                          constraints: const BoxConstraints(
                              maxHeight: 35,
                              maxWidth: 35,
                              minHeight: 35,
                              minWidth: 35),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.clear)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 37, right: 37, bottom: 40),
                      child: Text(
                        "Are you you wants to go back ?",
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge!
                            .copyWith(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.5),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButtonWidget(
                          borderRadius: 100,
                          height: 46,
                          backgroundColor: const Color(0xffD9D9D9),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: outstanding, fontSize: 14),
                          ),
                          onPressed: () => Navigator.pop(context))),
                  const SizedBox(
                    width: 11,
                  ),
                  Expanded(
                    child: ElevatedButtonWidget(
                        backgroundColor: outstanding,
                        borderRadius: 100,
                        height: 46,
                        child: Text(
                          'Confirm',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(color: Colors.white, fontSize: 14),
                        ),
                        onPressed: () async {
                          Navigator.pop(context, true);
                        }),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 26,
            ),
          ],
        ),
      ),
    );
  }
}
