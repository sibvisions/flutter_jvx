import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/select_record_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/select_record_view_model.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
import 'package:jvx_mobile_v3/model/open_screen/open_screen_resp.dart';
import 'package:jvx_mobile_v3/model/set_value/set_value_resp.dart';
import 'package:jvx_mobile_v3/services/data_service.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/widgets/api_subsription.dart';
import '../main.dart';
import '../model/changed_component.dart';
import 'component/jvx_component.dart';
import 'container/jvx_container.dart';
import 'jvx_component_creater.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxScreen {
  bool debug = true;
  String title = "OpenScreen";
  Key componentId;
  Map<String, JVxComponent> components = <String, JVxComponent>{};
  List<JVxData> data = <JVxData>[];
  List<JVxMetaData> metaData = <JVxMetaData>[];
  BuildContext context;
  Function buttonCallback;

  JVxScreen();

  bool isMovedComponent(JVxComponent component, ChangedComponent changedComponent) {
    if ((changedComponent.parent == null || changedComponent.parent.isEmpty) && 
        component.parentComponentId != null && component.parentComponentId.isNotEmpty) {
        
    }
  }

  void updateComponents(List<ChangedComponent> changedComponentsJson) {
    if (debug)
      print("JVxScreen updateComponents:");
    changedComponentsJson?.forEach((changedComponent) {
        if (components.containsKey(changedComponent.id)) {
          JVxComponent component = components[changedComponent.id];

          if (changedComponent.destroy) {
            if (debug)
              print("Destroy component (id:" + changedComponent.id + ")");
            _destroyComponent(component);
          } else if (changedComponent.remove) {
            if (debug)
              print("Remove component (id:" + changedComponent.id + ")");
            _removeComponent(component);
          } else {
            _moveComponent(component, changedComponent);

            if (component.state!=JVxComponentState.Added) {
              _addComponent(changedComponent);
            }
          
            component?.updateProperties(changedComponent.componentProperties);

            if (component?.parentComponentId != null) {
              JVxComponent parentComponent = components[component.parentComponentId];
              if (parentComponent!= null && parentComponent is JVxContainer) {
                parentComponent.updateComponentProperties(component.componentId, changedComponent.componentProperties);
              }
            }
          }
        } else {
          if (!changedComponent.destroy && !changedComponent.remove) {
            if (debug)
              print("Add component (id:" + changedComponent.id + 
              ",parent:" + (changedComponent.parent!=null?changedComponent.parent:"") +
                  ", className: " + (changedComponent.className!=null?changedComponent.className:"") + ")");
            this._addComponent(changedComponent);
          } else {
            print("Cannot remove or destroy component with id " + changedComponent.id + ", because its not in the components list.");
          }
        }
    });
  }

  void selectRecord(String dataProvider, int index, [bool fetch = false]) {
    DataService dataService = DataService(RestClient());

    JVxData selectData = this.getData(dataProvider);

    if (selectData != null && index < selectData.records.length) {
      dataService.selectRecord(dataProvider, selectData.columnNames, selectData.records[index], fetch, globals.clientId)
          .then((val) => getIt.get<JVxScreen>().buttonCallback(val.updatedComponents));
    }
  }

  void setValues(String dataProvider, List<dynamic> columnNames, List<dynamic> value) {
    DataService dataService = DataService(RestClient());

    dataService.setValues(dataProvider, columnNames, value, globals.clientId).then((val) {
      this.updateComponents(val.changedComponents);
      buttonCallback(val.changedComponents);
    });
  }

  JVxData getData(String dataProvider, [List<dynamic> columnNames]) {
    DataService dataService = DataService(RestClient());

    var returnData;

    print('DATAPROVDER: ' + dataProvider);

    data.forEach((d) {
      if (d.dataProvider == dataProvider)
        returnData = d;
    });

    if (returnData == null) {
      dataService.getData(
          dataProvider, globals.clientId, columnNames, null, null).then((
      JVxData jvxData) {
        data.add(jvxData);
        buttonCallback(<ChangedComponent>[]);
      });
      return null;
    } else {
      return returnData;
    }
  }

  void _addComponent(ChangedComponent component) {
    JVxComponent componentClass;

    if (!components.containsKey(component.id)) {
      componentClass = JVxComponentCreator.create(component, context);
    } else {
      componentClass = components[component.id];
    }

    if (componentClass!= null) {
      componentClass.state = JVxComponentState.Added;
      components.putIfAbsent(component.id, () => componentClass);
      _addToParent(componentClass);
    } 
  }

  void _addToParent(JVxComponent component) {
    if (component.parentComponentId?.isNotEmpty ?? false) {
      JVxComponent parentComponent = components[component.parentComponentId];
      if (parentComponent!= null && parentComponent is JVxContainer) {
        parentComponent.addWithConstraints(component, component.constraints);
      }
    }
  }

  void _removeComponent(JVxComponent component) {
    _removeFromParent(component);
    component.state = JVxComponentState.Free;
  }

  void _removeFromParent(JVxComponent component) {
    if (component.parentComponentId!=null && component.parentComponentId.isNotEmpty) {
      JVxComponent parentComponent = components[component.parentComponentId];
      if (parentComponent!= null && parentComponent is JVxContainer) {
          parentComponent?.removeWithComponent(component);
      }
    }
  }

  void _destroyComponent(JVxComponent component) {
    _removeComponent(component);
    components.remove(component.componentId);
    component.state = JVxComponentState.Destroyed;
  }

  void _moveComponent(JVxComponent component, ChangedComponent newComponent) {
    if (component.parentComponentId!=newComponent.parent) {
      if (debug)
        print("Move component (id:" + newComponent.id + 
              ",oldParent:" + (component.parentComponentId!=null?component.parentComponentId:"") +
              ",newParent:" + (newComponent.parent!=null?newComponent.parent:"") + 
              ", className: " + (newComponent.className!=null?newComponent.className:"") + ")");
      
      if (component.parentComponentId!=null) {
        _removeFromParent(component);
      }

      if (newComponent.parent!=null) {
        component.parentComponentId = newComponent.parent;
        _addToParent(component);
      }
    }
  }

  JVxComponent getRootComponent() {
    return this.components.values.firstWhere((element) => 
      element.parentComponentId==null && element.state==JVxComponentState.Added);
  }

  void debugPrintCurrentWidgetTree() {
    int level = 0;
    JVxComponent component = getRootComponent();
    print("--------------------");
    print("Current widget tree:");
    print("--------------------");
    debugPrintComponent(component, level);
    print("--------------------");
  }

  void debugPrintComponent(JVxComponent component, int level) {
    if (component!=null) {
      String debugString = "--" * level;

      debugString += " id: " + component.componentId.toString() + 
                     ", parent: " + (component.parentComponentId!=null?component.parentComponentId:"") +
                     ", className: " + component.runtimeType.toString() +
                     ", constraints: " + (component.constraints!=null?component.constraints:"")
                     ;

      if (component is JVxContainer) {
          debugString += ", layout: " + (component.layout!=null?component.layout.runtimeType.toString():"") +
                         ", childCount: " + (component.components!=null?component.components.length.toString():"0");
        print(debugString);
          
        if (component.components!=null) {
          component.components.forEach((c) {
            debugPrintComponent(c, (level+1));
          });
        }
      } else {
        print(debugString);
      }

    }
  }

  Widget getWidget() {

    if (debug) 
      debugPrintCurrentWidgetTree();

    JVxComponent component = this.getRootComponent();

    if (component!= null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }
}