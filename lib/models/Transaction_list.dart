class TransactionResponse {
  String? status;
  TransactionPageData? data;

  TransactionResponse.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    data = json["data"] != null
        ? TransactionPageData.fromJson(json["data"])
        : null;
  }
}

class TransactionPageData {
  int? currentPage;
  List<TransactionItem>? transactions;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  int? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  TransactionPageData.fromJson(Map<String, dynamic> json) {
    currentPage = json["current_page"];
    transactions = json["data"] != null
        ? List<TransactionItem>.from(
        json["data"].map((x) => TransactionItem.fromJson(x)))
        : [];
    firstPageUrl = json["first_page_url"];
    from = json["from"];
    lastPage = json["last_page"];
    lastPageUrl = json["last_page_url"];
    nextPageUrl = json["next_page_url"];
    path = json["path"];
    perPage = json["per_page"];
    prevPageUrl = json["prev_page_url"];
    to = json["to"];
    total = json["total"];
  }
}

class TransactionItem {
  int? id;
  String? status;
  String? amount;
  String? charge;
  String? trxType;
  String? trxId;
  String? remarks;
  String? createdAt;
  String? baseCurrency;
  String? currencySymbol;

  TransactionItem.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    amount = json["amount"];
    charge = json["charge"];
    trxType = json["trx_type"];
    trxId = json["trx_id"];
    remarks = json["remarks"];
    createdAt = json["created_at"];
    baseCurrency = json["base_currency"];
    currencySymbol = json["currency_symbol"];
    status= json['status'];
  }
}
