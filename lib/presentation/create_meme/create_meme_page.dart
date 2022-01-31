import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/create_meme_bloc.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_offset.dart';
import 'package:memogenerator/presentation/create_meme/models/meme_text_with_selection.dart';
import 'package:memogenerator/presentation/widgets/app_button.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'font_settings_bottom_sheet.dart';
import 'meme_text_on_canvas.dart';
import 'models/meme_text.dart';

class CreateMemePage extends StatefulWidget {
  final String? id;
  final String? selectedMemePath;

  const CreateMemePage({Key? key, this.id, this.selectedMemePath})
      : super(key: key);

  @override
  _CreateMemePageState createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc(
      id: widget.id,
      selectedMemePath: widget.selectedMemePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: WillPopScope(
        onWillPop: () async {
          final goBack = await showConfirmationExitDialod(context);
          return goBack ?? false;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            backgroundColor: AppColors.lemon,
            foregroundColor: AppColors.darkGrey,
            title: Text(
              "Создаем мем",
            ),
            bottom: EditTextBar(),
            actions: [
              GestureDetector(
                onTap: () {
                  bloc.shareMeme();
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.share,
                      color: AppColors.darkGrey,
                    )),
              ),
              GestureDetector(
                onTap: () {
                  bloc.saveMeme();
                },
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.save,
                      color: AppColors.darkGrey,
                    )),
              )
            ],
          ),
          backgroundColor: Colors.white,
          body: SafeArea(
            child: CreateMemePageContent(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<bool?> showConfirmationExitDialod(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text("Хотите выйти?"),
          content: Text("Вы потеряете несохраненные изменения "),
          actions: [
            AppButton(
              onTap: () {
                Navigator.of(context).pop(false);
              },
              text: "Отмена",
              color: AppColors.darkGrey,
            ),
            AppButton(
              onTap: () {
                Navigator.of(context).pop(true);
              },
              text: "Выйти",
            ),
          ],
        );
      },
    );
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data! : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? "";
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            final haveSelected = selectedMemeText != null;
            return TextField(
              enabled: selectedMemeText != null,
              controller: controller,
              onChanged: (text) {
                if (haveSelected) {
                  bloc.changeMemeText(selectedMemeText!.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              cursorColor: AppColors.fuchsia,
              decoration: InputDecoration(
                hintText: haveSelected ? "Ввести текст" : null,
                hintStyle: TextStyle(
                  color: AppColors.darkGrey38,
                  fontSize: 16,
                ),
                fillColor:
                    haveSelected ? AppColors.fuchsia16 : AppColors.darkGrey6,
                filled: true,
                disabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.darkGrey38, width: 1)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.fuchsia38, width: 1)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.fuchsia, width: 2)),
              ),
            );
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  @override
  _CreateMemePageContentState createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  @override
  Widget build(BuildContext context) {
   // final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Center(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: MemeCanvasWidget(),
          ),
          Container(
            height: 1,
            width: double.infinity,
            color: AppColors.darkGrey,
          ),
          Expanded(
            flex: 1,
            child: BottomList(),
          )
        ],
      ),
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: Colors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
        stream: bloc.observeMemeTextWithSelection(),
        initialData: const <MemeTextWithSelection>[],
        builder: (context, snapshot) {
          final items = snapshot.hasData
              ? snapshot.data!
              : const <MemeTextWithSelection>[];
          return ListView.separated(
            itemCount: items.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: AppButton(
                      onTap: () => bloc.addNewText(),
                      text: "Добавить текст",
                      icon: Icons.add,
                    ),
                  ),
                );
              }
              final item = items[index - 1];
              return BottomMemeText(
                item: item,
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const SizedBox.shrink();
              }
              return BottomSeparator();
            },
          );
        },
      ),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 1,
      color: AppColors.darkGrey,
    );
  }
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({Key? key, required this.item}) : super(key: key);

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        bloc.selectMemeText(item.memeText.id);
      },
      child: Container(
        height: 48,
        alignment: Alignment.centerLeft,
        color: item.selected ? AppColors.darkGrey16 : null,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                item.memeText.text,
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    context: context,
                    builder: (context) {
                      return Provider.value(
                        value: bloc,
                        child: FontSettingBottomSheet(
                          memeText: item.memeText,
                        ),
                      );
                    });
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.font_download_outlined),
              ),
            ),
            GestureDetector(
              onTap: () {
                  bloc.deleteMeme(item.memeText.id);
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.delete_forever_outlined),
              ),
            ),
            const SizedBox(
              width: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.darkGrey38,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.topCenter,
      child: AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => bloc.deselectMemeText(),
          child: StreamBuilder<ScreenshotController>(
              stream: bloc.observeScreenshotController(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                return Screenshot(
                  controller: snapshot.requireData,
                  child: Stack(
                    children: [
                      BackgroundImage(),
                      MemeTexts(),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class MemeTexts extends StatelessWidget {
  const MemeTexts({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<List<MemeTextWithOffset>>(
        initialData: const <MemeTextWithOffset>[],
        stream: bloc.observeMemeTextWithOffsets(),
        builder: (context, snapshot) {
          final memeTextWithOffsets =
              snapshot.hasData ? snapshot.data! : const <MemeTextWithOffset>[];
          return LayoutBuilder(builder: (context, constrains) {
            return Stack(
              children: memeTextWithOffsets.map((memeTextWithOffset) {
                return DraggableMemeText(
                  key: ValueKey(memeTextWithOffset.memeText.id),
                  memeTextWithOffset: memeTextWithOffset,
                  parentConstraints: constrains,
                );
              }).toList(),
            );
          });
        });
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return StreamBuilder<String?>(
        stream: bloc.observeMemePath(),
        builder: (context, snapshot) {
          final path = snapshot.hasData ? snapshot.data : null;
          if (path == null) {
            return Container(color: Colors.white);
          }
          return Image.file(File(path));
        });
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeTextWithOffset memeTextWithOffset;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeTextWithOffset,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  late double top;
  late double left;
  final double padding = 8;

  @override
  void initState() {
    super.initState();
    top = widget.memeTextWithOffset.offset?.dy ??
        widget.parentConstraints.maxHeight / 2;
    left = widget.memeTextWithOffset.offset?.dx ??
        widget.parentConstraints.maxWidth / 3;
    // TODO: implement initState
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    bloc.changeMemeTextOffset(
        widget.memeTextWithOffset.memeText.id, Offset(left, top));
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          bloc.selectMemeText(widget.memeTextWithOffset.memeText.id);
        },
        onPanUpdate: (details) {
          bloc.selectMemeText(widget.memeTextWithOffset.memeText.id);
          //print("DRAG UPDATE: ${details.delta}");
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);
            bloc.changeMemeTextOffset(
                widget.memeTextWithOffset.memeText.id, Offset(left, top));
          });
        },
        child: StreamBuilder<MemeText?>(
            stream: bloc.observeSelectedMemeText(),
            builder: (context, snapshot) {
              final selectedItem = snapshot.hasData ? snapshot.data! : null;
              var selected =
                  widget.memeTextWithOffset.memeText.id == selectedItem?.id;

              return MemeTextOnCanvas(
                padding: padding,
                selected: selected,
                parentConstraints: widget.parentConstraints,
                text: widget.memeTextWithOffset.memeText.text,
                fontSize: widget.memeTextWithOffset.memeText.fontSize,
                color: widget.memeTextWithOffset.memeText.color,
                fontWeight: widget.memeTextWithOffset.memeText.fontWeight,

              );
            }),
      ),
    );
  }

  double calculateTop(DragUpdateDetails details) {
    final rawTop = top + details.delta.dy;
    if (rawTop < 0) {
      return 0;
    }
    if (rawTop > widget.parentConstraints.maxHeight - 2 * padding - 24) {
      return widget.parentConstraints.maxHeight - 2 * padding - 24;
    }
    return rawTop;
  }

  double calculateLeft(DragUpdateDetails details) {
    final rawLeft = left + details.delta.dx;
    if (rawLeft < 0) {
      return 0;
    }
    if (rawLeft > widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }
    return rawLeft;
  }
}
