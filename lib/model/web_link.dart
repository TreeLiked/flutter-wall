class WebLinkModel {
  String url;
  String title;
  String iconPath;

  WebLinkModel(this.url, this.title, this.iconPath) {
    if (this.title == null) {
      this.title = this.url;
    }
    if (this.iconPath == null) {
      this.iconPath = "";
    }
  }
}
