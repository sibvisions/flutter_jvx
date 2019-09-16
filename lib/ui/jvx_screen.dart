import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/select_record_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/select_record_view_model.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/model/filter.dart';
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
    changedComponentsJson?.forEach((changedComponent) {
        if (components.containsKey(changedComponent.id)) {
          JVxComponent component = components[changedComponent.id];

          if (changedComponent.destroy) {
            _destroyComponent(component);
          } else if (changedComponent.remove) {
            _removeComponent(component);
          } else {
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
          this._addComponent(changedComponent);
        }
    });
  }

  void selectRecord(String dataProvider, int index, [bool fetch = false]) {
    DataService dataService = DataService(RestClient());

    JVxData selectData = this.getData(dataProvider);

    if (selectData != null && index < selectData.records.length) {
      /*
      SelectRecordBloc selectRecordBloc = SelectRecordBloc();
      StreamSubscription<FetchProcess> apiStreamSubscription = 
        apiSubscription(selectRecordBloc.apiResult, context);
      selectRecordBloc.selectRecordController.add(
        SelectRecordViewModel(clientId: globals.clientId, 
          dataProvider: dataProvider,
          filter: Filter(columnNames: selectData.columnNames, values: selectData.records[index]), 
          fetch: fetch)
      );
      */
      dataService.selectRecord(dataProvider, selectData.columnNames, selectData.records[index], fetch, globals.clientId)
          .then((val) => getIt.get<JVxScreen>().buttonCallback(val.updatedComponents));
    }
  }

  void setValues(String dataProvider, List columnNames, List values, List filterColumnNames, List filterValues) {
    DataService dataService = DataService(RestClient());

    return dataService.setValues(dataProvider, columnNames, values, filterColumnNames, filterValues);
  }

  JVxData getData(String dataProvider, [List<dynamic> columnNames]) {
    DataService dataService = DataService(RestClient());

    var returnData;

    data.forEach((data) {
      data.dataProvider == dataProvider ? returnData = data : returnData = null;
      print('DATAPROVIDER: $dataProvider + DATA DATA PROVIDER: ${data.dataProvider}');
    });

    if (returnData == null) {
      dataService.getData(
          dataProvider, globals.clientId, columnNames, null, null).then((
      JVxData jvxData) {
        // jvxData.records.add(['LORENZ']);
        // jvxData.records.add(['JÜRGEN']);
        data.add(jvxData);
        buttonCallback(<ChangedComponent>[]);
        //return returnData;
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

      if (componentClass.parentComponentId?.isNotEmpty ?? false) {
        JVxComponent parentComponent = components[componentClass.parentComponentId];
        if (parentComponent!= null && parentComponent is JVxContainer) {
          parentComponent.addWithConstraints(componentClass, componentClass.constraints);
        }
      }
    } 
  }


  void _removeComponent(JVxComponent component) {
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
    
  }

  JVxComponent getRootComponent() {
    return this.components.values.firstWhere((element) => 
      element.parentComponentId==null && element.state==JVxComponentState.Added);
  }

  Widget getWidget() {
    JVxComponent component = this.getRootComponent();

    if (component!= null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('Test'),
      );
    }
  }
}