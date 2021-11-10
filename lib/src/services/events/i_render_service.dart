import 'package:flutter_jvx/src/models/events/render/perform_render_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_preferred_size_event.dart';
import 'package:flutter_jvx/src/models/events/render/unregister_parent_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/render/on_register_parent_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/render/on_register_preferred_size_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/render/on_unregister_parent_event.dart';

/// This class takes in RenderEvents([RegisterParentEvent], [RegisterPreferredSizeEvent], [UnregisterParentEvent])
/// and should fire [PerformRenderEvent] to tell specific Components to re-layout themselves.
abstract class IRenderService with OnRegisterParentEvent, OnRegisterPreferredSizeEvent, OnUnregisterParentEvent {

  IRenderService(){
    registerParentEventStream.listen(receivedRegisterParentEvent);
    registerPreferredSizeEventStream.listen(receivedRegisterPreferredSizeEvent);
    unregisterParentEventStream.listen(receivedUnregisterParentEvent);
  }

  void receivedRegisterParentEvent(RegisterParentEvent event);
  void receivedRegisterPreferredSizeEvent(RegisterPreferredSizeEvent event);
  void receivedUnregisterParentEvent(UnregisterParentEvent event);
}