namespace rb splendorThrift
/*
 C like comments are supported
*/
// This is also a valid comment

typedef string id

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

struct PurchaseCard {
  1: required id cardId,
  2: optional id nobleId,
  3: required map<JewelType, i32> returnJewelChipMap;
}

struct ReserveCard {
  1: required id cardId,
  2: required map<JewelType, i32> receiveJewelChipMap;
  3: required map<JewelType, i32> returnJewelChipMap;
}

struct ReceiveJewelChip {
  1: required map<JewelType, i32> receiveJewelChipMap;
  2: required map<JewelType, i32> returnJewelChipMap;
}

union ActionResult {
  1: PurchaseCard purchaseCard,
  2: ReserveCard reserveCard,
  3: ReceiveJewelChip receiveJewelChip,
}
service SplendorAi
{
  void hi()
  ActionResult play(1:Game game)
}
