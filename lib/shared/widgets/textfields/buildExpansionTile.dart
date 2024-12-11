import 'package:flutter/material.dart';

class ExpansionSection extends StatefulWidget {
  final String title;
  final String buttonText;
  final VoidCallback onPressed;
  final bool isExpanded;
  final VoidCallback onExpansionChanged;
  final Widget selectedItems;

  const ExpansionSection({
    required this.title,
    required this.buttonText,
    required this.onPressed,
    required this.isExpanded ,
    required this.onExpansionChanged,
    required this.selectedItems,
    Key? key,
  }) : super(key: key);

  @override
  _ExpansionSectionState createState() => _ExpansionSectionState();
}

class _ExpansionSectionState extends State<ExpansionSection> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Container(
      child: ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.all(0),
        expansionCallback: (int index, bool isExpanded) {
          widget.onExpansionChanged();
        },
        children: [
          ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return ListTile(
                title: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            body: Container(
              width: size.width * .20,
              height: size.height * .45+15,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
              ),
              child: SingleChildScrollView(
                child:Column(
                  children: [
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: widget.onPressed,
                      child:
                        Text(
                            widget.buttonText,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.background, elevation: 0),
                    ),
                    SizedBox(height: 10,),
                     widget.selectedItems,
                ],
              ),
            ),),
            isExpanded: widget.isExpanded,
            canTapOnHeader: false,
          ),
        ],
      ),
    );
  }
}

