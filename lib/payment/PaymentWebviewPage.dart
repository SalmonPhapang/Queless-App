import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_app/menu/OrderTracking.dart';
import 'package:flutter_app/model/Order.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_app/model/NotificationDTO.dart' as dto;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../menu/OrderCart.dart';
import '../model/User.dart';
import '../service/NotificationService.dart';
import '../service/OrderService.dart';
class PaymentWebview extends StatefulWidget {
  const PaymentWebview({Key key,this.order,this.user}) : super(key: key);

  @override
  State<PaymentWebview> createState() => _PaymentWebviewState();
  final Order order;
  final User user;
}

class _PaymentWebviewState extends State<PaymentWebview> {
  InAppWebViewController webViewController;
  String redirectUrl = "http://queless.app";
  String transactionID;
  String status;
  String taxReference;
  OrderService orderService = new OrderService();
  NotificationService notificationService = new NotificationService();
  ProgressDialog progressDialog;

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<OrderCart>(context);
    String taxReference = this.widget.order.orderNumber;
    String amount = this.widget.order.total.toString();
    String name = this.widget.user.name;
    String email = this.widget.user.email;
    String publicKey = dotenv.env['PUBLIC_KEY'];

    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Payment Successful, Submitting Order',
        borderRadius: 10.0.sp,
        backgroundColor: Colors.white,
        progressWidget: SpinKitCubeGrid(
          color: Color(0xffff5722),
          size: 25.0.sp,
        ),
        elevation: 10.0.sp,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 11.0.sp,
            fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18.0.sp,
            fontWeight: FontWeight.w600));

    paymentSuccessful() async {
      progressDialog.show();
      String orderKey = await orderService.save(this.widget.order);
      if (orderKey != null && orderKey.isNotEmpty) {
        Order freshOrder = await orderService.fetchByKey(orderKey);
        dto.Notification notification = new dto.Notification();
        notification.userType = 'CLIENT';
        notification.title = "New Order";
        notification.message = "New order placed " + freshOrder.orderNumber;
        notification.userKey = this.widget.order.clientKey;
        await notificationService.send(notification);

        freshOrder.address = this.widget.order.address;
        cart.clearAll();
        progressDialog.hide();
        Navigator.pushAndRemoveUntil(
          context,
          PageTransition(type: PageTransitionType.rightToLeft,
              child: OrderTracker(order: freshOrder, willPop: false,)),
              (route) => false,
        );
      }
    }
    return Scaffold(
      body:   Container(
        width:MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: InAppWebView(
          initialUrlRequest: URLRequest(
              url: Uri.parse("https://checkout.flutterwave.com/v3/hosted/pay"),
              method: 'POST',
              body: Uint8List.fromList(utf8.encode("public_key=$publicKey&tx_ref=$taxReference&amount=$amount&currency=ZAR&customer[name]=$name&customer[email]=$email&meta[token]=54&redirect_url=$redirectUrl")),
              headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
              }
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            if(url.toString().contains(redirectUrl)) {
              this.status = url.queryParameters['status'];
              if (status.contains("successful")) {
                this.transactionID = url.queryParameters['transaction_id'];
                this.taxReference = url.queryParameters['tx_ref'];
                paymentSuccessful();
              } else {
                Navigator.pop(context);
                showCancelledAlertDialog(context);
              }
            }
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          onLoadError: (controller, url, code, message) {

          },

        ),
      )
    );
  }
  showCancelledAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            20.0.sp,
          ),
        ),
      ),
      contentPadding: EdgeInsets.only(
        top: 20.0.sp,
      ),
      title: Text("Cancelled",style: TextStyle(fontSize: 14.0.sp,color: Colors.black87),),
      content:Text("Oohps! Payment cancelled by user",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
        actions: [
        TextButton(
          child: Text("Ok"),
          onPressed:  () {},
        ),
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
class Constants{
  Constants._();
  static const double padding =20;
  static const double avatarRadius =45;
}
