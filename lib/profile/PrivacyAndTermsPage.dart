import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class TermsPrivacyPage extends StatefulWidget {
  TermsPrivacyPage({Key key, this.title,this.isTerms}) : super(key: key);

  final String title;
  final bool isTerms;

  @override
  _TermsPrivacyPageState createState() => _TermsPrivacyPageState();
}
class _TermsPrivacyPageState extends State<TermsPrivacyPage> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialUrlRequest: widget.isTerms ?  URLRequest(url: Uri.parse("https://queless.flycricket.io/terms.html")) :  URLRequest(url: Uri.parse("https://queless.flycricket.io/privacy.html")),
    );

  }
}