import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:where_to/widgets/app_text.dart';

class AuthButton extends StatefulWidget {
  final bool loading;
  final Function buttonClicked;
  final String buttonText;
  const AuthButton(
      {Key? key,
      required this.buttonText,
      required this.loading,
      required this.buttonClicked})
      : super(key: key);

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
      child: Container(
          height: 45,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [
                    0.1,
                    0.95
                  ],
                  colors: [
                    Color.fromARGB(230, 252, 67, 141),
                    Color.fromARGB(230, 0, 238, 255)
                  ]),
              borderRadius: BorderRadius.circular(10)),
          child: widget.loading
              ? const UnconstrainedBox(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    widget.buttonClicked();
                  },
                  style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white)),
                  child: AppTextHeader(text: widget.buttonText, fontSize: 22))),
    );
  }
}
