// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:meta/meta.dart' show required;
import '../../common/chart_context.dart' show ChartContext;
import '../../../common/graphics_factory.dart' show GraphicsFactory;
import 'axis.dart' show AxisOrientation;
import 'scale.dart' show MutableScale, Extents;
import 'tick.dart' show Tick;
import 'tick_formatter.dart' show TickFormatter;
import 'draw_strategy/tick_draw_strategy.dart' show TickDrawStrategy;

/// A strategy for selecting values for axis ticks based on the domain values.
///
/// [D] is the domain type.
abstract class TickProvider<D, E extends Extents,
    S extends MutableScale<D, E>> {
  /// Returns a list of ticks in value order that should be displayed.
  ///
  /// This method should not return null. If no ticks are desired an empty list
  /// should be returned.
  ///
  /// [graphicsFactory] The graphics factory used for text measurement.
  /// [scale] The scale of the data.
  /// [formatter] The formatter to use for generating tick labels.
  /// [axisOrientation] Orientation of this axis ticks.
  /// [tickDrawStrategy] Draw strategy for ticks.
  List<Tick<D>> getTicks({
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required S scale,
    @required TickFormatter<D> formatter,
    @required Map<D, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    @required AxisOrientation orientation,
    bool viewportExtensionEnabled: false,
  });
}

/// A base tick provider.
abstract class BaseTickProvider<D, E extends Extents,
    S extends MutableScale<D, E>> implements TickProvider<D, E, S> {
  const BaseTickProvider();

  /// Create ticks from [domainValues].
  List<Tick<D>> createTicks(
    List<D> domainValues, {
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required S scale,
    @required TickFormatter<D> formatter,
    @required Map<D, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    num stepSize,
  }) {
    final ticks = <Tick<D>>[];
    final labels =
        formatter.format(domainValues, formatterValueCache, stepSize: stepSize);

    for (var i = 0; i < domainValues.length; i++) {
      final value = domainValues[i];
      final tick = new Tick(
          value: value,
          textElement: graphicsFactory.createTextElement(labels[i]),
          locationPx: scale[value]);

      ticks.add(tick);
    }

    // Allow draw strategy to decorate the ticks.
    tickDrawStrategy.decorateTicks(ticks);

    return ticks;
  }
}
