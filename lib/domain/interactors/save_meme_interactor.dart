import 'dart:io';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/models/text_with_position.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:path_provider/path_provider.dart';

class SaveMemeInteractor {
  static SaveMemeInteractor? _instance;

  factory SaveMemeInteractor.getInstance() =>
      _instance ??= SaveMemeInteractor._internal();

  SaveMemeInteractor._internal();

  Future<bool> saveMeme({
    required final String id,
    required final List<TextWithPosition> textWithPositions,
    final String? imagePath,
  }) async {
    bool savePath = false;
    //final imagePath = memePathSubject.value;
    if (imagePath == null) {
      final meme = Meme(
        id: id,
        texts: textWithPositions,
      );
      return MemesRepository.getInstance().addToMemes(meme);
    }

    final docsPath = await getApplicationDocumentsDirectory();
    print("$docsPath наш путь");
    final memePath = "${docsPath.absolute.path}${Platform.pathSeparator}memes";
    await Directory(memePath).create(recursive: true);
    final imageName = imagePath.split(Platform.pathSeparator).last;
    String newImagePath = "$memePath${Platform.pathSeparator}$imageName";
    print("полный путь $newImagePath");
    final tempFile = File(imagePath);
    //await tempFile.copy(newImagePath);
    int length = await tempFile.length();
    print(length);

    String newImagePathWithSuffix = newImagePath;
    final List<Meme> memesList = await MemesRepository.getInstance().getMemes();
    for (var meme in memesList) {
      final int lengthStorage = await File(meme.memePath!).length();
      if (meme.memePath == newImagePath && meme.memePath != null) {
        if (length == lengthStorage) {
          print("Файлы одинаковы, не сохраняем");
        } else {
          print("Файлы разные, но имеют одинаковые имена, сохраняем");
          //Добавление суффикса
          String imageNumberStringWithType = newImagePath.split("_").last;
          String imageNumberString = imageNumberStringWithType.split(".").first;
          String imageFileType = imageNumberStringWithType.split(".").last;
          int? imageNumber = int.tryParse(imageNumberString);
          if (imageNumber == null) {
            imageNumber = 1;
            newImagePathWithSuffix =
                "${newImagePath.replaceRange(newImagePath.length - imageFileType.length - 1, null, "_1")}.$imageFileType";
            await tempFile.copy(newImagePathWithSuffix);
          } else {
            imageNumber++;
            String newImageNumberString = imageNumber.toString();
            newImagePathWithSuffix =
                "${newImagePath.replaceRange(newImagePath.length - imageNumberStringWithType.length, null, newImageNumberString)}.$imageFileType";
            await tempFile.copy(newImagePathWithSuffix);
          }
        }
      } else {
        await tempFile.copy(newImagePathWithSuffix);
      }
    }

    final meme = Meme(
      id: id,
      texts: textWithPositions,
      memePath: newImagePathWithSuffix,
    );
    return MemesRepository.getInstance().addToMemes(meme);
  }
}
