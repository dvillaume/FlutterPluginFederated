import 'package:flutter/material.dart';

class DialerWidget extends StatefulWidget {
  final Function(String) onCallPressed;

  const DialerWidget({
    Key? key,
    required this.onCallPressed,
  }) : super(key: key);

  @override
  State<DialerWidget> createState() => _DialerWidgetState();
}

class _DialerWidgetState extends State<DialerWidget> {
  final TextEditingController _numberController = TextEditingController();
  static const Color primaryColor = Color(0xFF2A3990);
  static const Color accentColor = Color(0xFF4481EB);

  void _onKeyPressed(String value) {
    setState(() {
      _numberController.text = _numberController.text + value;
    });
  }

  void _onDeletePressed() {
    if (_numberController.text.isNotEmpty) {
      setState(() {
        _numberController.text = _numberController.text
            .substring(0, _numberController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Champ de numéro
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              controller: _numberController,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 2,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Entrez un numéro",
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              readOnly: true,
            ),
          ),
          const SizedBox(height: 24),
          // Clavier numérique
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialerButton("1", ""),
                    _buildDialerButton("2", "ABC"),
                    _buildDialerButton("3", "DEF"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialerButton("4", "GHI"),
                    _buildDialerButton("5", "JKL"),
                    _buildDialerButton("6", "MNO"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialerButton("7", "PQRS"),
                    _buildDialerButton("8", "TUV"),
                    _buildDialerButton("9", "WXYZ"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDialerButton("*", ""),
                    _buildDialerButton("0", "+"),
                    _buildDialerButton("#", ""),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                Icons.backspace_outlined,
                Colors.red.shade400,
                _onDeletePressed,
              ),
              _buildCallButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDialerButton(String number, String letters) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onKeyPressed(number),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                if (letters.isNotEmpty)
                  Text(
                    letters,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (_numberController.text.isNotEmpty) {
            widget.onCallPressed(_numberController.text);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [primaryColor, accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.call,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
