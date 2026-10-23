import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/features/checkout/controllers/checkout_controller.dart';
import 'package:sixam_mart/features/checkout/domain/models/place_order_body_model.dart';
import 'package:sixam_mart/features/parcel/controllers/parcel_controller.dart';
import 'package:sixam_mart/features/payment/controllers/payment_controller.dart';
import 'package:sixam_mart/helper/price_converter.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/helper/route_helper.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/common/widgets/custom_app_bar.dart';
import 'package:sixam_mart/common/widgets/custom_button.dart';
import 'package:sixam_mart/common/widgets/custom_snackbar.dart';
import 'package:sixam_mart/common/widgets/custom_text_field.dart';
import 'package:sixam_mart/common/widgets/footer_view.dart';
import 'package:sixam_mart/features/splash/controllers/splash_controller.dart';
import 'package:sixam_mart/common/widgets/custom_image.dart';
import 'package:sixam_mart/util/app_constants.dart';

import 'package:image_picker/image_picker.dart';

class QrCodePaymentScreen extends StatefulWidget {
  final PlaceOrderBodyModel placeOrderBody;
  final int zoneId;
  final double total;
  final double? maxCodOrderAmount;
  final bool fromCart;
  final bool isCashOnDeliveryActive;
  final bool forParcel;

  const QrCodePaymentScreen({super.key, required this.placeOrderBody, required this.zoneId,
    required this.total, required this.maxCodOrderAmount, required this.fromCart, required this.isCashOnDeliveryActive, required this.forParcel});

  @override
  State<QrCodePaymentScreen> createState() => _QrCodePaymentScreenState();
}

class _QrCodePaymentScreenState extends State<QrCodePaymentScreen> {
  final TextEditingController _transactionIdController = TextEditingController();
  final FocusNode _transactionIdNode = FocusNode();
  XFile? _qrPaymentProof;

  @override
  Widget build(BuildContext context) {
    String qrCodeImage = Get.find<SplashController>().configModel!.qrCodePaymentImage ?? '';
    String qrCodeUpi = Get.find<SplashController>().configModel!.qrCodePaymentUpi ?? '';
    String imgUrl = '${AppConstants.baseUrl}/storage/app/public/business/$qrCodeImage';

    return Scaffold(
      appBar: CustomAppBar(title: 'QR Code Payment'),
      body: SafeArea(
        child: GetBuilder<PaymentController>(
          builder: (paymentController) {
            return Column(children: [
              Expanded(child: SingleChildScrollView(
                child: FooterView(
                  child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      CustomImage(
                        image: imgUrl,
                        height: 200,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      
                      Text('UPI ID: $qrCodeUpi', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      Text('Please scan the QR code to pay.', textAlign: TextAlign.center, style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodySmall?.color,
                      )),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Text(
                        'Amount: ${PriceConverter.convertPrice(widget.total)}',
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment Info',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          CustomTextField(
                            titleText: 'Transaction ID',
                            labelText: 'Transaction ID',
                            controller: _transactionIdController,
                            focusNode: _transactionIdNode,
                            inputAction: TextInputAction.done,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment Proof',
                              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          InkWell(
                            onTap: () async {
                              XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                              if(xFile != null) {
                                setState(() {
                                  _qrPaymentProof = xFile;
                                });
                              }
                            },
                            child: Container(
                              height: 100, width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 1, style: BorderStyle.solid),
                              ),
                              child: _qrPaymentProof != null ? Center(
                                child: Text('Image Selected', style: robotoMedium.copyWith(color: Theme.of(context).primaryColor)),
                              ) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Icon(Icons.cloud_upload, size: 40, color: Theme.of(context).disabledColor),
                                const SizedBox(height: Dimensions.paddingSizeSmall),
                                Text('Upload Image', style: robotoMedium.copyWith(color: Theme.of(context).disabledColor)),
                              ]),
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                        ]),
                      ),
                      ResponsiveHelper.isDesktop(context) ? completeButton(paymentController) : const SizedBox(),
                    ]),
                  ),
                ),
              )),
              !ResponsiveHelper.isDesktop(context) ? completeButton(paymentController) : const SizedBox(),
            ]);
          }
        ),
      ),
    );
  }

  Widget completeButton(PaymentController paymentController) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
      child: CustomButton(
        buttonText: 'Submit Payment'.tr,
        isLoading: paymentController.isLoading,
        width: ResponsiveHelper.isDesktop(context) ? 300 : 500,
        onPressed: () async {
          if(_transactionIdController.text.isEmpty && _qrPaymentProof == null) {
            showCustomSnackBar('Please enter transaction ID or upload Payment Proof');
            return;
          }
          paymentController.changeLoadingStatus(true);
          String? orderId = '';
          
          if (widget.placeOrderBody != null && _transactionIdController.text.isNotEmpty) {
            widget.placeOrderBody.setOrderNote('${widget.placeOrderBody.orderNote ?? ''} | QR Transaction ID: ${_transactionIdController.text}');
          }

          if(widget.forParcel) {
            orderId = await Get.find<ParcelController>().placeOrder(
                widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart,
                widget.isCashOnDeliveryActive, isOfflinePay: false, forParcel: widget.forParcel);
          } else {
            orderId = await Get.find<CheckoutController>().placeOrder(
                widget.placeOrderBody, widget.zoneId, widget.total, widget.maxCodOrderAmount, widget.fromCart,
                widget.isCashOnDeliveryActive, Get.find<CheckoutController>().pickedPrescriptions, isOfflinePay: false, qrPaymentProof: _qrPaymentProof);
          }
          paymentController.changeLoadingStatus(false);
          if(orderId.isNotEmpty) {
             Get.offAllNamed(RouteHelper.getOrderDetailsRoute(int.parse(orderId), fromOffline: false, contactNumber: widget.placeOrderBody.contactPersonNumber, fromCheckout: true));
          }
        },
      ),
    );
  }
}
