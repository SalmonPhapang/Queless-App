import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:new_gradient_app_bar/new_gradient_app_bar.dart';
import 'package:page_transition/page_transition.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_app/model/NotificationDTO.dart' as dto;
import 'package:provider/provider.dart';
import '../menu/OrderCart.dart';
import '../menu/OrderTracking.dart';
import '../model/Order.dart';
import '../model/Transaction.dart';
import '../model/User.dart';
import '../service/NotificationService.dart';
import '../service/OrderService.dart';
import '../service/TransactionService.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({Key key,this.order,this.user}) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
  final Order order;
  final User user;
}

class _PaymentPageState extends State<PaymentPage> {
  OrderService orderService = new OrderService();
  TransactionService transactionService = new TransactionService();
  NotificationService notificationService = new NotificationService();
  ProgressDialog progressDialog;
  Transaction transaction = Transaction();
  String cardNumber = '';
  String expiryDate = '';
  int year;
  int month;
  String cardHolderName = '';
  String cvvCode = '';
  String orderKey;
  bool isCvvFocused = false;
  bool useBackgroundImage = false;
  String publicKey = dotenv.env['PUBLIC_KEY'];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final plugin = PaystackPlugin();

  @override
  void initState() {
    plugin.initialize(publicKey: publicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var cart = Provider.of<OrderCart>(context);
    final topAppBar = NewGradientAppBar(
      elevation: 0.1.sp,
      gradient: LinearGradient(colors: [Colors.cyan, Colors.indigo]),
      title: Text("Payment"),
    );
    progressDialog = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true, showLogs: false);
    progressDialog.style(
        message: 'Processing Payment...',
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
    void onCreditCardModelChange(CreditCardModel creditCardModel) {
      setState(() {
        cardNumber = creditCardModel.cardNumber;
        expiryDate = creditCardModel.expiryDate;
        cardHolderName = creditCardModel.cardHolderName;
        cvvCode = creditCardModel.cvvCode;
        isCvvFocused = creditCardModel.isCvvFocused;
      });
    }
    PaymentCard _getCardFromUI() {
      // Using just the must-required parameters.
      return PaymentCard(
        number: cardNumber,
        cvc: cvvCode,
        expiryMonth: month,
        expiryYear: year,
        name: cardHolderName,
      );
    }
    handleCheckout(BuildContext context) async {
      if (formKey.currentState.validate()) {
        progressDialog.show();
          if(orderKey == null || orderKey.isEmpty){
            orderKey = await orderService.save(this.widget.order);
          }
        if (orderKey != null && orderKey.isNotEmpty) {
          List<String> dateList = expiryDate.split("/");
          year = int.parse(dateList.last);
          month = int.parse(dateList.first);
          Charge charge = Charge()
            ..reference = widget.order.orderNumber
            ..amount = (widget.order.total * 100).toInt()
            ..email = widget.user.email
            ..currency = "ZAR"
            ..card = _getCardFromUI()
            ..putCustomField('Charged From', 'Mobile App');
          try {
            CheckoutResponse response =  await plugin.chargeCard(context,charge: charge);
            if(response.status){
              bool success =  await transactionService.verify(response.reference);
              if(success){
                transaction.orderKey = orderKey;
                transaction.status = response.status.toString();
                transaction.taxReference = response.reference;
                transaction.message = response.message;
                await transactionService.save(transaction);
                Order freshOrder = await orderService.fetchByKey(orderKey);
                dto.Notification notification = new dto.Notification();
                notification.userType = 'CLIENT';
                notification.title = "New Order";
                notification.message = "New order placed " + freshOrder.orderNumber;
                notification.userKey = this.widget.order.clientKey;
                 notificationService.send(notification);
                 notificationService.sendSms(orderKey);

                freshOrder.address = this.widget.order.address;
                cart.clearAll();
                progressDialog.hide();
                Navigator.pushAndRemoveUntil(context,
                  PageTransition(type: PageTransitionType.rightToLeft,
                      child: OrderTracker(order: freshOrder, willPop: false,)),
                      (route) => false,
                );
              }else{
                progressDialog.hide();
                showUnsuccessfulAlertDialog(context);
              }
            }else{
              progressDialog.hide();
              showUnsuccessfulAlertDialog(context);
            }
          } catch (e) {
            rethrow;
          }
        }
      } else {
        print('invalid!');
      }
    }

    return Scaffold(
      appBar: topAppBar,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            CreditCardWidget(
              cardBgColor: Colors.black,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: true,
              obscureCardCvv: true,
              isHolderNameVisible: true,
              isSwipeGestureEnabled: true,
              animationDuration: Duration(milliseconds: 1000),
              onCreditCardWidgetChange: (CreditCardBrand) {},
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CreditCardForm(
                      formKey: formKey,
                      onCreditCardModelChange: onCreditCardModelChange,
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      themeColor: Colors.blue,
                      textColor: Colors.black87,
                      cardHolderDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Holder Name',
                      ),
                      cardNumberDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Number',
                        hintText: 'XXXX XXXX XXXX XXXX',
                      ),
                      expiryDateDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expire Date',
                        hintText: 'XX/XX',
                      ),
                      cvvCodeDecoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                        hintText: 'XXX',
                      ),
                    ),
                    new InkWell(
                      onTap: () {
                        handleCheckout(context);
                      },
                      child: new Container(
                          height: 40.0.sp,
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          margin: EdgeInsets.all(10.0.sp),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0.sp)),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.cyan,
                                    Colors.indigo,
                                  ])),
                          child: Center(
                            child: new Text(
                              'Pay R'+widget.order.total.toString(),
                              softWrap: true,
                              style: new TextStyle(
                                fontSize: 13.0.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )),
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
  showUnsuccessfulAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Unsuccessful",style: TextStyle(fontSize: 14.0.sp,color: Colors.black87),),
      content:Text("Oohps! Payment Unsuccessful or Cancelled",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,),
      actions: [
        TextButton(
          child: Text("Ok"),
          onPressed:  () {
            Navigator.pop(context);
          },
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
