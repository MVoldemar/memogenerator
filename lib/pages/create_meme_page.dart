import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateMemePage extends StatefulWidget {
  @override
  _CreateMemePageState createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc;
  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkGrey,
          title: Text(
            "Создаем мем",
          ),
          bottom: EditTextBar(),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({Key? key}) : super(key: key);

  @override
  _EditTextBarState createState() => _EditTextBarState();

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
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
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
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<MemeText>>(
                  stream: bloc.observeMemeTexts(),
                  initialData: const <MemeText>[],
                  builder: (context, snapshot) {
                    final items =
                        snapshot.hasData ? snapshot.data! : const <MemeText>[];
                    return ListView.separated(
                      itemCount: items.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return const AddNewMemeTextButton();
                        }
                        final item = items[index - 1];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16,),
                          height: 48,
                          alignment: Alignment.centerLeft,
                          child: Text(item.text, style: TextStyle(color: AppColors.darkGrey, fontSize: 16,),),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        if(index == 0) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          margin: const EdgeInsets.only(left: 16),
                          height: 1,
                          color: AppColors.darkGrey,
                        );
                      },
                    );
                  }),
            ),
          )
        ],
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
          child: Container(
            color: Colors.white,
            child: StreamBuilder<List<MemeText>>(
                initialData: const <MemeText>[],
                stream: bloc.observeMemeTexts(),
                builder: (context, snapshot) {
                  final memeTexts =
                      snapshot.hasData ? snapshot.data! : const <MemeText>[];
                  return LayoutBuilder(builder: (context, constrains) {
                    return Stack(
                      children: memeTexts.map((memeText) {
                        return DraggableMemeText(
                          memeText: memeText,
                          parentConstraints: constrains,
                        );
                      }).toList(),
                    );
                  });
                }),
          ),
        ),
      ),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    Key? key,
    required this.memeText,
    required this.parentConstraints,
  }) : super(key: key);

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  double top = 0;
  double left = 0;
  final double padding = 8;
  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          bloc.selectMemeText(widget.memeText.id);
        },
        onPanUpdate: (details) {
          bloc.selectMemeText(widget.memeText.id);
          print("DRAG UPDATE: ${details.delta}");
          setState(() {
            left = calculateLeft(details);
            top = calculateTop(details);
          });
        },
        child: StreamBuilder<MemeText?>(
            stream: bloc.observeSelectedMemeText(),
            builder: (context, snapshot) {
              final MemeText? selectedMemeText =
                  snapshot.hasData ? snapshot.data! : null;
              var selected = selectedMemeText?.id == widget.memeText.id;

              return Container(
                decoration: selected
                    ? BoxDecoration(
                        color: AppColors.darkGrey16,
                        borderRadius: BorderRadius.zero,
                        border: Border.all(
                          color: AppColors.fuchsia,
                          width: 1,
                        ),
                      )
                    : BoxDecoration(
                        border: Border.all(
                        color: Colors.transparent,
                        width: 1,
                      )),
                constraints: BoxConstraints(
                  maxWidth: widget.parentConstraints.maxWidth,
                  maxHeight: widget.parentConstraints.maxHeight,
                ),
                padding: EdgeInsets.all(padding),
                child: Text(
                  widget.memeText.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 24),
                ),
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

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => bloc.addNewText(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: AppColors.fuchsia),
              const SizedBox(
                width: 8,
              ),
              Text(
                "Добавить текст".toUpperCase(),
                style: TextStyle(
                  color: AppColors.fuchsia,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
