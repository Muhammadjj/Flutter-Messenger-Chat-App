//custom options card (for copy, edit, delete, etc.)
// ignore_for_file: must_be_immutable

import '../../../Export/export_file.dart';

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  late Size size;
  OptionItem(
      {super.key,
      required this.icon,
      required this.name,
      required this.onTap,
      required this.size});

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.sizeOf(context);
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: size.width * .05,
              top: size.height * .015,
              bottom: size.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
