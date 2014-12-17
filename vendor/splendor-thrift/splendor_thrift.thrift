namespace rb splendorThrift
/*
 C like comments are supported
*/
// This is also a valid comment

typedef i32 id

enum JewelType {
  DIAMOND,
  SAPPHIRE,
  EMERALD,
  RUBY,
  ONYX,
  GOLD
}

enum CardGrade {
  FIRST = 1,
  SECOND,
  THIRD
}

enum ActionType {
  PURCHASE_CARD,
  RESERVE_CARD,
  RECEIVE_JEWEL_CHIP,
}

struct Card {
  1: required id id;
  2: required CardGrade cardGrade;
  3: required bool revealed;
  4: required bool reserved;
  5: optional id userId;
  6: optional JewelType jewelType;
  7: optional i32 point;
  8: optional map<JewelType, i32> costs;
}

struct JewelChip {
  1: required id id;
  5: optional id userId;
  6: required JewelType jewelType;
}

struct Noble {
  1: required id id;
  5: optional id userId;
  7: required i32 point;
  8: optional map<JewelType, i32> costs;
}

struct User {
  1: required id id;
  2: required bool me;
}

struct Game {
  1: required id id;
  2: required id currentTurnUserId;
  3: required set<id> orderUserIds;
  4: optional id winnerId;
  5: required set<User> users;
  6: required set<Card> cards;
  7: required set<JewelChip> jewelChips;
  8: required set<Noble> nobles;
}

struct ActionResult {
  1: required ActionType actionType;
  2: optional Card purchasedCard;
  3: optional Card reservedCard;
}

service Player
{
  void hi()
  ActionResult play(1:Game game, 2:id userId)
}
