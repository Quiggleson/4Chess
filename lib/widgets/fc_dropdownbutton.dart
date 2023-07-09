import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FCDropdownButton extends StatefulWidget {
  @override
  FCDropdownButtonState createState() => FCDropdownButtonState();
}

//TODO: ADD STYLE DEFAULTSCUSTOMIZE FEATURES + CHANGE SELECTED COLOR
class FCDropdownButtonState extends State<FCDropdownButton> {
  String _dropdownValue = "3:00+2";

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          border: Border.all(
              width: 3,
              color: const Color.fromRGBO(68, 170, 255, 1),
              strokeAlign: BorderSide.strokeAlignInside),
          color: const Color.fromRGBO(130, 195, 255, 1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: DropdownButtonHideUnderline(
            child: DropdownButton(
                icon: Container(
                    constraints:
                        const BoxConstraints(minHeight: 90, minWidth: 72),
                    color: const Color.fromRGBO(68, 170, 255, 1),
                    child:
                        const Icon(Icons.arrow_drop_down, color: Colors.black)),
                iconSize: 48,
                isExpanded: true,
                itemHeight: 90,
                style: GoogleFonts.abel(
                  color: Colors.black,
                  fontSize: 56,
                ),
                borderRadius: BorderRadius.circular(15),
                dropdownColor: const Color.fromRGBO(130, 195, 255, 1),
                items: const [
                  DropdownMenuItem(
                      value: "3:00+2", child: Center(child: Text("3:00+2"))),
                  DropdownMenuItem(
                    value: "1:00",
                    child: Center(child: Text("1:00")),
                  ),
                  DropdownMenuItem(
                    value: "3:00",
                    child: Center(child: Text("3:00")),
                  ),
                  DropdownMenuItem(
                    value: "10:00",
                    child: Center(child: Text("10:00")),
                  ),
                ],
                value: _dropdownValue,
                onChanged: (selected) => {
                      if (selected is String)
                        {setState(() => _dropdownValue = selected)}
                    })));
  }
}
