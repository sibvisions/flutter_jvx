/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:pro_image_editor/pro_image_editor.dart' as editor;

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/layout/alignments.dart';
import '../../service/config/i_config_service.dart';
import '../../util/icon_util.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlIconWidget<T extends FlIconModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final Function(dynamic, [String?])? onEndEditing;

  final VoidCallback? onPress;

  final Widget? image;

  final WidgetWrapper? wrapper;

  final Function(Size, bool)? imageStreamListener;

  final bool inTable;

  /// whether to show image as avatar
  final bool showAsAvatar;

  /// whether to use full-size for avatar calculation instead of image size
  final bool showAvatarFullSize;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({
    super.key,
    required super.model,
    this.image,
    this.imageStreamListener,
    this.onPress,
    this.inTable = false,
    this.onEndEditing,
    this.wrapper,
    this.showAsAvatar = false,
    this.showAvatarFullSize = false
  });

  @override
  Widget build(BuildContext context) {
    Widget? child;

    Size? imageSize;

    if (image != null) {
      if (wrapper != null) {
        child = wrapper!(image, null);
      }
      else {
        child = image;
      }
    }
    else{
      if (!showAvatarFullSize && !model.showAvatarFullSize) {
        listener(Size size, bool b) {
          imageSize = size;

          imageStreamListener?.call(size, b);
        }

        child = _loadImage(listener);
      }
      else {
        child = _loadImage(imageStreamListener);
      }
    }

    if (model.toolTipText != null) {
      child = Tooltip(message: model.toolTipText!, child: child);
    }

    child = DecoratedBox(
      decoration: BoxDecoration(color: model.background),
      child: child,
    );

    if (model.showAsAvatar || showAsAvatar) {
      child = ClipPath(clipper: CircleClipper(areaSize: imageSize), child: child);
    }

    if (onPress != null) {
      return GestureDetector(
        onTap: model.isEnabled ? onPress : null,
        child: child
      );
    } else {

      return GestureDetector(
        onDoubleTap: model.isEditorEnabled &&
                     image == null && !IconUtil.isFontIcon(model.image) && model.hasImage() && !model.defaultImage &&
                     !model.isReadOnly && model.isEditable && onEndEditing != null ?
          () async {
            await _openEditor(context);
          }
          :
          null,
        onTap: !model.isEnlargeDisabled &&
               image == null && !IconUtil.isFontIcon(model.image) && model.hasImage() && !model.defaultImage
            ? () => showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: PhotoView(
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        initialScale: PhotoViewComputedScale.contained * 0.75,
                        minScale: PhotoViewComputedScale.contained * 0.1,
                        imageProvider: ImageLoader.getImageProvider(model.image!),
                      ),
                    );
                  },
                )
            : null,
        child: child
      );
    }
  }

  BoxFit? getBoxFit() {
    if (inTable) {
      return BoxFit.scaleDown;
    }

    if (model.preserveAspectRatio) {
      if (model.horizontalAlignment == HorizontalAlignment.STRETCH &&
          model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.contain;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
        return BoxFit.fitWidth;
      } else if (model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.fitHeight;
      }
    } else {
      if (model.horizontalAlignment == HorizontalAlignment.STRETCH &&
          model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.fill;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH ||
          model.verticalAlignment == VerticalAlignment.STRETCH) {
        return null;
      }
    }
    return BoxFit.none;
  }

  Widget? _loadImage(Function(Size, bool)? listener) {
    if (!model.hasImage()) {
      return null;
    }

    BoxFit? boxFit = getBoxFit();

    if (boxFit == null) {
      return LayoutBuilder(builder: (context, constraints) {
        double width = model.originalSize.width;
        double height = model.originalSize.height;

        if (boxFit == null) {
          if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
            width = constraints.maxWidth;
          }
          if (model.verticalAlignment == VerticalAlignment.STRETCH) {
            height = constraints.maxHeight;
          }
        }

        return Align(
          alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
          child: SizedBox(
            width: width,
            height: height,
            child: ImageLoader.loadImage(
              model.image!,
              imageStreamListener: listener,
              color: model.isEnabled ? model.foreground : JVxColors.COMPONENT_DISABLED,
              fit: BoxFit.fill,
              wrapper: wrapper
            ),
          ),
        );
      });
    } else {
      return ImageLoader.loadImage(
        model.image!,
        imageStreamListener: listener,
        color: model.isEnabled ? model.foreground : JVxColors.COMPONENT_DISABLED,
        fit: boxFit,
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
        wrapper: wrapper
      );
    }
  }

  Future<Uint8List?> _openEditor(BuildContext context) async {
    ImageProvider<Object>? imageProv = ImageLoader.getImageProvider(model.image!);

    if (imageProv is! MemoryImage) {
      return null;
    }

    final Uint8List? editedBytes = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (context) => editor.ProImageEditor.memory(
          imageProv.bytes,
          configs: editor.ProImageEditorConfigs(i18n: _editorTranslation()),
          callbacks: editor.ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {
              Navigator.pop(context, bytes);
            },
          ),
        ),
      ),
    );

    if (editedBytes != null) {
      onEndEditing!(editedBytes, "navigation-none");
    }

    return editedBytes;
  }

  editor.I18n _editorTranslation() {
    return editor.I18n(
      layerInteraction: editor.I18nLayerInteraction(
        remove: FlutterUI.translate("Remove"),
        edit: FlutterUI.translate("Edit"),
        rotateScale: FlutterUI.translate("Rotate and Scale"),
      ),
      paintEditor: editor.I18nPaintEditor(
        moveAndZoom: FlutterUI.translate("Zoom"),
        bottomNavigationBarText: FlutterUI.translate("Paint"),
        freestyle: FlutterUI.translate("Freestyle"),
        freestyleArrowStart: FlutterUI.translate("Freestyle arrow start"),
        freestyleArrowEnd: FlutterUI.translate("Freestyle arrow end"),
        freestyleArrowStartEnd: FlutterUI.translate("Freestyle arrow start-end"),
        arrow: FlutterUI.translate("Arrow"),
        line: FlutterUI.translate("Line"),
        rectangle: FlutterUI.translate("Rectangle"),
        circle: FlutterUI.translate("Circle"),
        dashLine: FlutterUI.translate("Dash line"),
        dashDotLine: FlutterUI.translate("Dash-dot line"),
        hexagon: FlutterUI.translate("Hexagon"),
        polygon: FlutterUI.translate("Polygon"),
        blur: FlutterUI.translate("Blur"),
        pixelate: FlutterUI.translate("Pixelate"),
        custom1: FlutterUI.translate("Custom 1"),
        custom2: FlutterUI.translate("Custom 2"),
        custom3: FlutterUI.translate("Custom 3"),
        lineWidth: FlutterUI.translate("Line width"),
        eraser: FlutterUI.translate("Eraser"),
        toggleFill: FlutterUI.translate("Toggle fill"),
        changeOpacity: FlutterUI.translate("Change opacity"),
        undo: FlutterUI.translate("Undo"),
        redo: FlutterUI.translate("Redo"),
        done: FlutterUI.translate("Done"),
        back: FlutterUI.translate("Back"),
        smallScreenMoreTooltip: FlutterUI.translate("More"),
        opacity: FlutterUI.translate("Opacity"),
        color: FlutterUI.translate("Color"),
        strokeWidth: FlutterUI.translate("Stroke Width"),
        fill: FlutterUI.translate("Fill"),
        cancel: FlutterUI.translate("Cancel"),
      ),
      textEditor: editor.I18nTextEditor(
        inputHintText: FlutterUI.translate("Enter text"),
        bottomNavigationBarText: FlutterUI.translate("Text"),
        back: FlutterUI.translate("Back"),
        done: FlutterUI.translate("Done"),
        textAlign: FlutterUI.translate("Align text"),
        fontScale: FlutterUI.translate("Font scale"),
        backgroundMode: FlutterUI.translate("Background mode"),
        smallScreenMoreTooltip: FlutterUI.translate("More"),
      ),
      cropRotateEditor: editor.I18nCropRotateEditor(
        bottomNavigationBarText: FlutterUI.translate("Crop/ Rotate"),
        rotate: FlutterUI.translate("Rotate"),
        flip: FlutterUI.translate("Flip"),
        tilt: FlutterUI.translate("Tilt"),
        tiltRotate: FlutterUI.translate("Rotate"),
        tiltHorizontal: FlutterUI.translate("Horizontal"),
        tiltVertical: FlutterUI.translate("Vertical"),
        ratio: FlutterUI.translate("Ratio"),
        back: FlutterUI.translate("Back"),
        done: FlutterUI.translate("Done"),
        cancel: FlutterUI.translate("Cancel"),
        undo: FlutterUI.translate("Undo"),
        redo: FlutterUI.translate("Redo"),
        smallScreenMoreTooltip: FlutterUI.translate("More"),
        reset: FlutterUI.translate("Reset"),
      ),
      tuneEditor: editor.I18nTuneEditor(
        bottomNavigationBarText: FlutterUI.translate("Tune"),
        back: FlutterUI.translate("Back"),
        done: FlutterUI.translate("Done"),
        brightness: FlutterUI.translate("Brightness"),
        contrast: FlutterUI.translate("Contrast"),
        saturation: FlutterUI.translate("Saturation"),
        exposure: FlutterUI.translate("Exposure"),
        hue: FlutterUI.translate("Hue"),
        temperature: FlutterUI.translate("Temperature"),
        sharpness: FlutterUI.translate("Sharpness"),
        fade: FlutterUI.translate("Fade"),
        luminance: FlutterUI.translate("Luminance"),
        undo: FlutterUI.translate("Undo"),
        redo: FlutterUI.translate("Redo"),        
      ),
      filterEditor: editor.I18nFilterEditor(
        bottomNavigationBarText: FlutterUI.translate("Filter"),
        back: FlutterUI.translate("Back"),
        done: FlutterUI.translate("Done"),
        filters: editor.I18nFilters(
          none: FlutterUI.translate("No Filter"),
          addictiveBlue: FlutterUI.translate("AddictiveBlue"),
          addictiveRed: FlutterUI.translate("AddictiveRed"),
          aden: FlutterUI.translate("Aden"),
          amaro: FlutterUI.translate("Amaro"),
          ashby: FlutterUI.translate("Ashby"),
          brannan: FlutterUI.translate("Brannan"),
          brooklyn: FlutterUI.translate("Brooklyn"),
          charmes: FlutterUI.translate("Charmes"),
          clarendon: FlutterUI.translate("Clarendon"),
          crema: FlutterUI.translate("Crema"),
          dogpatch: FlutterUI.translate("Dogpatch"),
          earlybird: FlutterUI.translate("Earlybird"),
          f1977: FlutterUI.translate("1977"),
          gingham: FlutterUI.translate("Gingham"),
          ginza: FlutterUI.translate("Ginza"),
          hefe: FlutterUI.translate("Hefe"),
          helena: FlutterUI.translate("Helena"),
          hudson: FlutterUI.translate("Hudson"),
          inkwell: FlutterUI.translate("Inkwell"),
          juno: FlutterUI.translate("Juno"),
          kelvin: FlutterUI.translate("Kelvin"),
          lark: FlutterUI.translate("Lark"),
          loFi: FlutterUI.translate("Lo-Fi"),
          ludwig: FlutterUI.translate("Ludwig"),
          maven: FlutterUI.translate("Maven"),
          mayfair: FlutterUI.translate("Mayfair"),
          moon: FlutterUI.translate("Moon"),
          nashville: FlutterUI.translate("Nashville"),
          perpetua: FlutterUI.translate("Perpetua"),
          reyes: FlutterUI.translate("Reyes"),
          rise: FlutterUI.translate("Rise"),
          sierra: FlutterUI.translate("Sierra"),
          skyline: FlutterUI.translate("Skyline"),
          slumber: FlutterUI.translate("Slumber"),
          stinson: FlutterUI.translate("Stinson"),
          sutro: FlutterUI.translate("Sutro"),
          toaster: FlutterUI.translate("Toaster"),
          valencia: FlutterUI.translate("Valencia"),
          vesper: FlutterUI.translate("Vesper"),
          walden: FlutterUI.translate("Walden"),
          willow: FlutterUI.translate("Willow"),
          xProII: FlutterUI.translate("X-Pro II"),
        )
      ),
      blurEditor: editor.I18nBlurEditor(
        bottomNavigationBarText: FlutterUI.translate("Blur"),
        back: FlutterUI.translate("Back"),
        done: FlutterUI.translate("Done"),        
      ),
      emojiEditor: editor.I18nEmojiEditor(
        bottomNavigationBarText: FlutterUI.translate("Emoji"),
        search: FlutterUI.translate("Search"),
        categoryRecent: FlutterUI.translate("Recent"),
        categorySmileys: FlutterUI.translate("Smileys & People"),
        categoryAnimals: FlutterUI.translate("Animals & Nature"),
        categoryFood: FlutterUI.translate("Food & Drink"),
        categoryActivities: FlutterUI.translate("Activities"),
        categoryTravel: FlutterUI.translate("Travel & Places"),
        categoryObjects: FlutterUI.translate("Objects"),
        categorySymbols: FlutterUI.translate("Symbols"),
        categoryFlags: FlutterUI.translate("Flags"),
        locale: Locale(IConfigService().getLanguage())
      ),
      stickerEditor: editor.I18nStickerEditor(
        bottomNavigationBarText: FlutterUI.translate("Stickers"),
      ),
      audioEditor: editor.I18nAudioEditor(
        bottomNavigationBarText: FlutterUI.translate("Audio"),
        done: FlutterUI.translate("Done"),
        back: FlutterUI.translate("Back"),
        balanceLabelOriginal: FlutterUI.translate("Original"),
        balanceLabelOverlay: FlutterUI.translate("Overlay"),
        balanceLabelBalanced: FlutterUI.translate("Balanced"),
        confirmChanges: FlutterUI.translate("Confirm"),
        editTrack: FlutterUI.translate("Edit Track"),        
      ),
      clipsEditor: editor.I18nClipsEditor(
        bottomNavigationBarText: FlutterUI.translate("Clips"),
        done: FlutterUI.translate("Done"),
        back: FlutterUI.translate("Back"),
        remove: FlutterUI.translate("Remove"),
        addVideoClip: FlutterUI.translate("Add Video-Clip"),
        processingClips: FlutterUI.translate("Processing clips..."),
      ),
      various: editor.I18nVarious(
        loadingDialogMsg: FlutterUI.translate("Please wait..."),
        closeEditorWarningTitle: FlutterUI.translate("Close Image Editor?"),
        closeEditorWarningMessage: FlutterUI.translate("Are you sure you want to close the Image Editor? Your changes will not be saved."),
        closeEditorWarningConfirmBtn: FlutterUI.translate("OK"),
        closeEditorWarningCancelBtn: FlutterUI.translate("Cancel"),        
      ),
      importStateHistoryMsg: FlutterUI.translate("Initialize Editor"),
      cancel: FlutterUI.translate("Cancel"),
      undo: FlutterUI.translate("Undo"),
      redo: FlutterUI.translate("Redo"),
      done: FlutterUI.translate("Done"),
      remove: FlutterUI.translate("Remove"),
      doneLoadingMsg: FlutterUI.translate("Changes are being applied")
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  Size? areaSize;

  CircleClipper({
    this.areaSize
  });

  @override
  Path getClip(Size size) {
    Size usedSize = areaSize ?? size;

    final radius = (usedSize.width < usedSize.height ? usedSize.width : usedSize.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    return Path()
      ..addOval(
        Rect.fromCircle(center: center, radius: radius),
      );
  }

  @override
  bool shouldReclip(covariant CircleClipper oldClipper) => areaSize != oldClipper.areaSize;
}
