class EnrollInvestmentPlans {
  String status;
  String data;

  EnrollInvestmentPlans({
    required this.status,
    required this.data,
  });

  EnrollInvestmentPlans.fromJson(Map<String, dynamic> json)
      : status = json['status'] ?? "",
        data = json['data'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "data": data,
    };
  }
}
