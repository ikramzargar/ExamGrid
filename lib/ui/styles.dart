import 'package:flutter/material.dart';

kTextFieldDecoration({required BuildContext context, required String title, Widget? suffix, String? prefix}){

  return InputDecoration(
    suffixIcon: suffix,
    prefixText: prefix,
    filled: true,
    fillColor: Color(0xfffff7f1),
    labelText: title,
    focusedBorder:  OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide:
      BorderSide(color:Theme.of(context).colorScheme.secondary, width: 1),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide:
      BorderSide(color:Colors.red, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide:
      BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
    ),

  );
}