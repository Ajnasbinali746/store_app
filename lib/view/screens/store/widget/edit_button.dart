import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/dimensions.dart';

class EditButton extends StatefulWidget {
  final Function onTap;
  const EditButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<EditButton> createState() => _EditButtonState();
}

class _EditButtonState extends State<EditButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : () async{
        setState(() {
          isLoading = true;
        });
        await widget.onTap();
        setState(() {
          isLoading = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault), border: Border.all(color: Theme.of(context).primaryColor),),
        child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : Icon(Icons.edit, color: Theme.of(context).primaryColor, size: 20),
      ),
    );
  }
}
