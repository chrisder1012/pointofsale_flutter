import 'dart:io';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter/material.dart';

import '../utils/snacbar.dart';
// import '../utils/toast.dart';

class AppService {
  Future<bool?> checkInternet() async {
    bool? internet;
    try {
      final result = await InternetAddress.lookup('bing.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        internet = true;
      }
    } on SocketException catch (_) {
      internet = false;
    }
    return internet;
  }

  Future openLink(context, String url) async {
    if (await canLaunchUrlString(url)) {
      launchUrlString(url);
    } else {
      openSnacbar(context, "Can't launch the url");
    }
  }

  Future openEmailSupport() async {
    // await urlLauncher.launch(
    //     'mailto:${Config().supportEmail}?subject=About ${Config().appName} App&body=');
  }

  Future openLinkWithCustomTab(BuildContext context, String url) async {
    // try {
    //   await FlutterWebBrowser.openWebPage(
    //     url: url,
    //     customTabsOptions: CustomTabsOptions(
    //       colorScheme: context.read<ThemeBloc>().darkTheme!
    //           ? CustomTabsColorScheme.dark
    //           : CustomTabsColorScheme.light,
    //       addDefaultShareMenuItem: true,
    //       instantAppsEnabled: true,
    //       showTitle: true,
    //       urlBarHidingEnabled: true,
    //     ),
    //     safariVCOptions: SafariViewControllerOptions(
    //       barCollapsingEnabled: true,
    //       dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    //       modalPresentationCapturesStatusBarAppearance: true,
    //     ),
    //   );
    // } catch (e) {
    //   openToast1(context, 'Cant launch the url');
    //   debugPrint(e.toString());
    // }
  }

  Future launchAppReview(context) async {
    // final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    // await LaunchReview.launch(
    //     androidAppId: sb.packageName,
    //     iOSAppId: Config().iOSAppId,
    //     writeReview: false);
    // if (Platform.isIOS) {
    //   if (Config().iOSAppId == '000000') {
    //     openToast1(
    //         context, 'The iOS version is not available on the AppStore yet');
    //   }
    // }
  }

  static getYoutubeVideoIdFromUrl(String videoUrl) {
    // return YoutubePlayer.convertUrlToId(videoUrl, trimWhitespaces: true);
  }
}
