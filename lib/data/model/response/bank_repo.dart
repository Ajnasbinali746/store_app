import 'package:get/get.dart';
import 'package:sixam_mart_store/controller/auth_controller.dart';
import 'package:sixam_mart_store/data/api/api_client.dart';
import 'package:sixam_mart_store/data/model/body/bank_info_body.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class BankRepo {
  final ApiClient apiClient;
  BankRepo({required this.apiClient});
  
  Future<Response> updateBankInfo(BankInfoBody bankInfoBody) async {
    return await apiClient.putData(AppConstants.updateBankInfoUri, bankInfoBody.toJson());
  }

  Future<Response> getWithdrawList() async {
    return await apiClient.getData(AppConstants.withdrawListUri);
  }

  Future<Response> requestWithdraw(Map<String?, String> data) async {
    return await apiClient.postData(AppConstants.withdrawRequestUri, data);
  }

  Future<Response> getWithdrawMethodList() async {
    return await apiClient.getData(AppConstants.withdrawRequestMethodUri);
  }

  Future<Response> getWalletPaymentList() async {
    return await apiClient.getData(AppConstants.walletPaymentListUri);
  }

  Future<Response> makeWalletAdjustment() async {
    return await apiClient.postData(AppConstants.makeWalletAdjustmentUri, {'token': Get.find<AuthController>().getUserToken()});
  }

  Future<Response> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    return await apiClient.postData(AppConstants.makeCollectedCashPaymentUri,
        {
          "amount": amount,
          "payment_gateway": paymentGatewayName,
          "callback": RouteHelper.success,
          "token": Get.find<AuthController>().getUserToken(),
        },
    );
  }
}