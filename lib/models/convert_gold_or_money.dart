class GoldCalculationResponse {
  String? status;
  GoldCalculationData? data;

  GoldCalculationResponse.fromJson(Map<String, dynamic> json) {
    status = json["status"];
    data = json["data"] != null
        ? GoldCalculationData.fromJson(json["data"])
        : null;
  }
}

class GoldCalculationData {
  String? grams;
  String? grossAmount;
  String? gstAmount;
  String? netAmount;
  String? goldPricePerGram;

  GoldCalculationData.fromJson(Map<String, dynamic> json) {
    grams = json["grams"];
    grossAmount = json["gross_amount"];
    gstAmount = json["gst_amount"];
    netAmount = json["net_amount"];
    goldPricePerGram = json["gold_price_per_gram"];
  }
}
