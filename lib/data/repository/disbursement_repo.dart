import 'package:get/get_connect/http/src/response/response.dart';
import 'package:sixam_mart_store/data/api/api_client.dart';
import 'package:sixam_mart_store/util/app_constants.dart';

class DisbursementRepo {
  final ApiClient apiClient;

  DisbursementRepo({required this.apiClient});

  Future<Response> addWithdraw(Map<String?, String> data) async {
    return await apiClient.postData(AppConstants.addWithdrawMethodUri, data);
  }

  Future<Response> getDisbursementMethodList() async {
    return await apiClient.getData('${AppConstants.disbursementMethodListUri}?limit=10&offset=1');
  }

  Future<Response> makeDefaultMethod(Map<String?, String> data) async {
    return await apiClient.postData(AppConstants.makeDefaultDisbursementMethodUri, data);
  }

  Future<Response> deleteMethod(int id) async {
    return await apiClient.postData(AppConstants.deleteDisbursementMethodUri, {'_method': 'delete', 'id': id});
  }

  Future<Response> getDisbursementReport(int offset) async {
    return await apiClient.getData('${AppConstants.getDisbursementReportUri}?limit=10&offset=$offset');
  }

}