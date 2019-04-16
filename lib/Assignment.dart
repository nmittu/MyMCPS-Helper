class Assignment{
  String AssignmentType;
  String Description;
  String OrigGrade = null;
  String Grade;
  String Points;
  String Possible;
  String Percent;

  Assignment({
    this.AssignmentType,
    this.Description,
    this.Grade,
    this.Points,
    this.Possible,
    this.Percent
  });

  factory Assignment.fromJson(Map<dynamic, dynamic> parsedJson){
    return Assignment(
        AssignmentType: parsedJson['AssignmentType'],
        Description : parsedJson['Description'],
        Grade : parsedJson ['Grade'],
        Points : parsedJson ['Points'],
        Possible : parsedJson ['Possible'],
        Percent: parsedJson ['Percent']
    );
  }
}