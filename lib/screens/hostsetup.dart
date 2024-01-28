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
  final _nameController = TextEditingController();

  static const int _nameMaxLength = 12;

  bool loading = false;
  bool error = false;
  bool canConfirm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: FCAppBar(title: Text(AppLocalizations.of(context)!.hostGame)),
        body: SingleChildScrollView(
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
                  controller: _nameController,
                  onChanged: (_) => {
                        setState(() => canConfirm = _canConfirm(
                            _nameController.text, _timeControlController.text))
                      }),
              Text(AppLocalizations.of(context)!.timeControl,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              Focus(
                  onFocusChange: (focused) {
                    if (!focused) {
                      if (_timeControlController.text == "0:00:00") {
                        _timeControlController.text = "";
                      } else {
                        _timeControlController.text =
                            _fixupTimeFormat(_timeControlController.text);
                      }
                    }
                  },
                  child: FCTextField(
                      controller: _timeControlController,
                      textDirection: TextDirection.rtl,
                      hintText: "0:00:00",
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        const TimeTextFormatter(numDigits: 5)
                      ],
                      keyboardType: TextInputType.number,
                      onChanged: (_) => {
                            setState(() => canConfirm = _canConfirm(
                                _nameController.text,
                                _timeControlController.text))
                          })),
              const Padding(padding: EdgeInsets.only(top: 15)),
              Text(AppLocalizations.of(context)!.increment,
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center),
              Focus(
                  onFocusChange: (focused) {
                    if (!focused) {
                      if (_incrementController.text == "0:00") {
                        _incrementController.text = "";
                      } else {
                        _incrementController.text =
                            _fixupTimeFormat(_incrementController.text);
                      }
                    }
                  },
                  child: FCTextField(
                      controller: _incrementController,
                      textDirection: TextDirection.rtl,
                      hintText: "0:00",
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        const TimeTextFormatter(numDigits: 3)
                      ],
                      keyboardType: TextInputType.number)),
              const Padding(padding: EdgeInsets.only(top: 30)),
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
                      onPressed: canConfirm ? () => _onConfirm(context) : null,
                      child: Text(AppLocalizations.of(context)!.confirm)),
            ])));
  }

  bool _canConfirm(String name, String timeControl) {
    bool c = name != "" && (timeControl != "" && timeControl != "0:00:00");
    return c;
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
      client = Client(name: _nameController.text, roomCode: code);
      debugPrint('Host front end making client ${_nameController.text}');
    } catch (e) {
      loading = false;
      error = true;
      debugPrint(e.toString());
      return;
    }

    void goToHostLobby() {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => HostLobby(roomCode: code, client: client)),
        );
      }
      client.removeListener(goToHostLobby);
    }

    client.addListener(goToHostLobby);

    Timer(const Duration(milliseconds: 10000), () {
      if (!mounted) {
        debugPrint("User has left the host setup screen");
        return;
      }

      //We have taken more than 10 seconds to connect, probably a network
      //issue
      debugPrint("Failed to host game");
      setState(() {
        loading = false;
        error = true;
      });
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
      if (i != 0) {
        if (num >= 60) {
          num -= 60;
          carry = 1;
        } else {
          carry = 0;
        }
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
      int beg = i > 2 ? i - 2 : 0;
      output = "${noColons.substring(beg, i)}$output";
    }

    return TextEditingValue(
      text: output,
      selection:
          TextSelection.fromPosition(TextPosition(offset: output.length)),
    );
  }
}
