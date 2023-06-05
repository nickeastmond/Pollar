

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/Comment/comment_model.dart';
import 'package:pollar/model/Poll/database/delete_all.dart';
import 'package:pollar/model/Report/report_model.dart';
import 'package:pollar/model/user/database/delete_user_db.dart';

void hardResetDataBase()
{
  deleteAllComment();
  deleteAllPoll();
  deleteAllUser();  
  deleteAllReport();
}


