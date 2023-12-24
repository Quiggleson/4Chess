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
import 'dart:math';

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
                inputFormatters: const [TimeTextFormatter(numDigits: 5)],
                onEditingComplete: () {
                  if (_timeControlController.text == "0:00:00") {
                    _timeControlController.text = "";
                  } else {
                    String newTime =
                        _fixupTimeFormat(_timeControlController.text);
                    _timeControlController.text = newTime;
                  }
                },
              ),
              FCTextField(
                controller: _incrementController,
                textDirection: TextDirection.rtl,
                hintText: "0:00",
                inputFormatters: const [TimeTextFormatter(numDigits: 3)],
                onEditingComplete: () {
                  if (_incrementController.text == "0:00") {
                    _incrementController.text = "";
                  } else {
                    String newTime =
                        _fixupTimeFormat(_incrementController.text);
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
      initTime: _timeToSeconds(_timeControlController.text),
      increment: _timeToSeconds(_incrementController.text),
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
    debugPrint(_timeToSeconds(_timeControlController.text).toString());
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => HostLobby(
              roomCode: "ABCDEF",
              client: Client(name: "Deven", roomCode: "ABCDEF"))),
    );
    return;
  }

  //STRING FORMAT METHODS
  String _fixupTimeFormat(String time) {
    List<String> splitTimes = time.split(':');

    int carry = 0;
    for (int i = splitTimes.length - 1; i > -1; i--) {
      int num = int.parse(splitTimes[i]) + carry;

      String padding = "";
      if (i != 0 && num > 60) {
        num -= 60;
        carry = 1;
        if (num < 10) {
          padding = "0";
        }
      }

      splitTimes[i] = "$padding${num.toString()}";
    }

    return splitTimes.join(':');
  }

  int _timeToSeconds(String time) {
    int sum = 0;
    List<String> splitTimes = time.split(':');
    int length = splitTimes.length;

    for (int i = length - 1; i > -1; i--) {
      sum += int.parse(splitTimes[i]) * pow(60, length - 1 - i) as int;
    }

    return sum;
  }
}

class TimeTextFormatter extends TextInputFormatter {
  const TimeTextFormatter({required this.numDigits});

  final int numDigits;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String noColons = newValue.text.replaceAll(':', '');
    int length = noColons.length;

    if (length > numDigits) {
      noColons = noColons.substring(length - numDigits);
    } else {
      noColons = '0' * (numDigits - length) + noColons;
    }

    String output = "";
    for (int i = numDigits; i > 0; i -= 2) {
      if (i < numDigits) {
        output = ":$output";
      }
      int beg = i > 1 ? i - 2 : 0;
      output = "${noColons.substring(beg, i)}$output";
    }

    return TextEditingValue(
      text: output,
      selection:
          TextSelection.fromPosition(TextPosition(offset: output.length)),
    );
  }
}
