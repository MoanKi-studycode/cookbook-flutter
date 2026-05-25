import 'package:flutter/material.dart';

Future<String?> showConfirmDialog(BuildContext context, String message) async {
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Xác nhận"),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "cancel"),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, "ok"),
            child: const Text("Đồng ý"),
          ),
        ],
      );
    },
  );
}
