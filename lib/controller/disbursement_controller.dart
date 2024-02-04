import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/controller/bank_controller.dart';
import 'package:sixam_mart_store/controller/splash_controller.dart';
import 'package:sixam_mart_store/data/api/api_checker.dart';
import 'package:sixam_mart_store/data/model/response/disbursement_method_model.dart' as d;
import 'package:sixam_mart_store/data/model/response/disbursement_report_model.dart' as r;
import 'package:sixam_mart_store/data/repository/disbursement_repo.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/view/base/custom_dropdown.dart';
import 'package:sixam_mart_store/view/base/custom_snackbar.dart';
import 'package:sixam_mart_store/view/screens/disbursements/widget/withdraw_method_attention_dialog.dart';

import '../data/model/response/widthdrow_method_model.dart';

class DisbursementController extends GetxController implements GetxService {
  final DisbursementRepo disbursementRepo;

  DisbursementController({required this.disbursementRepo});

  bool _isLoading = false;
  bool _isDeleteLoading = false;
  int? _selectedMethodIndex = 0;
  List<DropdownItem<int>> _methodList = [];
  List<TextEditingController> _textControllerList = [];
  List<MethodFields> _methodFields = [];
  List<FocusNode> _focusList = [];
  List<WidthDrawMethodModel>? _widthDrawMethods;
  d.DisbursementMethodBody? _disbursementMethodBody;
  int? _index = -1;
  r.DisbursementReportModel? _disbursementReportModel;

  bool get isLoading => _isLoading;
  bool get isDeleteLoading => _isDeleteLoading;
  int? get selectedMethodIndex => _selectedMethodIndex;
  List<DropdownItem<int>> get methodList => _methodList;
  List<TextEditingController> get textControllerList => _textControllerList;
  List<MethodFields> get methodFields => _methodFields;
  List<FocusNode> get focusList => _focusList;
  List<WidthDrawMethodModel>? get widthDrawMethods => _widthDrawMethods;
  d.DisbursementMethodBody? get disbursementMethodBody => _disbursementMethodBody;
  int? get index =>_index;
  r.DisbursementReportModel? get disbursementReportModel => _disbursementReportModel;

  void setMethodId(int? id, {bool canUpdate = true}) {
    _selectedMethodIndex = id;
    if(canUpdate){
      update();
    }
  }

  Future<void> setMethod({bool isUpdate = true, bool initCall = false}) async {
    _methodList = [];
    _textControllerList = [];
    _methodFields = [];
    _focusList = [];

    if(Get.find<BankController>().widthDrawMethods == null) {
      _widthDrawMethods = await Get.find<BankController>().getWithdrawMethodList();
    } else {
      _widthDrawMethods = Get.find<BankController>().widthDrawMethods;
    }
    if(_widthDrawMethods != null && _widthDrawMethods!.isNotEmpty){
      for(int i=0; i < _widthDrawMethods!.length; i++){
        _methodList.add(DropdownItem<int>(value: i, child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('${_widthDrawMethods![i].methodName}'),
          ),
        )));
      }

      if(initCall) {
        _selectedMethodIndex = 0;
      }
      _textControllerList = [];
      _methodFields = [];
      print('=====check : $_selectedMethodIndex //${_widthDrawMethods![_selectedMethodIndex!].methodFields}');
      for (var field in _widthDrawMethods![_selectedMethodIndex!].methodFields!) {
        _methodFields.add(field);
        _textControllerList.add(TextEditingController());
        _focusList.add(FocusNode());
      }
    }
    if(isUpdate) {
      update();
    }
  }

  Future<void> addWithdrawMethod(Map<String?, String> data) async {
    _isLoading = true;
    update();
    Response response = await disbursementRepo.addWithdraw(data);
    if(response.statusCode == 200) {
      Get.back();
      getDisbursementMethodList();
      showCustomSnackBar('add_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<bool> getDisbursementMethodList() async {
    bool success = false;
    Response response = await disbursementRepo.getDisbursementMethodList();
    if(response.statusCode == 200) {
      success = true;
      _disbursementMethodBody = d.DisbursementMethodBody.fromJson(response.body);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
    return success;
  }

  Future<void> makeDefaultMethod(Map<String, String> data, int index) async {
    _index = index;
    _isLoading = true;
    update();
    Response response = await disbursementRepo.makeDefaultMethod(data);
    if(response.statusCode == 200) {
      _index = -1;
      getDisbursementMethodList();
      showCustomSnackBar('set_default_method_successful'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> deleteMethod(int id) async {
    _isDeleteLoading = true;
    update();
    Response response = await disbursementRepo.deleteMethod(id);
    if(response.statusCode == 200) {
      getDisbursementMethodList();
      Get.back();
      showCustomSnackBar('method_delete_successfully'.tr, isError: false);
    }else {
      ApiChecker.checkApi(response);
    }
    _isDeleteLoading = false;
    update();
  }

  Future<void> getDisbursementReport(int offset) async {
    Response response = await disbursementRepo.getDisbursementReport(offset);
    if(response.statusCode == 200) {
      _disbursementReportModel = r.DisbursementReportModel.fromJson(response.body);
    }else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<bool> enableDisbursementWarningMessage(bool fromDashboard, {bool canShowDialog = true}) async {

    bool showWarning = false;

    if(Get.find<SplashController>().configModel!.disbursementType == 'automated'){
     await getDisbursementMethodList().then((success) {
        if(success){
          for (var method in disbursementMethodBody!.methods!) {
            if(method.isDefault == 1){
              showWarning = false;
              break;
            } else {
              showWarning = true;
            }
          }
        }
      });
    } else {
      showWarning = false;
    }

    if(showWarning && canShowDialog) {
      Get.dialog(
        Dialog(
          alignment: Alignment.bottomCenter,
          backgroundColor: const Color(0xfffff1f1),
          insetPadding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)), //this right here
          child: WithdrawMethodAttentionDialog(isFromDashboard: fromDashboard),
        ),
      );
    }
    // update();
    return showWarning;
  }

}