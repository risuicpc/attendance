import 'package:attendance/api/cloud/atendance.dart';
import 'package:attendance/api/cloud/office_location.dart';
import 'package:attendance/api/cloud/setting.dart';
import 'package:attendance/api/cloud/storage_exceptions.dart';
import 'package:attendance/api/cloud/user_info.dart';
import 'package:attendance/api/cloud/user_workday.dart';
import 'package:attendance/constants/cloud_storage.dart';
import 'package:attendance/extensions/date_time.dart';
import 'package:attendance/utils/device_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStorage {
  factory FirebaseStorage() => _shared;
  static final _shared = FirebaseStorage._sharedInstance();
  FirebaseStorage._sharedInstance();

  final _domain = FirebaseFirestore.instance.collection('domain');
  Future<Iterable<String>> get getDomain async {
    try {
      return await _domain
          .get()
          .then((value) => value.docs.map((e) => e.data()['domain']));
    } catch (_) {
      return [];
    }
  }

  // CRUD FOR USERINFO
  final _userInfo = FirebaseFirestore.instance.collection('user-info');

  Future<void> createUserInfo({
    required String userId,
    required String userName,
  }) async {
    final userInfo = await getUserInfo(userId: userId);
    if (userInfo != null) {
      throw AlreadyCreatedException();
    }

    final deviceInfo = await getDeviceInfo();

    try {
      await _userInfo.add({
        userIdFieldName: userId,
        userNameFieldName: userName,
        numberOfLateFieldName: 0,
        numberOfAbsentFieldName: 0,
        deviceIdFieldName: deviceInfo.deviceId,
        androidIdFieldName: deviceInfo.androidId
      });
    } catch (_) {
      throw CouldNotCreateException();
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
      if (deviceInfo.androidId == "Unknown ID" ||
          deviceInfo.deviceId == "Unknown ID") return false;

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
  }) async {
    final workday = await getUserWorkday(userId: userId);

    if (workday != null) {
      throw AlreadyCreatedException();
    }

    try {
      await _userWorkday.add({
        userIdFieldName: userId,
        userNameFieldName: userName,
        mondayFieldName: true,
        tuesdayFieldName: true,
        wednesdayFieldName: true,
        thursdayFieldName: true,
        fridayFieldName: true,
        saturdayFieldName: true,
        sundayFieldName: false,
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

  Future<bool> get isPermissionAllowToUpdate async {
    try {
      await _userWorkday.doc("id").get();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == "permission-denied") return false;
      return true;
    } catch (_) {
      return false;
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

  Stream<Iterable<UserWorkday>> get allUserWorkday {
    return _userWorkday
        .snapshots()
        .map((event) => event.docs.map((doc) => UserWorkday.fromSnapshot(doc)));
  }

  // CRUD FOR SETTING
  final _setting = FirebaseFirestore.instance.collection('setting');

  Future<void> createSetting({
    required String startTime,
    required String lateTime,
    required String endTime,
  }) async {
    final setting = await getSetting;
    if (setting != null) {
      throw AlreadyCreatedException();
    }

    try {
      await _setting.add({
        startTimeFieldName: startTime,
        lateTimeFieldName: lateTime,
        endTimeFieldName: endTime
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "permission-denied":
          throw PermissionDeniedException();
        default:
          throw CouldNotCreateException();
      }
    } catch (_) {
      throw CouldNotCreateException();
    }
  }

  Future<bool> get isSettingPermissionAllow async {
    try {
      await _setting.doc("id").get();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == "permission-denied") return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Setting?> get getSetting async {
    try {
      final setting = await _setting
          .get()
          .then((value) => value.docs.map((e) => Setting.fromSnapshot(e)));
      return setting.first;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateSettingTimestamp({
    required String id,
    required String startTime,
    required String lateTime,
    required String endTime,
  }) async {
    try {
      await _setting.doc(id).update({
        startTimeFieldName: startTime,
        lateTimeFieldName: lateTime,
        endTimeFieldName: endTime
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

  // CRUD FOR ATTENDACE
  final _attendace = FirebaseFirestore.instance.collection('attendance');

  Future<void> addAttendace({
    required String userId,
    required DateTime day,
    required String status,
  }) async {
    final today = await getAttendace(userId: userId);
    if (today != null) {
      if (DateTime.now().isAtSameDayAs(today.day)) {
        throw AlreadyCreatedException();
      }
    }

    try {
      await _attendace.add({
        userIdFieldName: userId,
        dayFieldName: day,
        statusFieldName: status
      });
    } catch (_) {
      throw CouldNotCreateException();
    }
  }

  Future<Attendace?> getAttendace({required String userId}) async {
    try {
      final userAttendace = await _attendace
          .where(userIdFieldName, isEqualTo: userId)
          .get()
          .then((value) => value.docs.map((e) => Attendace.fromSnapshot(e)));
      final sort = userAttendace.toList();
      sort.sort((a, b) => b.day.compareTo(a.day));
      return sort.first;
    } catch (_) {
      return null;
    }
  }

  Stream<Iterable<Attendace>> get getAllAttendace {
    return _attendace
        .snapshots()
        .map((event) => event.docs.map((doc) => Attendace.fromSnapshot(doc)));
  }

  // CRUD FOR LOCATION
  final _location = FirebaseFirestore.instance.collection('location');

  Future<void> addLocation({
    required String officeName,
    required double latitude,
    required double longitude,
    required double distance,
  }) async {
    final exist = await getLocation;
    if (exist != null) {
      throw AlreadyCreatedException();
    }

    try {
      await _location.add({
        officeNameFieldName: officeName,
        longitudeFieldName: longitude,
        latitudeFieldName: latitude,
        distanceFieldName: distance
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        case "permission-denied":
          throw PermissionDeniedException();
        default:
          throw CouldNotUpdateException();
      }
    } catch (_) {
      throw CouldNotCreateException();
    }
  }

  Future<void> updateLocation({
    required String id,
    required String officeName,
    required double latitude,
    required double longitude,
    required double distance,
  }) async {
    try {
      await _location.doc(id).update({
        officeNameFieldName: officeName,
        longitudeFieldName: longitude,
        latitudeFieldName: latitude,
        distanceFieldName: distance
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

  Future<OfficeLocation?> get getLocation async {
    try {
      final location = await _location.get().then(
          (value) => value.docs.map((e) => OfficeLocation.fromSnapshot(e)));
      return location.first;
    } catch (_) {
      return null;
    }
  }

  Future<bool> get isLocationPermissionAllow async {
    try {
      await _location.doc("id").get();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == "permission-denied") return false;
      return true;
    } catch (_) {
      return false;
    }
  }
}
