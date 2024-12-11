import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
  Calendar({Key? key}) : super(key: key);

  void showCustomDateRangePicker(
      BuildContext context, {
        required bool dismissible,
        required DateTime minimumDate,
        required DateTime maximumDate,
        DateTime? startDate,
        DateTime? endDate,
        required Function(DateTime startDate, DateTime endDate) onApplyClick,
        required Function() onCancelClick,
        required Color backgroundColor,
        required Color primaryColor,
        String? fontFamily,
      }) {
    FocusScope.of(context).requestFocus(FocusNode());

    showDialog<dynamic>(
      context: context,
      builder: (BuildContext context) => Transform.scale(
        scale: 0.6, // Adjust this value to make the widget smaller or larger
        child: SingleChildScrollView(

          child: Container(
            height: 1700, // Adjust this value as needed
            child: CustomDateRangePicker(
              barrierDismissible: true,
              backgroundColor: backgroundColor,
              primaryColor: primaryColor,
              minimumDate: minimumDate,
              maximumDate: maximumDate,
              initialStartDate: startDate,
              initialEndDate: endDate,
              onApplyClick: onApplyClick,
              onCancelClick: onCancelClick,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }
}