import 'package:flutter/material.dart';

void hien_thi_man_hinh(BuildContext context, Widget manHinh) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => manHinh));
}

void quay_ve_man_hinh_truoc(BuildContext context) {
  Navigator.pop(context);
}

void quay_ve_man_hinh_chinh(BuildContext context) {
  Navigator.popUntil(context, (route) => route.isFirst);
}
