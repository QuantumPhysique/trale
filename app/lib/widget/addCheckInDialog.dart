import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:trale/core/db/app_database.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/l10n-gen/app_localizations.dart';

/// Simple check-in dialog allowing weight, height, notes (thoughts),
/// up to 3 camera-only photos, per-photo NSFW toggle, and an emotional color.
Future<bool> showAddCheckInDialog({
  required BuildContext context,
  required double initialWeight,
  required DateTime initialDate,
}) async {
  final db = AppDatabase();

  double weight = initialWeight;
  double? height;
  DateTime date = initialDate;
  final TextEditingController notesController = TextEditingController();

  final List<_PhotoItem> photos = <_PhotoItem>[];
  Color? pickedColor;

  Future<void> takePhoto() async {
    if (photos.length >= 3) return;
    final XFile? file = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (file == null) return;
    // Move to app directory: keep as-is for now and store path
    photos.add(_PhotoItem(path: file.path));
  }

  Widget buildPhotos() {
    return Wrap(
      spacing: 8,
      children: photos
          .map(
            (p) => Stack(
              alignment: Alignment.topRight,
              children: [
                Image.file(
                  File(p.path),
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        p.nsfw
                            ? Icons.warning_amber_rounded
                            : Icons.lock_person,
                        color: p.nsfw ? Colors.amber : Colors.white,
                      ),
                      onPressed: () {
                        p.nsfw = !p.nsfw;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () => photos.remove(p),
                    ),
                  ],
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  final bool result =
      await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(AppLocalizations.of(context)!.addWeight),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: weight.toStringAsFixed(1),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.weight,
                              ),
                              onChanged: (v) =>
                                  weight = double.tryParse(v) ?? weight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.height,
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onChanged: (v) => height = double.tryParse(v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.notes,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: photos.length >= 3
                                ? null
                                : () async {
                                    await takePhoto();
                                    setState(() {});
                                  },
                            icon: const Icon(Icons.camera_alt),
                            label: Text(
                              AppLocalizations.of(context)!.takePhoto,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final Color selected = pickedColor ?? Colors.blue;
                              await showDialog<void>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    title: Text(
                                      AppLocalizations.of(ctx)!.selectColor,
                                    ),
                                    content: SingleChildScrollView(
                                      child: BlockPicker(
                                        pickerColor: selected,
                                        onColorChanged: (c) {
                                          pickedColor = c;
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: Text(
                                          AppLocalizations.of(ctx)!.close,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.palette),
                            label: Text(
                              AppLocalizations.of(context)!.pickColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (photos.isNotEmpty) buildPhotos(),
                      if (pickedColor != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                color: pickedColor,
                              ),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.color),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(AppLocalizations.of(context)!.abort),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save check-in and related records
                      final dateStr =
                          "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                      await db.insertCheckIn(
                        CheckInsCompanion.insert(
                          date: dateStr,
                          weight: Value(weight),
                          height: Value(height),
                          notes: Value(
                            notesController.text.isEmpty
                                ? null
                                : notesController.text,
                          ),
                        ),
                      );

                      final nowTs =
                          DateTime.now().millisecondsSinceEpoch ~/ 1000;
                      for (final p in photos) {
                        await db.insertPhoto(
                          dateStr,
                          p.path,
                          nowTs,
                          fw: p.nsfw,
                        );
                      }

                      if (pickedColor != null) {
                        final colorInt =
                            (pickedColor!.red << 16) |
                            (pickedColor!.green << 8) |
                            pickedColor!.blue;
                        await db.insertColor(
                          dateStr,
                          nowTs,
                          colorInt,
                          message: notesController.text.isEmpty
                              ? null
                              : notesController.text,
                        );
                      }

                      Navigator.pop(context, true);
                    },
                    child: Text(AppLocalizations.of(context)!.save),
                  ),
                ],
              );
            },
          );
        },
      ) ??
      false;

  return result;
}

class _PhotoItem {
  _PhotoItem({required this.path, this.nsfw = false});

  String path;
  bool nsfw;
}
