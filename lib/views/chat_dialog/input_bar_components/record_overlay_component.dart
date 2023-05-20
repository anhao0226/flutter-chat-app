import 'package:desktop_app/utils/index.dart';
import 'package:flutter/material.dart';

class OverlayComponent extends StatefulWidget {
  const OverlayComponent({
    super.key,
    required this.amplitude,
    required this.selectStatus,
  });

  final List<double> amplitude;
  final int selectStatus;

  @override
  State<StatefulWidget> createState() => _OverlayComponentState();
}

class _OverlayComponentState extends State<OverlayComponent> {
  // final List<double> _amplitude = List.generate(100, (index) => 30);
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        logger.i(details);
      },
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _getAmplitudeUI(),
            Container(
              margin: const EdgeInsets.only(
                  bottom: 60, left: 20, right: 20, top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 66,
                    height: 66,
                    decoration:  BoxDecoration(
                      color: widget.selectStatus == 1
                          ? Colors.redAccent
                          : const Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(33)),
                    ),
                    child: const Icon(
                      Icons.save_alt,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                    ),
                  ),
                  // [ x >  ]
                  Container(
                    width: 66,
                    height: 66,
                    decoration:  BoxDecoration(
                      color: widget.selectStatus == 2
                          ? const Color(0xFF967ADC)
                          : const Color.fromRGBO(0, 0, 0, 0.2),
                      borderRadius: const BorderRadius.all(Radius.circular(33)),
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Color.fromRGBO(255, 255, 255, 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAmplitudeUI() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.amplitude.length,
        itemBuilder: (context, index) {
          return Center(
            child: Container(
              width: 2,
              height: widget.amplitude[index],
              margin: const EdgeInsets.only(left: 2),
              constraints: const BoxConstraints(
                minHeight: 10,
              ),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.4),
                borderRadius: BorderRadius.all(
                  Radius.circular(1),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
