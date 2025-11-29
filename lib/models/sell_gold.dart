class GoldSellResponse {
  String? status;
  GoldSellData? data;

  GoldSellResponse({this.status, this.data});

  GoldSellResponse.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    data = json["data"] != null ? GoldSellData.fromJson(json["data"]) : null;
  }
}

class GoldSellData {
  String? trxId;
  String? goldGrams;
  String? grossAmount;
  String? gstAmount;
  String? gstPercentage;
  String? tdsAmount;
  String? tdsPercentage;
  String? tcsAmount;
  String? tcsPercentage;
  String? totalDeductions;
  String? netAmount;
  String? payoutMethod;
  String? paymentMethod;
  String? status;
  String? message;
  

  GoldSellData.fromJson(Map<String, dynamic> json) {
    trxId = json["trx_id"];
    goldGrams = json["gold_grams"];
    grossAmount = json["gross_amount"];
    gstAmount = json["gst_amount"];
    gstPercentage = json["gst_percentage"];
    tdsAmount = json["tds_amount"];
    tdsPercentage = json["tds_percentage"];
    tcsAmount = json["tcs_amount"];
    tcsPercentage = json["tcs_percentage"];
    totalDeductions = json["total_deductions"];
    netAmount = json["net_amount"];
    payoutMethod = json["payout_method"];
    paymentMethod = json["payment_method"];
    status = json["status"];
    message = json["message"];
  }
}
