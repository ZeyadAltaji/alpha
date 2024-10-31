import 'dart:convert';
import 'dart:io';
import 'package:alpha/GeneralFiles/Dialogs.dart';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:badges/badges.dart' as badges ;
import 'package:flutter/material.dart';
import 'package:alpha/GeneralFiles/Trans.dart' as trans;
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

class Upload extends StatefulWidget {
  final String? initialpath;
  final void Function(String? base64Image, String? path) onSelectFile;
  final void Function()? onRemoveFile;

  Upload({
    Key? key,
    required this.onSelectFile,
    this.onRemoveFile,
    this.initialpath,
  }) : super(key: key);

  File selectedImage = File('');
  bool image = false;
  bool initialLoaded = false;

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  void _selectAttachment(bool s) async {
    ImagePicker _picker = ImagePicker();
    try {
      final pickedFile = await _picker.pickImage(
        source: s ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 70,
      );
      File sFILE;
      sFILE = File(pickedFile!.path);
      var decodedImage = await decodeImageFromList(sFILE.readAsBytesSync());
      double ww = (width - 80) / decodedImage.width;
      attchmentWidth = decodedImage.width * ww;
      attchmentHeight = decodedImage.height * ww;

      if (sFILE.lengthSync() > maxSize) {
        toast(
            '${arEn('لا يمكن اختيار ملف بهذا الحجم', 'A file of this size cannot be selected')}');
        return;
      } else {
        setState(() {
          widget.selectedImage = sFILE;
          List<int> imageBytes = widget.selectedImage.readAsBytesSync();
          // path = pickedFile.path;
          // base64Image = base64Encode(imageBytes);
          widget.onSelectFile(
            base64Encode(imageBytes),
            // file: sFILE,
            pickedFile.path,
          );
          widget.image = true;
        });
      }
    } catch (e) {
      widget.image = false;
      //  _pickImageError = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.initialLoaded && widget.initialpath != '') {
      widget.selectedImage = File(widget.initialpath!);

      // var decodedImage = await decodeImageFromList(sFILE.readAsBytesSync());
      // double ww = width / decodedImage.width;
      // widget.w = decodedImage.width * ww;
      // widget.h = decodedImage.height * ww;

      widget.initialLoaded = true;
      widget.image = true;
    }
    return Directionality(
      textDirection: trans.direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !widget.image
              ? Row(
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all<Color>(
                              darkTheme ? Colors.grey : Colors.black)),
                      onPressed: () {
                        dataSource(
                          onDone: (bool v) {
                            _selectAttachment(v);
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(LineIcons.paperclip),
                          Text(' ${arEn('اضافة ملف', 'Attach file')}'),
                        ],
                      ),
                    )
                  ],
                )
              : SizedBox(),
          widget.image
              ? badges.Badge(
                  // showBadge: false,
                  badgeContent: Container(
                    width: 25.0,
                    height: 25.0,
                    child: FloatingActionButton(
                      onPressed: () {
                        new Dialogs(context, (bool c) {
                          if (!c) return;
                          widget.image = false;
                          setState(() {});
                          widget.onRemoveFile!();
                        },
                                '${arEn('ازالة', 'Remove')}',
                                '${arEn('هل تريد ازالة الملف ؟', 'Do you want to remove the file?')}',
                                false)
                            .yesOrNo();
                      },
                      child: Icon(Icons.clear),
                      hoverElevation: 0,
                      isExtended: false,
                      backgroundColor: Colors.red,
                    ),
                  ),
                   badgeStyle: badges.BadgeStyle(
                    padding: EdgeInsets.zero,
                  ),
                  position: badges.BadgePosition.topEnd(top: 5, end: 5),
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Image(
                        image: (widget.image == true)
                            ? Image.file(widget.selectedImage).image
                            : AssetImage('images/profile.png'),
                        // width: double.infinity,
                        height: attchmentHeight,
                        fit: BoxFit.contain,
                        width: attchmentWidth,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
