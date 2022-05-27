abstract class ApiObjectProperty {
  //General Properties -- any Component can have these
  // Basic Data
  static const String id = "id";
  static const String name = "name";
  static const String className = "className";
  static const String parent = "parent";
  static const String remove = "~remove";
  static const String visible = "visible";
  static const String enabled = "enabled";
  static const String focusable = "focusable";

  // Layout Data
  static const String constraints = "constraints";
  static const String indexOf = "indexOf";
  static const String tabIndex = "tabIndex";
  static const String bounds = "bounds";
  static const String dividerPosition = "dividerPosition";
  static const String orientation = "orientation";

  // Size Data
  static const String preferredSize = "preferredSize";
  static const String minimumSize = "minimumSize";
  static const String maximumSize = "maximumSize";

  // Style Data
  static const String background = "background";
  static const String foreground = "foreground";
  static const String horizontalAlignment = "horizontalAlignment";
  static const String verticalAlignment = "verticalAlignment";
  static const String font = "font";
  static const String toolTipText = "toolTipText";

  //Parent Properties -- any Component which can have children have these
  static const String layout = "layout";
  static const String layoutData = "layoutData";

  //Screen Properties -- only the most top Panel will have these
  static const String classNameEventSourceRef = "classNameEventSourceRef";
  static const String mobileAutoClose = "mobile.autoclose";
  static const String screenTitle = "screen_title_";
  static const String screenNavigationName = "screen_navigationName_";
  static const String screenModal = "screen_modal_";
  static const String screenClassName = "screen_className_";

  //Common Properties -- these may be used by many different Components
  static const String text = "text";
  static const String borderOnMouseEntered = "borderOnMouseEntered";
  static const String borderPainted = "borderPainted";
  static const String defaultButton = "defaultButton";
  static const String horizontalTextPosition = "horizontalTextPosition";
  static const String verticalTextPosition = "verticalTextPosition";
  static const String margins = "margins";
  static const String imageTextGap = "imageTextGap";
  static const String mousePressedImage = "mousePressedImage";
  static const String mouseOverImage = "mouseOverImage";
  static const String accelerator = "accelerator";
  static const String ariaLabel = "ariaLabel";
  static const String defaultWindow = "defaultWindow";
  static const String selected = "selected";
  static const String ariaPressed = "ariaPressed";
  static const String placeholder = "placeholder";
  static const String rows = "rows";
  static const String border = "border";
  static const String editable = "editable";
  static const String deselectedValue = "deselectedValue";
  static const String selectedValue = "selectedValue";
  static const String eventTabClosed = "eventTabClosed";
  static const String eventTabMoved = "eventTabMoved";
  static const String selectedIndex = "selectedIndex";
  static const String draggable = "draggable";
  static const String tabPlacement = "tabPlacement";
  static const String preserveAspectRatio = "preserveAspectRatio";
  static const String marker = "marker";
  static const String center = "center";
  static const String zoomLevel = "zoomLevel";
  static const String pointSelectionEnabled = "pointSelectionEnabled";
  static const String pointSelectionLockedOnCenter = "pointSelectionLockedOnCenter";
  static const String markerImageColumnName = "markerImageColumnName";
  static const String longitudeColumnName = "longitudeColumnName";
  static const String latitudeColumnName = "latitudeColumnName";
  static const String groupColumnName = "groupColumnName";

  //Can occur in both request & response
  static const String clientId = "clientId";
  static const String componentId = "componentId";

  //Request Properties
  static const String deviceMode = "deviceMode";
  static const String applicationName = "applicationName";
  static const String username = "username";
  static const String password = "password";
  static const String manualClose = "manualClose";
  static const String action = "action";
  static const String label = "label";
  static const String screenWidth = "screenWidth";
  static const String screenHeight = "screenHeight";
  static const String value = "value";
  static const String values = "values";
  static const String fileId = "fileId";
  static const String libraryImages = "libraryImages";
  static const String applicationImages = "applicationImages";
  static const String contentMode = "contentMode";
  static const String index = "index";
  static const String appMode = "appMode";
  static const String newPassword = "newPassword";
  static const String identifier = "identifier";
  static const String message = "message";
  static const String createAuthKey = "createAuthKey";
  static const String loginMode = "loginMode";
  static const String filterCondition = "filterCondition";
  static const String editorComponentId = "editorComponentId";
  static const String compareType = "compareType";
  static const String operatorType = "operatorType";
  static const String not = "not";
  static const String condition = "condition";
  static const String conditions = "conditions";
  static const String fillColor = "fillColor";
  static const String tileProvider = "tileProvider";
  static const String lineColor = "fillColor";
  static const String groupDataBook = "groupDataBook";
  static const String pointsDataBook = "pointsDataBook";
  static const String authKey = "authKey";
  static const String xAxisTitle = "xAxisTitle";
  static const String yAxisTitle = "yAxisTitle";
  static const String xColumnName = "xColumnName";
  static const String yColumnNames = "yColumnNames";
  static const String title = "title";
  static const String yColumnLabels = "yColumnLabels";
  static const String xColumnLabel = "xColumnLabel";
  static const String maxValue = "maxValue";
  static const String minValue = "minValue";
  static const String maxErrorValue = "maxErrorValue";
  static const String minErrorValue = "minErrorValue";
  static const String maxWarningValue = "maxWarningValue";
  static const String minWarningValue = "minWarningValue";
  static const String gaugeStyle = "gaugeStyle";
  static const String data = "data";
  static const String columnLabel = "columnLabel";

  //Response Properties
  static const String authenticated = "authenticated";
  static const String openScreen = "openScreen";
  static const String group = "group";
  static const String image = "image";
  static const String entries = "entries";
  static const String changedComponents = "changedComponents";
  static const String update = "update";
  static const String home = "home";
  static const String columnViewTable = "columnView_table_";
  static const String columns = "columns";
  static const String version = "version";
  static const String displayName = "displayName";
  static const String userName = "userName";
  static const String eMail = "email";
  static const String mode = "mode";
  static const String profileImage = "profileImage";

  // Data Properties
  static const String dataTypeIdentifier = "dataTypeIdentifier";
  static const String width = "width";
  static const String height = "height";
  static const String readOnly = "readonly";
  static const String nullable = "nullable";
  static const String resizable = "resizable";
  static const String sortable = "sortable";
  static const String movable = "movable";
  static const String contentType = "contentType";
  static const String directCellEditor = "directCellEditor";
  static const String preferredEditorMode = "preferredEditorMode";
  static const String autoOpenPopup = "autoOpenPopup";
  static const String cellEditor = "cellEditor";
  static const String dataProvider = "dataProvider";
  static const String records = "records";
  static const String to = "to";
  static const String from = "from";
  static const String columnNames = "columnNames";
  static const String columnName = "columnName";
  static const String dataRow = "dataRow";
  static const String isAllFetched = "isAllFetched";
  static const String selectedRow = "selectedRow";
  static const String numberFormat = "numberFormat";
  static const String fromRow = "fromRow";
  static const String rowCount = "rowCount";
  static const String includeMetaData = "includeMetaData";
  static const String reload = "reload";
  static const String changedColumnNames = "changedColumnNames";
  static const String changedValues = "changedValues";
  static const String deleteEnabled = "deleteEnabled";
  static const String updateEnabled = "updateEnabled";
  static const String insertEnabled = "insertEnabled";
  static const String filter = "filter";
  static const String fetch = "fetch";
  static const String onlySelected = "onlySelected";

  // Cell editor overrides
  static const String cellEditorEditable = "cellEditor_editable_";
  static const String cellEditorFont = "cellEditor_font_";
  static const String cellEditorHorizontalAlignment = "cellEditor_horizontalAlignment_";
  static const String cellEditorVerticalAlignment = "cellEditor_verticalAlignment_";
  static const String cellEditorBackground = "cellEditor_background_";
  static const String cellEditorForeground = "cellEditor_foreground_";
  static const String cellEditorPlaceholder = "cellEditor_placeholder_";

  // Choice cell editor
  static const String allowedValues = "allowedValues";
  static const String defaultImageName = "defaultImageName";
  static const String imageNames = "imageNames";

  // Date cell editor
  static const String dateFormat = "dateFormat";
  static const String isDateEditor = "isDateEditor";
  static const String isTimeEditor = "isTimeEditor";
  static const String isHourEditor = "isHourEditor";
  static const String isMinuteEditor = "isMinuteEditor";
  static const String isSecondEditor = "isSecondEditor";
  static const String isAmPmEditor = "isAmPmEditor";

  // Linked cell editor
  static const String columnView = "columnView";
  static const String rowDefinitions = "rowDefinitions";
  static const String columnCount = "columnCount";
  static const String additionalCondition = "additionalCondition";
  static const String displayReferencedColumnName = "displayReferencedColumnName";
  static const String displayConcatMask = "displayConcatMask";
  static const String linkReference = "linkReference";
  static const String referencedColumnNames = "referencedColumnNames";
  static const String referencedDataBook = "referencedDataBook";
  static const String popupSize = "popupSize";
  static const String searchColumnMapping = "searchColumnMapping";
  static const String searchTextAnywhere = "searchTextAnywhere";
  static const String searchInAllTableColumns = "searchInAllTableColumns";
  static const String sortByColumnName = "sortByColumnName";
  static const String tableHeaderVisible = "tableHeaderVisible";
  static const String validationEnabled = "validationEnabled";
  static const String doNotClearColumnNames = "doNotClearColumnNames";
  static const String clearColumns = "clearColumns";
  static const String additionalClearColumns = "additionalClearColumns";

  // Column definition
  static const String length = "length";
  static const String scale = "scale";
  static const String precision = "precision";
  static const String signed = "signed";
  static const String autoTrim = "autoTrim";
  static const String encoding = "encoding";
  static const String fractionalSecondsPrecision = "fractionalSecondsPrecision";

  static const String dataBook = "dataBook";
  static const String columnLabels = "columnLabels";
  static const String autoResize = "autoResize";
  static const String showFocusRect = "showFocusRect";
  static const String showHorizontalLines = "showHorizontalLines";
  static const String showSelection = "showSelection";
  static const String showVerticalLines = "showVerticalLines";
  static const String sortOnHeaderEnabled = "sortOnHeaderEnabled";
  static const String wordWrapEnabled = "wordWrapEnabled";
}
