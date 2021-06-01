import '../../../../../flutterclient.dart';
import '../layout_model.dart';

class FormLayoutModel extends LayoutModel<String> {
  bool valid = false;

  int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;

  int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  Map<String, CoFormLayoutAnchor> defaultAnchors =
      <String, CoFormLayoutAnchor>{};

  Map<String, CoFormLayoutAnchor> anchors = <String, CoFormLayoutAnchor>{};

  FormLayoutModel() {
    init();
  }

  FormLayoutModel.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    init();
    updateLayoutString(layoutString);
    updateLayoutData(layoutData);
    super.container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    parseFromString(layoutString);

    List<String> parameter = layoutString.split(',');

    horizontalAlignment = int.parse(parameter[7]);
    verticalAlignment = int.parse(parameter[8]);

    super.updateLayoutString(layoutString);
  }

  @override
  void updateLayoutData(String layoutData) {
    anchors = Map<String, CoFormLayoutAnchor>.from(defaultAnchors);

    List<String> anc = layoutData.split(';');

    Map<int, String> mappedAnc = anc.asMap();

    mappedAnc.forEach((index, a) {
      addAnchorFromString(a);
    });

    mappedAnc.forEach((index, a) {
      updateRelatedAnchorFromString(a);
    });

    super.updateLayoutData(layoutData);
  }

  void addAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(',');

    if (values.length < 4) {
      throw new ArgumentError(
          "CoFormLayout: The anchor data parsed from json is less then 4 items! AnchorData: " +
              pAnchor);
    } else if (values.length < 5) {
      print(
          "CoFormLayout: The anchor data parsed from json is less then 5 items! AnchorData: " +
              pAnchor);
    }

    late CoFormLayoutAnchor anchor;

    if (anchors.containsKey(values[0])) {
      anchor = anchors[values[0]]!;
    } else {
      int orientation = CoFormLayoutAnchor.VERTICAL;

      if (values[0].startsWith('h') ||
          values[0].startsWith('l') ||
          values[0].startsWith('r')) {
        orientation = CoFormLayoutAnchor.HORIZONTAL;
      }

      anchor = CoFormLayoutAnchor(this, orientation, values[0]);
    }

    if (values[3] == 'a') {
      if (values.length > 4 && values[4].length > 0) {
        anchor.position = int.parse(values[4]);
      }
      anchor.autoSize = true;
    } else {
      anchor.position = int.parse(values[3]);
    }

    if (values[1] != "-" && anchors.containsKey(values[1])) {
      anchor.relatedAnchor = anchors[values[1]];
    }

    anchors.putIfAbsent(values[0], () => anchor);
  }

  void updateRelatedAnchorFromString(String pAnchor) {
    List<String> values = pAnchor.split(",");

    CoFormLayoutAnchor anchor = anchors[values[0]]!;
    if (values[1] != "-") {
      if (anchors.containsKey(values[1])) {
        anchor.relatedAnchor = anchors[values[1]];
        anchors.putIfAbsent(values[0], () => anchor);
      } else {
        throw new ArgumentError("CoFormLayout: Related anchor (Name: '" +
            values[1] +
            "') not found!");
      }
    }
  }

  void init() {
    verticalGap = 5;
    horizontalGap = 5;
    addDefaultAnchors();
  }

  addDefaultAnchors() {
    defaultAnchors.putIfAbsent("l",
        () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.HORIZONTAL, "l"));
    defaultAnchors.putIfAbsent("r",
        () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.HORIZONTAL, "r"));
    defaultAnchors.putIfAbsent(
        "t", () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.VERTICAL, "t"));
    defaultAnchors.putIfAbsent(
        "b", () => CoFormLayoutAnchor(this, CoFormLayoutAnchor.VERTICAL, "b"));
    defaultAnchors.putIfAbsent(
        "lm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["l"], 10, "lm"));
    defaultAnchors.putIfAbsent(
        "rm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["r"], -10, "rm"));
    defaultAnchors.putIfAbsent(
        "tm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["t"], 10, "tm"));
    defaultAnchors.putIfAbsent(
        "bm",
        () => CoFormLayoutAnchor.fromAnchorAndPosition(
            defaultAnchors["b"], -10, "bm"));
  }

  @override
  void addLayoutComponent(ComponentWidget pComponent, String pConstraint) {
    if (pConstraint.isEmpty) {
      throw new ArgumentError(
          "Constraint " + pConstraint.toString() + " is not allowed!");
    } else {
      layoutConstraints.putIfAbsent(pComponent, () => pConstraint);
    }

    valid = false;

    notifyListeners();
  }

  @override
  void removeLayoutComponent(ComponentWidget pComponent) {
    layoutConstraints.removeWhere((ComponentWidget comp, String constraint) =>
        comp.componentModel.componentId ==
        pComponent.componentModel.componentId);

    valid = false;

    notifyListeners();
  }

  CoFormLayoutConstraint? getConstraintsFromString(String pConstraints) {
    List<String> anc = pConstraints.split(";");

    if (anc.length == 4) {
      CoFormLayoutAnchor topAnchor = anchors[anc[0]]!;
      CoFormLayoutAnchor leftAnchor = anchors[anc[1]]!;
      CoFormLayoutAnchor bottomAnchor = anchors[anc[2]]!;
      CoFormLayoutAnchor rightAnchor = anchors[anc[3]]!;

      return CoFormLayoutConstraint(
          topAnchor, leftAnchor, bottomAnchor, rightAnchor);
    }

    return null;
  }
}
