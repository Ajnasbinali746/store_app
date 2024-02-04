import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/controller/disbursement_controller.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/view/base/custom_button.dart';

class ConfirmDialog extends StatelessWidget {
  final int id;
  const ConfirmDialog({Key? key, required this.id, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisbursementController>(
        builder: (disbursementController) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
            insetPadding: const EdgeInsets.all(30),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: SizedBox(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                child: Column(mainAxisSize: MainAxisSize.min, children: [

                  Icon(Icons.error_outlined, color: Theme.of(context).colorScheme.error, size: 54),
                  const SizedBox(height: Dimensions.paddingSizeLarge),

                  Text(
                    'are_you_sure_to_delete_this_method'.tr,
                    style: robotoMedium,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  !disbursementController.isDeleteLoading ? Row(children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'cancel'.tr,
                        color: Theme.of(context).disabledColor,
                        onPressed: () => Get.back(),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    Expanded(
                      child: CustomButton(
                        buttonText: 'ok'.tr,
                        onPressed: () => disbursementController.deleteMethod(id),
                      ),
                    ),
                  ]) : const Center(child: CircularProgressIndicator()),

                ]),
              ),
            ),
          );
        }
    );
  }
}