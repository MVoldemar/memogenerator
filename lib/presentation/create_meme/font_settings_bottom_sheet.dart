import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/meme_text_on_canvas.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';


class FontSettingBottomSheet extends StatefulWidget {
  final MemeText memeText;
  const FontSettingBottomSheet({Key? key, required this.memeText})
      : super(key: key);

  @override
  State<FontSettingBottomSheet> createState() => _FontSettingBottomSheetState();
}

class _FontSettingBottomSheetState extends State<FontSettingBottomSheet> {
  late double fontSize;
  late Color color;
  late FontWeight fontWeight;
  @override
  void initState() {
    super.initState();
    fontSize = widget.memeText.fontSize;
    color = widget.memeText.color;
    fontWeight = widget.memeText.fontWeight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        //crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 8,
          ),
          Center(
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.darkGrey38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          MemeTextOnCanvas(
            padding: 8,
            selected: true,
            parentConstraints: BoxConstraints.expand(),
            text: widget.memeText.text,
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
          const SizedBox(
            height: 48,
          ),
          FontSizeSlider(
            changeFontSize: (value) {
              setState(() => fontSize = value);
            },
            initialFontSize: fontSize,
          ),
          const SizedBox(
            height: 16,
          ),
          ColorSelection(
            changeColor: (color) {
              setState(() {
                this.color = color;
              });
            },
          ),
          const SizedBox(
            height: 16,
          ),
          FontWeightSlider(
            changeFontWeight: (value) {
              setState(() => fontWeight = calculateFontWeigt(value));
              print(fontWeight);
            },
            initialFontWeight: fontWeight.index.toDouble(),
          ),
          const SizedBox(
            height: 36,
          ),
          Align(
            child: Buttons(
              fontSize: fontSize,
              textId: widget.memeText.id,
              color: color,
              fontWeight: fontWeight,
            ),
            alignment: Alignment.centerRight,
          ),
          const SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }

  FontWeight calculateFontWeigt(double? value) {
    if(value == null)  return FontWeight.w400;
    switch(value.round().toInt()){
      case 0 : fontWeight = FontWeight.w100;
      return fontWeight;
      case 1 : fontWeight = FontWeight.w200;
      return fontWeight;
      case 2 : fontWeight = FontWeight.w300;
      return fontWeight;
      case 3 : fontWeight = FontWeight.w400;
      return fontWeight;
      case 4 : fontWeight = FontWeight.w500;
      return fontWeight;
      case 5 : fontWeight = FontWeight.w600;
      return fontWeight;
      case 6 : fontWeight = FontWeight.w700;
      return fontWeight;
      case 7 : fontWeight = FontWeight.w800;
      return fontWeight;
      case 8 : fontWeight = FontWeight.w900;
      return fontWeight;
    }
    return FontWeight.w800;
  }
}

class Buttons extends StatelessWidget {
  final Color color;
  final String textId;
  final double fontSize;
  final FontWeight fontWeight;
  const Buttons({
    Key? key,
    required this.color,
    required this.fontSize,
    required this.textId,
    required this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Row(
      // mainAxisSize: MainAxisSize.min,
      children: [
        AppButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          text: "Отмена",
          color: AppColors.darkGrey,
        ),
        const SizedBox(
          width: 24,
        ),
        AppButton(
          onTap: () {
            bloc.changeFontSettings(textId, color, fontSize, fontWeight );
            Navigator.of(context).pop();
          },
          text: "Сохранить",
        ),
        const SizedBox(
          width: 16,
        ),
      ],
      mainAxisSize: MainAxisSize.min,
    );
  }
}

class ColorSelection extends StatelessWidget {
  const ColorSelection({
    Key? key,
    required this.changeColor,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(
          width: 16,
        ),
        Text(
          "Color:",
          style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
        ),
        const SizedBox(
          width: 16,
        ),
        ColorSelectionBox(changeColor: changeColor, color: Colors.white),
        const SizedBox(
          width: 16,
        ),
        ColorSelectionBox(changeColor: changeColor, color: Colors.black),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }
}

class ColorSelectionBox extends StatelessWidget {
  const ColorSelectionBox({
    Key? key,
    required this.changeColor,
    required this.color,
  }) : super(key: key);

  final ValueChanged<Color> changeColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => changeColor(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
    );
  }
}

class FontWeightSlider extends StatefulWidget {
  final ValueChanged<double> changeFontWeight;
  final double initialFontWeight;

  const FontWeightSlider({
    Key? key,
    required this.changeFontWeight,
    required this.initialFontWeight,
  }) : super(key: key);

  @override
  _FontWeightSliderState createState() => _FontWeightSliderState();
}

class _FontWeightSliderState extends State<FontWeightSlider> {
  late double fontWeight;
  @override
  void initState() {
    super.initState();
    fontWeight = widget.initialFontWeight;
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Font Weight:",
            style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              value: fontWeight,
              min: FontWeight.w100.index.toDouble(),
              max:  FontWeight.w900.index.toDouble(),
              divisions: 8,
              //label: fontsize.round().toString(),
              onChanged: (double value) {
                setState(() {
                   fontWeight = value;
                   widget.changeFontWeight(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

class FontSizeSlider extends StatefulWidget {
  final ValueChanged<double> changeFontSize;
  final double initialFontSize;

  const FontSizeSlider({
    Key? key,
    required this.changeFontSize,
    required this.initialFontSize,
  }) : super(key: key);

  @override
  State<FontSizeSlider> createState() => _FontSizeSliderState();
}

class _FontSizeSliderState extends State<FontSizeSlider> {
  late double fontsize;
  @override
  void initState() {
    super.initState();
    fontsize = widget.initialFontSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Size:",
            style: TextStyle(fontSize: 20, color: AppColors.darkGrey),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.fuchsia,
              inactiveTrackColor: AppColors.fuchsia38,
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              thumbColor: AppColors.fuchsia,
              inactiveTickMarkColor: AppColors.fuchsia,
              valueIndicatorColor: AppColors.fuchsia,
            ),
            child: Slider(
              value: fontsize,
              min: 16,
              max: 32,
              divisions: 10,
              label: fontsize.round().toString(),
              onChanged: (double value) {
                setState(() {
                  fontsize = value;
                  widget.changeFontSize(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
