import 'package:flutter/material.dart';
import 'package:flutter_grocery/common/widgets/custom_tooltip.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/common/providers/cart_provider.dart';
import 'package:flutter_grocery/helper/custom_snackbar_helper.dart';

import 'package:provider/provider.dart';

class QuantityButtonWidget extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int? stock;
  final int? maxOrderQuantity;
  final int? cartIndex;
  final ScrollController? scrollController;

  QuantityButtonWidget({super.key,
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.maxOrderQuantity,
    this.isCartWidget = false,
    required this.cartIndex,
    this.scrollController,
  });

  final GlobalKey<CustomTooltipState> tooltipKey = GlobalKey<CustomTooltipState>();

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return CustomTooltip(
      scrollController: scrollController,
      key: tooltipKey,
      title: getTranslated('warning', context),
      description: hasMaximumQuantityReached(cartProvider)
          ? '${getTranslated('you_cant_add_more_than', context)} $maxOrderQuantity '
          '${getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)}'
          : '${getTranslated('there_is_nt_enough_quantity_on_stock', context)} ${getTranslated('only', context)} $stock ${getTranslated('is_available', context)}',
      toolTipGap: hasMaximumQuantityReached(cartProvider) ? 15 : 25,
      leadingIcon: Icons.warning,
      iconColor: Colors.orange,
      placement: TooltipPlacement.top,
      tailPosition: TooltipTailPosition.start,
      backgroundColor: Colors.orange.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {

          if(cartIndex != null) {
            if(isIncrement) {
              if(maxOrderQuantity == null || cartProvider.updatedCartList[cartIndex!].quantity! < maxOrderQuantity!){
                if (cartProvider.updatedCartList[cartIndex!].quantity! < cartProvider.updatedCartList[cartIndex!].stock!) {
                  cartProvider.initialUpdateCartQuantity(true, cartIndex, showMessage: false, context: context);
                } else {
                  ResponsiveHelper.isDesktop(context)
                      ? tooltipKey.currentState?.showTooltip(context)
                      : showCustomSnackBarHelper('${getTranslated('there_is_nt_enough_quantity_on_stock', context)} ${getTranslated('only', context)} $stock ${getTranslated('is_available', context)}', snackBarStatus: SnackBarStatus.info);
                }
              }else{
                ResponsiveHelper.isDesktop(context)
                    ? tooltipKey.currentState?.showTooltip(context)
                    : showCustomSnackBarHelper('${getTranslated('you_cant_add_more_than', context)} $maxOrderQuantity '
                    '${getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)}', snackBarStatus: SnackBarStatus.info);
              }

            }else {
              if (cartProvider.updatedCartList[cartIndex!].quantity! > 1) {
                cartProvider.initialUpdateCartQuantity(false, cartIndex, showMessage: false, context: context);
              }
              // else {
              //   cartProvider.setExistData(null);
              //   cartProvider.removeItemFromCart(cartIndex!, context);
              // }
            }
          }else {
            if (!isIncrement && quantity > 1) {
              cartProvider.setQuantity(false);
            } else if (isIncrement) {
              if(maxOrderQuantity == null || quantity < maxOrderQuantity!) {
                if(quantity < stock!) {
                  cartProvider.setQuantity(true);
                }else {
                  ResponsiveHelper.isDesktop(context)
                      ? tooltipKey.currentState?.showTooltip(context)
                      : showCustomSnackBarHelper('${getTranslated('there_is_nt_enough_quantity_on_stock', context)} ${getTranslated('only', context)} $stock ${getTranslated('is_available', context)}', snackBarStatus: SnackBarStatus.info);
                }
              }else{
                ResponsiveHelper.isDesktop(context)
                    ? tooltipKey.currentState?.showTooltip(context)
                    : showCustomSnackBarHelper('${getTranslated('you_cant_add_more_than', context)} $maxOrderQuantity '
                    '${getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)}');
              }
            }
          }
        },
        child: ResponsiveHelper.isDesktop(context)  ? Container(
          height: 30, width: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5)),
          child: Center(
            child: Icon(
              isIncrement ? Icons.add : Icons.remove,
              color: isIncrement
                  ? Theme.of(context).primaryColor
                  : quantity > 1
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).primaryColor,
              size: isCartWidget ? 26 : 20,
            ),
          ),
        ) : Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ?  Theme.of(context).primaryColor
                : quantity > 1
                ?  Theme.of(context).primaryColor
                :  Theme.of(context).primaryColor,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ),
    );
  }

  bool hasMaximumQuantityReached(CartProvider cartProvider) {
    return (maxOrderQuantity != null && quantity >= maxOrderQuantity!)
        || (cartIndex != null
            && maxOrderQuantity != null
            && (cartProvider.updatedCartList[cartIndex!].quantity ?? 0) >= maxOrderQuantity!);
  }
}
