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
  RECEIVE_JEWEL_CHIP
}

enum CardLocation {
  PACK,
  EXHIBITION
}

struct Card {
  1: required id id;
  2: required CardGrade cardGrade;
  3: required bool revealed;
  6: optional JewelType jewelType;
  7: optional i32 point;
  8: optional map<JewelType, i32> costs;
}

struct JewelChip {
  1: required id id;
  6: required JewelType jewelType;
}

struct Noble {
  1: required id id;
  7: required i32 point;
  8: optional map<JewelType, i32> costs;
}

struct Player {
  1: required id id;
  2: required bool isMe;
  3: required map<JewelType, set<Card>> purchasedCards;
  4: required set<Card> reservedCards;
  5: required map<JewelType, set<JewelChip>> jewelChips;
  6: required set<Noble> nobles;
}

struct CenterField {
  1: required map<CardLocation, map<CardGrade, set<Card>>> cards;
  2: required map<JewelType, set<JewelChip>> jewelChips;
  3: required set<Noble> nobles;
}

struct Game {
  1: required id id;
  2: required CenterField centerField;
  3: required set<Player> players;
}

struct ActionResult {
  1: required ActionType actionType;
  2: optional id cardId;
  3: optional map<JewelType, i32> receiveJewelChipMap;
  4: optional map<JewelType, i32> returnJewelChipMap;
}

service SplendorAi
{
  void hi()
  ActionResult play(1:Game game)
}
