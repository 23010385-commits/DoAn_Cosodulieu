import 'package:flutter/material.dart';
import '../utils/localization.dart';
import '../utils/navigation.dart';
import '../widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  final NgonNgu ngonNgu;
  final Function(NgonNgu) doiNgonNgu;

  const SettingsPage({
    super.key,
    required this.ngonNgu,
    required this.doiNgonNgu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '⚙️ ${Strings.get(StringsEnum.caiDat, ngonNgu)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('🌐 Chọn ngôn ngữ / Choose Language:'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => doiNgonNgu(NgonNgu.viet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ngonNgu == NgonNgu.viet
                        ? Colors.tealAccent
                        : const Color.fromARGB(240, 202, 199, 199),
                  ),
                  child: const Text('Tiếng Việt'),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () => doiNgonNgu(NgonNgu.anh),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ngonNgu == NgonNgu.anh
                        ? Colors.blue
                        : const Color.fromARGB(255, 202, 195, 195),
                  ),
                  child: const Text('English'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              Strings.get(StringsEnum.gioiThieuCaiDat, ngonNgu),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: Strings.get(StringsEnum.quayLai, ngonNgu),
              color: const Color.fromARGB(255, 196, 194, 194),
              onPressed: () => quay_ve_man_hinh_truoc(context),
              icon: Icons.arrow_back,
            ),
          ],
        ),
      ),
    );
  }
}
