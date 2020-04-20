class Result<T> {
  bool isSuccess = false;
  String code;
  String message;
  T data;

  Result.fromJson(Map<String, dynamic> json)
      : isSuccess = json['isSuccess'],
        code = json['code'],
        message = json['message'],
        data = json['data'];

  Result({this.isSuccess});


  Result.fromResult(Result r)
      : isSuccess = r.isSuccess,
        code = r.code,
        message = r.message;



}
