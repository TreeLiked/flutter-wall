class Result<T> {
  bool isSuccess = false;
  String code;
  String message;
  T data;

  Result.fromJson(Map<String, dynamic> json)
      : isSuccess = json['isSuccess'],
        code = json['code'] is String ? json['code']: json['code'].toString(),
        message = json['message'],
        data = json['data'];

  Result({this.isSuccess});

  Result.fromResult(Result r)
      : isSuccess = r.isSuccess,
        code = r.code,
        message = r.message;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'isSuccess': isSuccess, 'code': code, 'message': message, 'data': data};

  void toText() {
    print("$isSuccess, $message, $code, $data");
  }
}
