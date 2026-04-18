import 'package:flutter/material.dart';
import 'nfc_writer.dart';

class DigitalCardPage extends StatelessWidget {
  const DigitalCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Digital Card")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 40),
            const SizedBox(height: 16),
            const Text("Bereket", style: TextStyle(fontSize: 22)),
            const Text("+251900000000"),
            const Text("bereket@email.com"),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hold phone near NFC tag...")),
                );

                try {
                  await NFCWriter().writeVCard();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("NFC written successfully ✅")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Failed to write NFC : ${e.toString()}"),
                    ),
                  );
                }
              },
              child: const Text("Tap to Write NFC"),
            ),
          ],
        ),
      ),
    );
  }
}
