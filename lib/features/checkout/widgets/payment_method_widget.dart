import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/models/config_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/features/splash/providers/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/common/widgets/custom_image_widget.dart';
import 'package:provider/provider.dart';

class PaymentMethodWidget extends StatelessWidget {
  final Function(PaymentMethod method) onTap;
  final List<PaymentMethod> paymentList;
  const PaymentMethodWidget({
    super.key, required this.onTap, required this.paymentList,
  });

  @override
  Widget build(BuildContext context) {
    final OrderProvider orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);



    final List<PaymentMethod> finalPaymentList = [];
    PaymentMethod? razorpayMethod;
    for(var method in paymentList) {
      if(method.getWay!.toLowerCase().contains('razor') || method.getWay!.toLowerCase().contains('rezo')) {
        razorpayMethod = method;
      } else {
        finalPaymentList.add(method);
      }
    }

    if(razorpayMethod != null) {
      finalPaymentList.insert(0, PaymentMethod(getWayTitle: 'UPI Pay', getWayImage: Images.upi, getWay: razorpayMethod.getWay, type: razorpayMethod.type));
      finalPaymentList.insert(1, PaymentMethod(getWayTitle: 'Credit Card', getWayImage: Images.creditCard, getWay: razorpayMethod.getWay, type: razorpayMethod.type));
      finalPaymentList.insert(2, PaymentMethod(getWayTitle: 'Net Banking', getWayImage: Images.netBank, getWay: razorpayMethod.getWay, type: razorpayMethod.type));
      finalPaymentList.insert(3, PaymentMethod(getWayTitle: 'PhonePe', getWayImage: Images.phonepe, getWay: razorpayMethod.getWay, type: razorpayMethod.type));
      finalPaymentList.insert(4, PaymentMethod(getWayTitle: 'Google Pay', getWayImage: Images.googlePay, getWay: razorpayMethod.getWay, type: razorpayMethod.type));
    }

    return SingleChildScrollView(child: ListView.builder(
      itemCount: finalPaymentList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index){
        bool isSelected = finalPaymentList[index].getWayTitle == orderProvider.paymentMethod?.getWayTitle;
        bool isOffline = finalPaymentList[index].type == 'offline';
        return InkWell(
          onTap: ()=> onTap(finalPaymentList[index]),
          child: Container(
            decoration: BoxDecoration(
                color: isSelected ? Colors.blue.withValues(alpha: 0.05) : Colors.transparent,
                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault)
            ),
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                      border: Border.all(color: Theme.of(context).disabledColor)
                  ),
                  child: Icon(Icons.check, color: Theme.of(context).cardColor, size: 16),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                isOffline || (finalPaymentList[index].getWayImage?.contains('assets') ?? false) ? Image.asset(
                  finalPaymentList[index].getWayImage!,  height: 30, width: 40, fit: BoxFit.contain,
                ) : CustomImageWidget(
                  height: 30, width: 40, fit: BoxFit.contain,
                  image: '${splashProvider.configModel?.baseUrls?.getWayImageUrl}/${finalPaymentList[index].getWayImage}',
                ),


                const SizedBox(width: Dimensions.paddingSizeSmall),

                Text(
                  isOffline ? getTranslated('pay_offline', context) : finalPaymentList[index].getWayTitle ?? '',
                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                ),
              ]),

              if(isOffline && isSelected && splashProvider.offlinePaymentModelList != null) SingleChildScrollView(
                padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraLarge),
                scrollDirection: Axis.horizontal,
                child: Row(mainAxisAlignment: MainAxisAlignment.start, children: splashProvider.offlinePaymentModelList!.map((offlineMethod) => InkWell(
                  onTap: () {
                    orderProvider.changePaymentMethod(offlinePaymentModel: offlineMethod);
                    orderProvider.setOfflineSelectedValue(null);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeExtraLarge),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(width: 2, color: Theme.of(context).primaryColor.withValues(alpha: 
                        orderProvider.selectedOfflineMethod?.id == offlineMethod?.id ? 0.9 : 0.1,
                      )),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                    ),
                    child: Text(offlineMethod?.methodName ?? ''),
                  ),
                )).toList()),
              ),

              if(isOffline && orderProvider.selectedOfflineValue != null && isSelected ) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: Dimensions.paddingSizeDefault),

                Text(getTranslated('payment_info', context), style: poppinsMedium,),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                Column(children: orderProvider.selectedOfflineValue!.map((method) => Row(children: [
                  Text(method.keys.single, style: poppinsRegular),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Text(' :  ${method.values.single}', style: poppinsRegular),
                ])).toList()),

              ]),


            ]),
          ),
        );
      },));
  }
}
