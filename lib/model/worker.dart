class Worker {
  String? workerId;
  String? workerFullName;
  String? workerUsername;
  String? workerEmail;
  String? workerPassword;
  String? workerPhone;
  String? workerAddress;

  Worker({
    this.workerId,
    this.workerUsername,
    this.workerFullName,
    this.workerEmail,
    this.workerPassword,
    this.workerPhone,
    this.workerAddress,
  });

  // Convert JSON to Worker object
  Worker.fromJson(Map<String, dynamic> json) {
    workerId = json['id'];
    workerFullName = json['full_name'];
    workerUsername = json['username'];
    workerEmail = json['email'];
    workerPassword = json['password'];
    workerPhone = json['phone'];
    workerAddress = json['address'];
  }

  // Convert Worker object to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = workerId;
    data['full_name'] = workerFullName; 
    data['username'] = workerUsername;
    data['email'] = workerEmail;
    data['password'] = workerPassword;
    data['phone'] = workerPhone;
    data['address'] = workerAddress;
    return data;
  }
}
