import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final void Function(String text) onSendText;
  final void Function(Uint8List bytes) onSendPhoto;

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.onSendText,
    required this.onSendPhoto,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      widget.onSendPhoto(bytes);
    }
  }

  void _submitText() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendText(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: const Color(0xFF0D0020),
        child: Row(
          children: [
            IconButton(
              onPressed: widget.enabled ? _pickFromCamera : null,
              icon: Icon(
                Icons.camera_alt,
                color: widget.enabled
                    ? const Color(0xFF39FF14)
                    : Colors.white24,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                enabled: widget.enabled,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Mensaje…' : 'Vínculo expirado',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _submitText(),
              ),
            ),
            IconButton(
              onPressed: widget.enabled ? _submitText : null,
              icon: Icon(
                Icons.send,
                color: widget.enabled
                    ? const Color(0xFFB300FF)
                    : Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
