import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserName({required String userId}) async {
    String username = "";
    var userData = await _firestore.collection("Users").doc(userId).get();
    username = userData["username"];
    return username;
  }

  Future<Map<String, dynamic>> getUserData({required String userId}) async {
    try {
      DocumentSnapshot userData =
          await _firestore.collection("Users").doc(userId).get();
      if (userData.exists) {
        return userData.data() as Map<String, dynamic>;
      } else {
        return {};
      }
    } catch (e) {
      throw Exception('Error fetching user data');
    }
  }

  Future<void> follow(
      {required String userId, required String currentUserId}) async {
    DocumentReference userRef = _firestore.collection("Users").doc(userId);

    DocumentReference currentUserRef =
        _firestore.collection("Users").doc(currentUserId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot =
          await transaction.get(currentUserRef);

      if (currentUserSnapshot.exists) {
        List following = currentUserSnapshot.get("following");
        if (following.contains(userId)) {
          following.remove(userId);
          transaction.update(userRef, {
            "follower": FieldValue.arrayRemove([currentUserId])
          });
        } else {
          following.add(userId);
          transaction.update(userRef, {
            "follower": FieldValue.arrayUnion([currentUserId])
          });
        }

        transaction.update(currentUserRef, {"following": following});
      }
    });
  }

  Future<void> editUserData(
      {required String userId,
      required Map<String, dynamic> editedUserData}) async {
    DocumentReference userRef = _firestore.collection("Users").doc(userId);

    await _firestore.runTransaction((transaction) async {
      transaction.update(userRef, editedUserData);
    });
  }
}
