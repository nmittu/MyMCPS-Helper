class GradingCategory{
  String Description;
  String Weight;
  String PointsEarned;
  String PointsPossible;

  GradingCategory({
    this.Description,
    this.Weight,
    this.PointsEarned,
    this.PointsPossible
  });

  factory GradingCategory.fromJson(Map<dynamic, dynamic> parsedJson){
    return GradingCategory(
        Description: parsedJson['Description'],
        Weight : parsedJson['Weight'],
        PointsEarned : parsedJson ['PointsEarned'],
        PointsPossible : parsedJson ['PointsPossible']
    );
  }
}