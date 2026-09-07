import 'package:flutter/material.dart';
import 'package:flutter_grocery/features/order/providers/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class DeliveryOptionWidget extends StatelessWidget {
  final String value;
  final String? title;
  const DeliveryOptionWidget({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {

    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return RadioGroup<String>(
          groupValue: order.orderType,
          onChanged: (value) {
            if (value != null) {
              order.setOrderType(value);
            }
          },
          child: InkWell(
            onTap: () => order.setOrderType(value),
            child: Row(children: [
              Radio<String>(value: value),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(title!, style: order.orderType == value
                  ? poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall)
                  : poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            ]),
          ),
        );
      },
    );
  }
}
