import 'package:flutter/material.dart';
import '../api_client/apiClient.dart';
import '../constants/constant.dart';
import '../constants/end_points.dart';
import '../models/Transaction_list.dart';

class TransactionProvider with ChangeNotifier {
  bool isLoading = false;
  TransactionPageData? pageData;
  List<TransactionItem> transactions = [];
  ApiClient transactionApi=ApiClient();

  Future<void> fetchTransactions({int page = 1}) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await transactionApi.getMethod(transactionsList);
      TransactionResponse transactionResponse = TransactionResponse.fromJson(response);
      print("transactionResponse ------ ${transactionResponse.data?.transactions}");

      if (transactionResponse.data != null) {
        pageData = transactionResponse.data!;
        transactions = pageData!.transactions ?? [];
      }
    } catch (e) {
      print("Transaction fetch error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  // ------------------------ FILTER TRANSACTIONS ------------------------
  List<TransactionItem> filterTransactions(String type) {
    if (type.toLowerCase() == 'all') return transactions;
    return transactions.where((txn) => txn.trxType?.toLowerCase() == type.toLowerCase()).toList();
  }
}
