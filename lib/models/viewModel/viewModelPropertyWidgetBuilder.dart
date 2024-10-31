import 'package:alpha/models/viewModel/viewModel.dart';
import 'package:flutter/widgets.dart';

class ViewModelPropertyWidgetBuilder<TPropertyType>
    extends StreamBuilder<PropertyChangedEvent> {
  // Properties

  // Methods

  ViewModelPropertyWidgetBuilder(
      {required Key key,
      required ViewModel viewModel,
      required String propertyName,
      required AsyncWidgetBuilder<PropertyChangedEvent> builder})
      : super(
            key: key,
            builder: builder,
            stream: viewModel.whenPropertyChanged(propertyName));
}
