class AnimationsController {
  static final AnimationsController _instance =
      AnimationsController._internal();

  factory AnimationsController() => _instance;

  AnimationsController._internal();

  // ------------------------

  late Function() _showSelected;
  late Future Function() hideSelected;
  set showSelected(Function() x) => _showSelected = x;
  Function() get showSelected => nowReadSelected;

  late Function() _showTitleSelected;
  late Future Function() hideTitleSelected;
  set showTitleSelected(Function() x) => _showTitleSelected = x;
  Function() get showTitleSelected => nowReadTitle;

  late Future Function() _showNavigation;
  late Future Function() hideNavigation;
  set showNavigation(Future Function() x) => _showNavigation = x;

  bool isShowedNavigator = false;

  void minimizeShowed() {
    hideSelected();
    hideTitleSelected();

    _showNavigation();

    isShowedNavigator = true;
  }

  void nowReadSelected() {
    hideNavigation();

    _showSelected();

    isShowedNavigator = false;
  }

  void nowReadTitle() {
    hideNavigation();

    _showTitleSelected();

    isShowedNavigator = false;
  }

  Future<void> hideAll() async {
    final List<Future> toWait = [];

    toWait.addAll([hideSelected(), hideTitleSelected(), hideNavigation()]);

    await Future.wait(toWait);
  }
}
