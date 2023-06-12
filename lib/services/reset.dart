

import 'package:firebase_auth/firebase_auth.dart';
import 'package:pollar/model/Comment/comment_model.dart';
import 'package:pollar/model/Poll/database/delete_all.dart';
import 'package:pollar/model/Report/report_model.dart';
import 'package:pollar/model/user/database/delete_user_db.dart';

// WILL DELETE EVERYTHING
//TODO:  WE NEED TO ONLY LET ADMIN FIREBASE USERS USE THIS
void hardResetDataBase()
{
  deleteAllComment();
  deleteAllPoll();
  deleteAllUser();  
  deleteAllReport();
}


