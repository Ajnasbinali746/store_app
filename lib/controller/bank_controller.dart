import 'package:flutter/material.dart';
import 'package:sixam_mart_store/controller/auth_controller.dart';
import 'package:sixam_mart_store/data/api/api_checker.dart';
import 'package:sixam_mart_store/data/model/body/bank_info_body.dart';
import 'package:sixam_mart_store/data/model/response/bank_repo.dart';
import 'package:sixam_mart_store/data/model/response/response_model.dart';
import 'package:sixam_mart_store/data/model/response/wallet_payment_model.dart';
import 'package:sixam_mart_store/data/model/response/widthdrow_method_model.dart';
import 'package:sixam_mart_store/data/model/response/withdraw_model.dart';
import 'package:sixam_mart_store/helper/route_helper.dart';
import 'package:sixam_mart_store/util/styles.dart';
import 'package:sixam_mart_store/view/base/custom_snackbar.dart';
import 'package:get/get.dart';

class BankController extends GetxController implements GetxService {
  final BankRepo bankRepo;
  BankController({required this.bankRepo});

  bool _isLoading = false;
  List<WithdrawModel>? _withdrawList;
  late List<WithdrawModel> _allWithdrawList;
  double _pendingWithdraw = 0;
  double _withdrawn = 0;
  final List<String> _statusList = ['All', 'Pending', 'Approved', 'Denied'];
  int _filterIndex = 0;
  List<WidthDrawMethodModel>? _widthDrawMethods;
  int? _methodIndex = 0;
  List<DropdownMenuItem<int>> _methodList = [];
  List<TextEditingController> _textControllerList = [];
  List<MethodFields> _methodFields = [];
  List<FocusNode> _focusList = [];
  int _selectedIndex = 0;
  List<Transactions>? _transactions;
  bool _adjustmentLoading = false;

  bool get isLoading => _isLoading;
  List<WithdrawModel>? get withdrawList => _withdrawList;
  double get pendingWithdraw => _pendingWithdraw;
  double get withdrawn => _withdrawn;
  List<String> get statusList => _statusList;
  int get filterIndex => _filterIndex;
  List<WidthDrawMethodModel>? get widthDrawMethods => _widthDrawMethods;
  int? get methodIndex => _methodIndex;
  List<DropdownMenuItem<int>> get methodList => _methodList;
  List<TextEditingController> get textControllerList => _textControllerList;
  List<MethodFields> get methodFields => _methodFields;
  List<FocusNode> get focusList => _focusList;
  int get selectedIndex => _selectedIndex;
  List<Transactions>? get transactions => _transactions;
  bool get adjustmentLoading => _adjustmentLoading;

  Future<ResponseModel> makeCollectCashPayment(double amount, String paymentGatewayName) async {
    _isLoading = true;
    update();
    Response response = await bankRepo.makeCollectCashPayment(amount, paymentGatewayName);
    ResponseModel responseModel;
    if (response.statusCode == 200) {

      String redirectUrl = response.body['redirect_link'];
      Get.back();
      if(GetPlatform.isWeb) {

        // html.window.open(redirectUrl,"_self");
      } else{
        Get.toNamed(RouteHelper.getPaymentRoute(null, redirectUrl));
      }
      responseModel = ResponseModel(true, response.body.toString());
    } else {
      responseModel = ResponseModel(false, response.statusText);
    }
    _isLoading = false;
    update();
    return responseModel;
  }

  void setMethod({bool isUpdate = true}){
    _methodList = [];
    _textControllerList = [];
    _methodFields = [];
    _focusList = [];
    if(widthDrawMethods != null && widthDrawMethods!.isNotEmpty){
      for(int i=0; i< widthDrawMethods!.length; i++){
        _methodList.add(DropdownMenuItem<int>(value: i, child: SizedBox(
          width: Get.context!.width-100,
          child: Text(widthDrawMethods![i].methodName!, style: robotoBold),
        )));
      }

      _textControllerList = [];
      _methodFields = [];
      for (var field in widthDrawMethods![_methodIndex!].methodFields!) {
        _methodFields.add(field);
        _textControllerList.add(TextEditingController());
        _focusList.add(FocusNode());
      }
    }
    if(isUpdate) {
      update();
    }
  }

  void setMethodIndex(int? index) {
    _methodIndex = index;
    // update();
  }

  Future<void> updateBankInfo(BankInfoBody bankInfoBody) async {
    _isLoading = true;
    update();
    Response response = await bankRepo.updateBankInfo(bankInfoBody);
    if(response.statusCode == 200) {
      Get.find<AuthController>().getProfile();
      Get.back();
      showCustomSnackBar('bank_info_updated'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> getWithdrawList() async {
    Response response = await bankRepo.getWithdrawList();
    if(response.statusCode == 200) {
      _withdrawList = [];
      _allWithdrawList = [];
      _pendingWithdraw = 0;
      _withdrawn = 0;
      response.body.forEach((withdraw) {
        WithdrawModel withdrawModel = WithdrawModel.fromJson(withdraw);
        _withdrawList!.add(withdrawModel);
        _allWithdrawList.add(withdrawModel);
        if(withdrawModel.status == 'Pending') {
          _pendingWithdraw = _pendingWithdraw + withdrawModel.amount!;
        }else if(withdrawModel.status == 'Approved') {
          _withdrawn = _withdrawn + withdrawModel.amount!;
        }
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<List<WidthDrawMethodModel>?> getWithdrawMethodList() async {
    Response response = await bankRepo.getWithdrawMethodList();
    if(response.statusCode == 200) {
      _widthDrawMethods = [];
      response.body.forEach((method) {
        WidthDrawMethodModel withdrawMethod = WidthDrawMethodModel.fromJson(method);
        _widthDrawMethods!.add(withdrawMethod);
      });
    }else {
      ApiChecker.checkApi(response);
    }
    update();
    return _widthDrawMethods;
  }

  void setIndex(int index) {
    _selectedIndex = index;
    update();
  }

  Future<void> getWalletPaymentList() async {
    _transactions = null;
    Response response = await bankRepo.getWalletPaymentList();
    if(response.statusCode == 200) {
      _transactions = [];
      WalletPaymentModel walletPaymentModel = WalletPaymentModel.fromJson(response.body);
      _transactions!.addAll(walletPaymentModel.transactions!);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> makeWalletAdjustment() async {
    _adjustmentLoading = true;
    update();
    Response response = await bankRepo.makeWalletAdjustment();
    if(response.statusCode == 200) {
      Get.back();
      Get.find<AuthController>().getProfile();
      showCustomSnackBar('wallet_adjustment_successfully'.tr, isError: false);
    }else {
      Get.back();
      ApiChecker.checkApi(response);
    }
    _adjustmentLoading = false;
    update();
  }

  void filterWithdrawList(int index) {
    _filterIndex = index;
    _withdrawList = [];
    if(index == 0) {
      _withdrawList!.addAll(_allWithdrawList);
    }else {
      for (var withdraw in _allWithdrawList) {
        if(withdraw.status == _statusList[index]) {
          _withdrawList!.add(withdraw);
        }
      }
    }
    update();
  }

  Future<void> requestWithdraw(Map<String?, String> data) async {
    _isLoading = true;
    update();
    Response response = await bankRepo.requestWithdraw(data);
    if(response.statusCode == 200) {
      Get.back();
      getWithdrawList();
      Get.find<AuthController>().getProfile();
      showCustomSnackBar('request_sent_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

}