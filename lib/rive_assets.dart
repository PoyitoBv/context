import 'package:rive/rive.dart';

class RiveAssets {
  static final RiveAssets _instance = RiveAssets._internal();

  factory RiveAssets() => _instance;

  RiveAssets._internal();

  // -----------------------

  late RiveFile _problemTitle;
  late RiveFile _problemVictim;

  RiveFile get titleAnimation => _problemTitle;
  RiveFile get victimAnimation => _problemVictim;

  Future<void> preloadAssets() async {
    // Initialize Rive
    // await RiveFile.initialize();
    // unawaited(RiveFile.initialize()); //? Sugerencia de Rive

    // Load ProblemTitle

    _problemTitle = await RiveFile.asset('assets/problemtitle.riv');
    _problemVictim = await RiveFile.asset('assets/victim.riv');

    // try {
    //   rootBundle.load('assets/problemtitle.riv').then(
    //     (data) async {
    //       // Load the RiveFile from the binary data.
    //       _problemTitle = RiveFile.import(data);

    //       debugPrint("[Preload] => RiveAnimation Status: OK");
    //     },
    //   ).catchError((e) {
    //     print(e);
    //   });

    //   // Load ProblemVictim
    //   rootBundle.load('assets/victim.riv').then(
    //     (data) async {
    //       // Load the RiveFile from the binary data.
    //       _problemVictim = RiveFile.import(data);

    //       debugPrint("[Preload] => RiveAnimation Status: OK");
    //     },
    //   ).catchError((e) {
    //     print(e);
    //   });
    // } catch (e) {
    //   log("{Error} => On Preload: $e");
    // }
  }
}
