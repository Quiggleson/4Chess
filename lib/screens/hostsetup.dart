import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourchess/theme/fc_colors.dart';
import 'package:fourchess/widgets/debugonly.dart';
import 'package:fourchess/widgets/fc_appbar.dart';
import 'dart:core';
import 'package:fourchess/widgets/fc_loadinganimation.dart';
import 'package:fourchess/widgets/fc_textfield.dart';
import '../backend/client.dart';
import '../util/gamestate.dart';
import '../backend/host.dart';
import '../widgets/fc_button.dart';
import '../util/player.dart';
import 'hostlobby.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/services.dart';

class HostSetup extends StatefulWidget {
  const HostSetup({super.key});
  @override
  HostSetupState createState() => HostSetupState();
}

class HostSetupState extends State<HostSetup> {
  final _timeControlController = TextEditingController();
  final _incrementController = TextEditingController();

  String _name = "";
  static const int _nameMaxLength = 12;

  bool loading = false;
  bool error = false;

  String _increment = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context)!.hostGame)),
        body: Padding(
            padding: const EdgeInsets.all(30),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(AppLocalizations.of(context)!.hostInstructions,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              const Padding(padding: EdgeInsets.only(top: 30)),
              FCTextField(
                maxLength: _nameMaxLength,
                hintText: AppLocalizations.of(context)!.name,
                onChanged: (value) => setState(() => _name = value),
              ),
              FCTextField(
                controller: _timeControlController,
                textDirection: TextDirection.rtl,
                hintText: "0:00:00",
                inputFormatters: [TimeControlTextFormatter()],
                onEditingComplete: () {
                  if (_timeControlController.text == "0:00:00") {
                    _timeControlController.text = "";
                  } else {
                    String newTime =
                        _fixupTimeControl(_timeControlController.text);
                    _timeControlController.text = newTime;
                  }
                },
              ),
              FCTextField(
                controller: _incrementController,
                textDirection: TextDirection.rtl,
                hintText: "0:00",
                inputFormatters: [IncrementTextFormatter()],
                onEditingComplete: () {
                  if (_incrementController.text == "0:00:00") {
                    _incrementController.text = "";
                  } else {
                    String newTime = _fixupIncrement(_incrementController.text);
                    _incrementController.text = newTime;
                  }
                },
              ),
              const Padding(padding: EdgeInsets.only(top: 30)),
              const Spacer(),
              DebugOnly(text: "force start game", onPress: _forceOnConfirm),
              Visibility(
                  visible: error,
                  child: Text(AppLocalizations.of(context)!.unableToCreate,
                      style: const TextStyle(
                          fontSize: 16, color: FCColors.error))),
              const Padding(padding: EdgeInsets.only(top: 10)),
              loading
                  ? const FCLoadingAnimation()
                  : FCButton(
                      onPressed:
                          _name.isEmpty ? null : () => _onConfirm(context),
                      child: Text(AppLocalizations.of(context)!.confirm)),
            ])));
  }

  _onConfirm(BuildContext context) async {
    setState(() {
      loading = true;
      error = false;
    });

    //When user presses
    GameState gameState = GameState(
      initTime: _timeControlToSeconds(_timeControlController.text),
      increment: _incrementToSeconds(_incrementController.text),
      players: <Player>[],
    );

    late Host host;
    late String code;
    late Client client;

    try {
      host = Host(gameState: gameState);
      code = await host.getRoomCode();
      client = Client(name: _name, roomCode: await host.getRoomCode());
      debugPrint('Host front end making client $_name');
    } catch (e) {
      loading = false;
      error = true;
      debugPrint(e.toString());
      return;
    }

    double elapsedTime = 0;

    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //checks twice a second to see if have successfully joined the game
      elapsedTime += .5;

      //Mounted checks if the widget is still in the build tree i.e make sure we're still on this screen before we do
      //any funny stuff

      if (!mounted) {
        timer.cancel();
        debugPrint("User has left the host setup screen");
      }

      if (client.isDirty() && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => HostLobby(roomCode: code, client: client)),
        );
        timer.cancel();
      }

      debugPrint("Time elapsed since attempting to host game: $elapsedTime");

      if (elapsedTime > 10 && mounted) {
        //We have taken more than 10 seconds to connect, probably a network
        //issue
        debugPrint("Failed to host game");
        setState(() {
          loading = false;
          error = true;
        });
        timer.cancel();
      }
    });
  }

  void _forceOnConfirm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HostLobby(
              roomCode: "ABCDEF",
              client: Client(name: "Deven", roomCode: "ABCDEF"))),
    );
    return;
  }

  String _fixupTimeControl(String time) {
    int hours = int.parse(time.substring(0, 1));
    int minutes = int.parse(time.substring(2, 4));
    int seconds = int.parse(time.substring(5, 7));

    if (seconds > 60) {
      seconds -= 60;
      minutes += 1;
    }
    if (minutes > 60) {
      minutes -= 60;
      hours += 1;
    }

    String minuteString = minutes < 10 ? "0$minutes" : minutes.toString();
    String secondString = seconds < 10 ? "0$seconds" : seconds.toString();

    return "$hours:$minuteString:$secondString";
  }

  String _fixupIncrement(String time) {
    int minutes = int.parse(time.substring(0, 1));
    int seconds = int.parse(time.substring(2, 4));

    if (seconds > 60) {
      seconds -= 60;
      minutes += 1;
    }

    String minuteString = minutes.toString();
    String secondString = seconds < 10 ? "0$seconds" : seconds.toString();

    return "$minuteString:$secondString";
  }

  int _timeControlToSeconds(String time) {
    int hours = int.parse(time.substring(0, 1));
    int minutes = int.parse(time.substring(2, 4));
    int seconds = int.parse(time.substring(5, 7));

    return hours * 3600 + minutes * 60 + seconds;
  }

  int _incrementToSeconds(String time) {
    int minutes = int.parse(time.substring(0, 1));
    int seconds = int.parse(time.substring(2, 4));

    return minutes * 60 + seconds;
  }
}

class TimeControlTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String noColons = newValue.text.replaceAll(':', '');
    int length = noColons.length;

    if (length > 5) {
      noColons = noColons.substring(length - 5);
    } else {
      noColons = '0' * (5 - length) + noColons;
    }

    String output =
        "${noColons.substring(0, 1)}:${noColons.substring(1, 3)}:${noColons.substring(3, 5)}";

    return TextEditingValue(
      text: output,
      selection: TextSelection.fromPosition(TextPosition(offset: 7)),
    );
  }
}

class IncrementTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String noColons = newValue.text.replaceAll(':', '');
    int length = noColons.length;

    if (length > 3) {
      noColons = noColons.substring(length - 3);
    } else {
      noColons = '0' * (3 - length) + noColons;
    }

    String output = "${noColons.substring(0, 1)}:${noColons.substring(1, 3)}";

    return TextEditingValue(
      text: output,
      selection: TextSelection.fromPosition(TextPosition(offset: 4)),
    );
  }
}
