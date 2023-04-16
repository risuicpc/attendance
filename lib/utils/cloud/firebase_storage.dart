import 'package:attendance/constants/cloud_storage.dart';
import 'package:attendance/utils/cloud/storage_exceptions.dart';
import 'package:attendance/utils/cloud/user_info.dart';
import 'package:attendance/utils/cloud/user_workday.dart';
import 'package:attendance/utils/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStorage {
  factory FirebaseStorage() => _shared;
  static final _shared = FirebaseStorage._sharedInstance();
  FirebaseStorage._sharedInstance();

// CRUD FOR USERINFO
  final _userInfo = FirebaseFirestore.instance.collection('user-info');
  Future<void> initCreateUserInfo({
    required String userId,
    required String userName,
  }) async {
    try {
      final deviceInfo = await getDeviceInfo();
      await createUserInfo(
        userId: userId,
        userName: userName,
        numberOfLate: 0,
        numberOfAbsent: 0,
        deviceId: deviceInfo.deviceId,
        androidId: deviceInfo.androidId,
      );
    } catch (_) {}
  }

  Future<void> createUserInfo({
    required String userId,
    required String userName,
    required int numberOfLate,
    required int numberOfAbsent,
    required String deviceId,
    required String androidId,
  }) async {
    final userInfo = await getUserInfo(userId: userId);
    if (userInfo == null) {
      try {
        await _userInfo.add({
          userIdFieldName: userId,
          userNameFieldName: userName,
          numberOfLateFieldName: numberOfLate,
          numberOfAbsentFieldName: numberOfAbsent,
          deviceIdFieldName: deviceId,
          androidIdFieldName: androidId
        });
      } catch (_) {
        throw CouldNotCreateException();
      }
    } else {
      throw AlreadyCreatedException();
    }
  }

  Future<UserInfo?> getUserInfo({required String userId}) async {
    try {
      final userInfo = await _userInfo
          .where(userIdFieldName, isEqualTo: userId)
          .get()
          .then((value) => value.docs.map((e) => UserInfo.fromSnapshot(e)));
      return userInfo.first;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isTheDeviceRegistered async {
    try {
      final deviceInfo = await getDeviceInfo();
      final exist = await _userInfo
          .where(deviceIdFieldName, isEqualTo: deviceInfo.deviceId)
          .where(androidIdFieldName, isEqualTo: deviceInfo.androidId)
          .get()
          .then((value) => value.docs);
      return exist.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> updateUserInfo({
    required String id,
    required int numberOfLate,
    required int numberOfAbsent,
  }) async {
    try {
      await _userInfo.doc(id).update({
        numberOfLateFieldName: numberOfLate,
        numberOfAbsentFieldName: numberOfAbsent
      });
    } catch (_) {
      throw CouldNotUpdateException();
    }
  }

  Stream<Iterable<UserInfo>> get allUserInfo {
    return _userInfo
        .snapshots()
        .map((event) => event.docs.map((doc) => UserInfo.fromSnapshot(doc)));
  }

// CRUD FOR USERWORKDAY
  final _userWorkday = FirebaseFirestore.instance.collection('workday');
  Future<void> createUserWorkday({
    required String userId,
    required String userName,
    required bool monday,
    required bool tuesday,
    required bool wednesday,
    required bool thursday,
    required bool friday,
    required bool saturday,
    required bool sunday,
  }) async {
    final workday = await getUserWorkday(userId: userId);
    if (workday == null) {
      try {
        await _userWorkday.add({
          userIdFieldName: userId,
          userNameFieldName: userName,
          mondayFieldName: monday,
          tuesdayFieldName: tuesday,
          wednesdayFieldName: wednesday,
          thursdayFieldName: thursday,
          fridayFieldName: friday,
          saturdayFieldName: saturday,
          sundayFieldName: sunday,
        });
      } on FirebaseException catch (e) {
        switch (e.code) {
          case "permission-denied":
            throw PermissionDeniedException();
          default:
            throw GenericCloudException();
        }
      } catch (_) {
        throw GenericCloudException();
      }
    } else {
      throw AlreadyCreatedException();
    }
  }

  Future<UserWorkday?> getUserWorkday({required String userId}) async {
    try {
      final userWorkday = await _userWorkday
          .where(userIdFieldName, isEqualTo: userId)
          .get()
          .then((value) => value.docs.map((e) => UserWorkday.fromSnapshot(e)));
      return userWorkday.first;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateUserWorkday({required UserWorkday obj}) async {
    try {
      await _userWorkday.doc(obj.id).update({
        mondayFieldName: obj.monday,
        tuesdayFieldName: obj.tuesday,
        wednesdayFieldName: obj.wednesday,
        thursdayFieldName: obj.thursday,
        fridayFieldName: obj.friday,
        saturdayFieldName: obj.saturday,
        sundayFieldName: obj.sunday,
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "permission-denied":
          throw PermissionDeniedException();
        default:
          throw CouldNotUpdateException();
      }
    } catch (_) {
      throw CouldNotUpdateException();
    }
  }

  Future<bool> isPermissionAllow({
    required id,
    required userId,
  }) async {
    try {
      await _userWorkday.doc(id).update({
        userIdFieldName: userId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Stream<Iterable<UserWorkday>> get allUserWorkday {
    return _userWorkday
        .snapshots()
        .map((event) => event.docs.map((doc) => UserWorkday.fromSnapshot(doc)));
  }
}
